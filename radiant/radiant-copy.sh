#! /bin/sh

tag=${1-""} 

hostname=`hostname`
ssh -t rno-g@10.1.0.1 "cd librno-g && ./daqwebplot.sh $hostname $tag $tag"
