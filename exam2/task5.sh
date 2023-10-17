#!/bin/bash

ARCHIVE_URL="https://github.com/gabrieltalavera1986/rhce-practice-exams/raw/main/exam2/myfile.tgz"
ARCHIVE_NAME="myfile.tgz"
ARCHIVE_PATH="/tmp/myarchives/$ARCHIVE_NAME"
EXTRACT_DIR="/tmp/myarchives/"

# Check if the playbook exists
if [[ ! -f get_file.yml ]]; then
    echo "get_file.yml playbook does not exist."
    exit 1
fi

# Check if the playbook contains the necessary tasks
if ! grep -q "get_url" get_file.yml; then
    echo "get_file.yml does not contain the get_url module."
    exit 1
fi

if ! grep -q "$ARCHIVE_URL" get_file.yml; then
    echo "get_file.yml does not contain the correct archive URL."
    exit 1
fi

if ! grep -q "unarchive" get_file.yml; then
    echo "get_file.yml does not contain the unarchive module."
    exit 1
fi

# Check if the archive was downloaded
if [[ ! -f $ARCHIVE_PATH ]]; then
    echo "Archive was not downloaded to $ARCHIVE_PATH."
    exit 1
fi

# Check if the extraction directory exists
if [[ ! -d $EXTRACT_DIR ]]; then
    echo "Extraction directory $EXTRACT_DIR does not exist."
    exit 1
fi

# Check if the archive was extracted
if ! (tar tf $ARCHIVE_PATH >/dev/null 2>&1); then
    echo "Archive at $ARCHIVE_PATH is not a valid .tgz file or was not extracted correctly."
    exit 1
fi

echo "All checks passed. The task has been completed successfully!"
exit 0
