#! /bin/bash

finaldir=/data/windmon/raw
while true ; 
do

  outname=/tmp/windmon.`date -Is`.log

  #Loop over a file (approx an hour) 
  for n in {1..60} 
  do
    #loop over the i2c addresses
    for addr in 48 4f
    do

      #start a measurement
      echo START 0x$addr >> $outname

      #50 100 sample measurements, 0.01 seconds apart 
      for i in {1..50} ; 
      do
        echo $i  >> $outname
        date +%s.%N >> $outname
        i2ctransfer -y 2 r200@0x$addr >> $outname
        date +%s.%N >> $outname
        sleep 0.01
      done

      echo END  0x$addr>> $outname
    done
    sleep 60
  done
  xz $outname && mv $outname.xz $finaldir
done

