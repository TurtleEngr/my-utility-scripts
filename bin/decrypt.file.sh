#!/bin/bash
# Decrypt the list of files.

echo "gpg --decrypt-files $*"
gpg --decrypt-files $*
