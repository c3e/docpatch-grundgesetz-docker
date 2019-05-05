#!/bin/bash
cd /pandoc
download=$(curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | grep 'browser_' | cut -d\" -f4 |grep deb); \
wget $download
apt install ./*.deb
pandoc --version

