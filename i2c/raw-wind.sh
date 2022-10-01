#! /bin/bash

finaldir=/data/windmon/raw
while true ; 
do

  outname=/tmp/windmon.`date -Is`.log

  #Loop over a file (approx an hour) 
  for n in {1..60} 
  do
    #loop over the i2c addresses
    for addr in 48 4e
    do
      /rno-g/bin/wind-adc-helper -b 2 -a 0x$addr -s 100 -d 0.01 -m 50 >> $outname 
    done
    sleep 60
  done
  xz $outname && mv $outname.xz $finaldir
done

