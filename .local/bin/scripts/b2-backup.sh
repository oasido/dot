#!/bin/bash

BUCKET_NAME="pikachu-oasido"
DATE=$(date +"%Y-%m-%d")
FILENAME="${DATE}_pikachu.tar.gz"

SRC_DIR="/home/ofek"
DST_DIR="/tmp" # temporary directory for the tarball

sudo tar -czf "${DST_DIR}/${FILENAME}" "${SRC_DIR}"

if [ $? -ne 0 ]; then
  echo "Error creating tarball"
  exit 1
fi

b2v3-linux file upload --no-progress "${BUCKET_NAME}" "${DST_DIR}/${FILENAME}"

if [ $? -ne 0 ]; then
  echo "Error uploading tarball to B2"
  exit 1
fi

# Remove temporary tarball
rm "${DST_DIR}/${FILENAME}"
