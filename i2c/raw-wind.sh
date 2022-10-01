#! /bin/bash

finaldir=/data/windmon/raw

#number of samples per measurement (max 4096) 
nsamp_per_meas=100
#delay between BEGINNING of measurements (if less then time to record measurement, effectively 0) 
delay=0.05
#number of measurements 
nmeas=50
#time between measurements
sleep_amt=60


while true ; 
do

  outname=/tmp/windmon.`date -Is`.log

  #Loop over a file (approx an hour) 
  for n in {1..60} 
  do
    #loop over the i2c addresses
    for addr in 48 4e
    do
      /rno-g/bin/wind-adc-helper -b 2 -a 0x$addr -s $nsamp_per_meas -d $delay -m $nmeas >> $outname 
    done
    sleep $sleep_amt
  done
  xz $outname && mv $outname.xz $finaldir
done

