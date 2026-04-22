# Meckano Punch CLI

A command-line tool to punch in/out on [Meckano](https://app.meckano.co.il) time tracking system.

## Features

- Punch in (start of day)
- Punch out (end of day)
- Check current status
- Automatically selects your configured task
- Caches login session for faster subsequent runs

## Requirements

- macOS (tested on macOS 12+)
- [uv](https://docs.astral.sh/uv/) — fast Python package manager

## Installation

### 1. Install uv (if not already installed)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 2. Install the Playwright browser (required once)

```bash
uv run --with playwright python -m playwright install chromium
```

### 3. Configure your credentials

```bash
# Copy the example config file
cp meckano_config.example .meckano_config

# Edit with your credentials
nano .meckano_config
```

Fill in:

- `username` - Your Meckano login email
- `password` - Your Meckano password
- `task_id` - Your task ID (see "Finding your task ID" below)

**Important:** Keep `.meckano_config` private. It contains your password.

### 4. Add shell aliases (optional but recommended)

Add these lines to your `~/.zshrc` (or `~/.bashrc`):

```bash
MECKANO=/path/to/meckano-punch-cli/meckano_punch.py
alias punch-in="uv run $MECKANO in"
alias punch-out="uv run $MECKANO out"
alias punch-status="uv run $MECKANO status"
```

Then reload your shell:

```bash
source ~/.zshrc
```

## Usage

### With aliases

```bash
punch-in       # Start of day
punch-out      # End of day
punch-status   # Check current status
```

### Without aliases

```bash
uv run meckano_punch.py in
uv run meckano_punch.py out
uv run meckano_punch.py status

# Debug with visible browser
uv run meckano_punch.py in --visible
```

## Finding your task ID

The task ID is an internal Meckano identifier, not the project code shown in the UI.

To find it:

1. Open <https://app.meckano.co.il> in Chrome
2. Log in and go to the dashboard
3. Open Developer Tools (Cmd+Option+I or F12)
4. Go to the **Network** tab
5. Filter by "Fetch/XHR"
6. Click on your task to select it
7. Look for a request to `/api/taskEntry/`
8. In the request payload, find `"taskId":"XXXXXX"` - that's your task ID

## Files

```
meckano-punch-cli/
├── meckano_punch.py       # Main script
├── environment.yml        # Conda environment definition
├── meckano_config.example # Example configuration (copy to .meckano_config)
├── .meckano_config        # Your credentials (create this, don't share!)
├── .meckano_playwrightstate.json    # Cached session (auto-generated)
└── README.md              # This file
```

## Troubleshooting

### "Login failed" error

- Verify your credentials in `.meckano_config`
- Try running with `--visible` flag to see what's happening
- Delete `.meckano_state.json` to clear cached session

### "Could not find actionsToken" error

- The session may have expired. Delete `.meckano_state.json` and try again

### Browser doesn't open

- Make sure Playwright browsers are installed: `playwright install chromium`

### Permission denied

- Make sure the script is executable: `chmod +x meckano_punch.py`

## Security Notes

- Your credentials are stored in plain text in `.meckano_config`
- The session state (cookies) is cached in `.meckano_state.json`
- Keep both files private and don't commit them to version control
- Add to `.gitignore`: `.meckano_config` and `.meckano_state.json`

## License

MIT - Use at your own risk. This is an unofficial tool not affiliated with Meckano.
