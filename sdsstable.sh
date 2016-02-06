#!/bin/bash

# 
# sdsstable.sh - runs sdsstable.ps1 PowerShell script
# 
# Copyright (c) 2015 Sam Gabriel
# 
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "$0 file [sheet]"
    exit 0
fi
if [ -z $2 ]; then
    sheet=1
else
    sheet="$2"
fi
scriptdir="`dirname $0`"
psfile="$scriptdir/sdsstable.ps1"
wpsfile="`cygpath -w $psfile`"
warg1="`cygpath -w $1`"
powershell -NoProfile -ExecutionPolicy Bypass -file "$wpsfile" "$warg1" "$sheet"
