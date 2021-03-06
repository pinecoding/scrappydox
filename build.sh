#!/bin/bash

# 
# build.sh - runs scrappydox with pandoc
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

if [ $# -ne 0 ]; then
    files=( "$@" )
else
    files=(*.txt)
fi
rootfile=${files[0]}
noextname=`echo $rootfile | sed -e 's/[.][^.]*$//'`
basename=`echo $rootfile | sed -e 's/^.*[+]//' -e 's/~.*$//' -e 's/[.][^.]*$//'`
title=${basename//_/ }
#echo "${files[@]}"
#echo "$basename"
#exit
if [ -e "$noextname.head" ]; then
    head="--include-in-header=$noextname.head"
else
    head=""
fi
perl scrappydox.pl "${files[@]}" >$basename.md
pandoc --standalone --self-contained $head \
    --title-prefix="$title" \
    $basename.md >$basename.html
