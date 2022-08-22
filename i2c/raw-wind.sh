#! /bin/bash

finaldir=/data/windmon/raw
while true ; 
do

  outname=/tmp/windmon.`date -Is`.log

  for n in {1..60} 
  do
    echo START >> $outname

    for i in {1..50} ; 
    do
      echo $i  >> $outname
      date +%s.%N >> $outname
      i2ctransfer -y 2 r200@0x4e >> $outname
      date +%s.%N >> $outname
      sleep 0.01
    done
    echo END >> $outname
    sleep 60
  done
  xz $outname && mv $outname.xz $finaldir
done

