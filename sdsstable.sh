#!/bin/bash

# 
# sdsstable.sh - runs sdsstable.ps1 PowerShell script
# 
# Copyright (c) 2016 Sam Gabriel
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

syntax () {
    echo "$0 file [sheet] [class] [--markup] [--sort]" 1>&2
    exit 1
}

if [ $# -lt 1 ] || [ $# -gt 4 ]; then
    syntax
fi
file=""
sheet=1
class=""
sort=""
position=0
for arg in "$@"; do
    case $arg in
        -s|--sort)
            sort="-sort"
            ;;
        -m|--markup)
            markup="-markup"
            ;;
        *)
            case $position in
                0)
                    file="$arg"
                    ;;
                1)
                    sheet="$arg"
                    ;;
                2)
                    class="$arg"
                    ;;
                *)
                    syntax
                    ;;
            esac
            ((position++))
            ;;
    esac
done
if [ -z "$file" ]; then
    syntax
fi
scriptdir="`dirname $0`"
psfile="$scriptdir/sdsstable.ps1"
wpsfile="`cygpath -w $psfile`"
wfile="`cygpath -w $file`"
#echo "file: $file" 1>&2
#echo "sheet: $sheet" 1>&2
#echo "class: $class" 1>&2
#echo "sort: $sort" 1>&2
#exit 1
powershell -NoProfile -ExecutionPolicy Bypass -file "$wpsfile" "$wfile" "$sheet" "$class" "$markup" "$sort" 
