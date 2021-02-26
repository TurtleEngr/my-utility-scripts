#!/bin/bash
# Decrypt one file, and send the output to stdout.
# No need to cleanup and the screen is cleared after pressing enter.

echo "gpg --decrypt $1"
gpg --decrypt $1

echo "Press enter when done..."
read
clear
