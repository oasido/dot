#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "playwright",
# ]
# ///
"""
Meckano Time Punch CLI

Usage:
    python meckano_punch.py in      # Punch in (start of day)
    python meckano_punch.py out     # Punch out (end of day)
    python meckano_punch.py status  # Check current status

Set credentials in .meckano_config file:
    username=your_email
    password=your_password
"""

import argparse
import json
import sys
from pathlib import Path

from playwright.sync_api import sync_playwright

BASE_URL = "https://app.meckano.co.il"
CONFIG_PATH = Path(__file__).parent / ".meckano_config"
STATE_PATH = Path(__file__).parent / ".meckano_state.json"


def load_config():
    """Load config from file."""
    if not CONFIG_PATH.exists():
        print(f"Error: Config file not found at {CONFIG_PATH}")
        print("Create it with:")
        print("  username=your_email")
        print("  password=your_password")
        print("  task_id=your_task_id")
        sys.exit(1)

    config = {}
    with open(CONFIG_PATH) as f:
        for line in f:
            line = line.strip()
            if "=" in line and not line.startswith("#"):
                key, value = line.split("=", 1)
                config[key.strip()] = value.strip()

    if "username" not in config or "password" not in config:
        print("Error: Config file must contain username and password")
        sys.exit(1)

    return config


class MeckanoClient:
    def __init__(self, headless=True):
        self.headless = headless
        self.playwright = None
        self.browser = None
        self.context = None
        self.page = None
        self.api_responses = {}

    def __enter__(self):
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=self.headless)

        # Try to restore saved session state
        if STATE_PATH.exists():
            try:
                self.context = self.browser.new_context(storage_state=str(STATE_PATH))
            except Exception:
                self.context = self.browser.new_context()
        else:
            self.context = self.browser.new_context()

        self.page = self.context.new_page()

        # Capture API responses
        def handle_response(response):
            if "/api/" in response.url:
                try:
                    self.api_responses[response.url] = response.json()
                except Exception:
                    pass

        self.page.on("response", handle_response)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.context:
            self.context.close()
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()

    def login(self, username, password):
        """Login to Meckano."""
        self.page.goto(BASE_URL)
        self.page.wait_for_timeout(5000)  # Wait for page to fully load/redirect

        current_url = self.page.url
        print(f"Initial URL: {current_url}")

        # Check if already logged in (redirected to dashboard)
        if "dashboard" in current_url:
            print("Already logged in (session restored)")
            self.context.storage_state(path=str(STATE_PATH))
            return True

        # Check if login form exists or if we're on dashboard
        email_input = self.page.locator("input#email")
        if email_input.count() == 0:
            # No login form - check if we're on the dashboard
            # Look for dashboard elements like the timer or user greeting
            dashboard_indicator = self.page.locator(
                '.dashboard, .user-greeting, [class*="attendance"]'
            )
            if dashboard_indicator.count() > 0 or "dashboard" in self.page.url:
                print("Already logged in (on dashboard)")
                self.context.storage_state(path=str(STATE_PATH))
                return True
            # Wait a bit more and check again
            self.page.wait_for_timeout(3000)
            if self.page.locator("input#email").count() == 0:
                # Still no login form - assume logged in
                print("Already logged in (no login form)")
                self.context.storage_state(path=str(STATE_PATH))
                return True

        # Fill login form
        try:
            password_input = self.page.locator("input#password")

            email_input.fill(username)
            password_input.fill(password)

            # Click login button
            login_btn = self.page.locator(
                'input.send.login, input[name="submit"].login'
            )
            login_btn.first.click()

            # Wait for navigation
            self.page.wait_for_timeout(5000)

            if "dashboard" in self.page.url:
                print("Logged in successfully")
                self.context.storage_state(path=str(STATE_PATH))
                return True
            else:
                print(f"Warning: Unexpected URL after login: {self.page.url}")
                self.page.wait_for_timeout(3000)
                if "dashboard" in self.page.url:
                    print("Logged in (after extra wait)")
                    self.context.storage_state(path=str(STATE_PATH))
                    return True
                return False

        except Exception as e:
            print(f"Login failed: {e}")
            self.page.screenshot(path=str(Path(__file__).parent / "login_error.png"))
            return False

    def get_status(self):
        """Get current punch status."""
        # Make sure we're on the dashboard
        if "#dashboard" not in self.page.url:
            self.page.goto(f"{BASE_URL}/#dashboard")

        # Wait for time entries to load
        self.page.wait_for_timeout(5000)

        # Find time entry API response
        for url, data in self.api_responses.items():
            if "timeEntry" in url and data.get("status") == 0:
                entries = data.get("data", [])
                if not entries:
                    print("No entries today - you haven't punched in")
                    return None

                print(f"Latest entries ({len(entries)}):")
                for entry in entries:
                    direction = "OUT" if entry.get("isOut") else "IN"
                    time_str = entry.get("timeStr", "?")
                    date_str = entry.get("dateStr", "")
                    if date_str:
                        print(f"  {date_str} {time_str} - {direction}")
                    else:
                        print(f"  {time_str} - {direction}")

                last_entry = entries[-1]
                if last_entry.get("isOut"):
                    print("\nStatus: Currently punched OUT")
                    return "out"
                else:
                    print("\nStatus: Currently punched IN")
                    return "in"

        print("Could not retrieve status")
        return None

    def _get_actions_token(self):
        """Extract actionsToken from captured API responses."""
        for url, data in self.api_responses.items():
            if isinstance(data, dict):
                inner_data = data.get("data")
                if isinstance(inner_data, dict) and inner_data.get("actionsToken"):
                    return inner_data["actionsToken"]
        return None

    def _select_task(self, task_id, actions_token, start=True):
        """
        Select/start or stop a task.
        start: True to start task, False to stop
        """
        task_data = {
            "taskStop": not start,
            "taskId": str(task_id),
            "disclaimerLocation": 2,
            "actionsToken": actions_token,
        }

        payload = f"_method=create&data={json.dumps(task_data)}"

        result = self.page.evaluate(f'''
            async () => {{
                const response = await fetch("{BASE_URL}/api/taskEntry/", {{
                    method: "POST",
                    headers: {{
                        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                    }},
                    body: `{payload}`,
                    credentials: "include"
                }});
                return await response.json();
            }}
        ''')

        if result and result.get("status") == 0:
            action = "Started" if start else "Stopped"
            print(f"{action} task {task_id}")
            return True
        else:
            error_msg = result.get("msg", "Unknown error") if result else "No response"
            print(f"Task selection failed: {error_msg}")
            return False

    def punch(self, action, task_id=None):
        """
        Punch in or out via API call.
        action: 'in' or 'out'
        task_id: optional task to select
        """
        # Make sure we're on the dashboard to get actionsToken
        if "#dashboard" not in self.page.url:
            self.page.goto(f"{BASE_URL}/#dashboard")
            self.page.wait_for_timeout(3000)

        # Extract actionsToken from captured API responses
        actions_token = self._get_actions_token()

        if not actions_token:
            print("Error: Could not find actionsToken")
            return False

        is_out = action == "out"

        # If task_id is provided, handle task selection
        if task_id:
            if is_out:
                # Stop task when punching out
                self._select_task(task_id, actions_token, start=False)
            else:
                # Start task when punching in
                self._select_task(task_id, actions_token, start=True)

        # Prepare punch request
        punch_data = {
            "id": None,
            "userId": None,
            "userName": None,
            "isOut": is_out,
            "ts": None,
            "mts": None,
            "disclaimerLocation": 2,
            "actionsToken": actions_token,
        }

        payload = f"_method=create&data={json.dumps(punch_data)}"

        # Execute punch via JavaScript fetch
        result = self.page.evaluate(f'''
            async () => {{
                const response = await fetch("{BASE_URL}/api/timeEntry/", {{
                    method: "POST",
                    headers: {{
                        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                    }},
                    body: `{payload}`,
                    credentials: "include"
                }});
                return await response.json();
            }}
        ''')

        if result and result.get("status") == 0:
            entry = result.get("data", {})
            time_str = entry.get("timeStr", "")
            action_text = "OUT" if is_out else "IN"
            print(f"Punched {action_text} successfully at {time_str}")
            return True
        else:
            error_msg = result.get("msg", "Unknown error") if result else "No response"
            print(f"Punch failed: {error_msg}")
            return False


def main():
    parser = argparse.ArgumentParser(
        description="Meckano Time Punch CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "action",
        choices=["in", "out", "status"],
        help="Punch action: 'in' (start), 'out' (end), or 'status'",
    )
    parser.add_argument(
        "--visible", action="store_true", help="Show browser window (for debugging)"
    )

    args = parser.parse_args()

    config = load_config()
    username = config["username"]
    password = config["password"]
    task_id = config.get("task_id")

    with MeckanoClient(headless=not args.visible) as client:
        if not client.login(username, password):
            sys.exit(1)

        if args.action == "status":
            client.get_status()
            success = True
        else:
            success = client.punch(args.action, task_id=task_id)

        sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
