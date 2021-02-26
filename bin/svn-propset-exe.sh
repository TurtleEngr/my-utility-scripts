#!/bin/bash
# Set keywords and native properties on the list of files

svn propset svn:eol-style native $*
svn propset svn:executable 1 $*
