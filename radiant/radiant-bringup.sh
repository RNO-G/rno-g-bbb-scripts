#! /bin/bash 


startdir=`pwd`
failable_mask=${1-0x0}

echo "Failable mask is $failable_mask"


echo "Turning off RADIANT... (if it's on)"
echo "#RADIANT-OFF" > /dev/ttyController
sleep 3

echo "Turning off amplifiers... (if they're on)"
echo "#AMPS-SET 0 0" > /dev/ttyController
sleep 3



echo "Turning on RADIANT"
echo "#RADIANT-ON" > /dev/ttyController 
sleep 1


cd $HOME/radpy-cal 

echo `pwd` 
. env.sh 

identified=0
sleep 2



for i in {1..3} ; do 
  if timeout 5 python3 examples/radidentify.py  ; 
  then 
    echo "Succesful identification" 
    identified=1
    break 
  else 
    echo "Identification failed, MCU restart $i/3"
    /rno-g/bin/reset-radiant-mcu 
    sleep 3
  fi
done 

if [[ $identified -eq 0 ]] ; 
then 
  echo "RADIANT couldn't identify. Bailing" 
  exit 1; 
fi 


echo "Switching to upgrade firmware" 
python3 examples/radiant_to_upgrade.py  || exit 1 


sleep 3 
echo "Running setup" 

python3 examples/i01_setup_radiant.py 


echo  pretuning run with amps off 

cd $HOME/librno-g 
. env.sh 
make daq-test-progs 
mdy=`date +%m%d%y` 
suffix=0 
lbl=$mdy.$suffix-pre 

while [ -d /data/test/$lbl ] ; 
do 
  echo $lbl already used, incrementing 
  let "suffix+=1"
  lbl=$mdy.$suffix-pre
done

radiant-try-event -f -L $lbl &> /tmp/radiant-pre.log


cd $HOME/radpy-cal

echo "attempting tuning" 

mask="0xffffff"
rst=0
for round in {1..24} ; 
do 
  echo "Round $round" 

  python3 examples/i02_tune_initial.py $mask $rst 
  mask=`cat /tmp/radiant-fail-mask` || `echo 0xffffff`
  echo mask is $mask 
  echo $(( $mask & ~$failable_mask )) 
if [ $(( $mask & ~$failable_mask )) -eq 0 ] ; then
    echo "Great Success!"
    #todo, verify 
    break; 
  else
    sleep 10 # seems like backing off may help?
    rst=$(( ($i % 6) == 0 && $i > 0 ))
    echo reset is $rst 
  fi 
done

if [ $(( $mask & ~$failable_mask )) -eq 0 ] ; then
echo "passed with mask $mask" ;
 else 
 echo "Not all channels tuned. Mask of shame is $mask " 
 exit 1; 
fi 
 


python3 examples/i03_calib_isels.py 

cd $HOME/librno-g 
lbl=$mdy.$suffix-post 
radiant-try-event -f -L $lbl  &> /tmp/radiant-post.log

./radiant-check-cal.sh $mdy.$suffix  &> /tmp/radiant-check-cal.log

echo "Turning on amps" 
echo "#AMPS-SET 3f 7" > /dev/ttyController

cd $HOME/librno-g 
lbl=$mdy.$suffix-force 
radiant-try-event -f -L $lbl -N 500  &> /tmp/radiant-force.log



#if we are on the RNO-G LTE network, copy to server
if ip addr | grep 10.3.0. ; 
then 
  cd $startdir
  for i in pre post cal0 cal1 cal2 force ; do 
    ./radiant-copy-to-server.sh $mdy.$suffix-$i 
  done
  echo "Check rno-g-server:~rno-g/$hostname/$mdy.$suffix-*"
fi 



