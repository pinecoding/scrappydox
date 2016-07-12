#!/bin/bash

# 
# install.sh - install scrappydox and sdpd to usr/local/bin
#
#   scrappydox.pl installs to /usr/local/bin/scrappydox
#
#   build.sh installs to /usr/local/bin/sdpd
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

cp scrappydox.pl /usr/local/bin/scrappydox
chmod +x /usr/local/bin/scrappydox
sed '/perl scrappydox.pl/s/perl scrappydox.pl/scrappydox/' build.sh >/usr/local/bin/sdpd
chmod +x /usr/local/bin/sdpd
cp sdssclean.ps1 /usr/local/bin/
cp sdssclean.sh /usr/local/bin/sdssclean
chmod +x /usr/local/bin/sdssclean
cp sdsstable.ps1 /usr/local/bin/
cp sdsstable.sh /usr/local/bin/sdsstable
chmod +x /usr/local/bin/sdsstable

