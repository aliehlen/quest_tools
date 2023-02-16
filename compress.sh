#!/bin/bash
# usage: add this script to a folder whose contents you want to compress, then run it.

for file in *
do
if [ $file != compress.sh ]; then
    echo $file
    tar -zcvf ${file}.tar.gz $file
fi
done
