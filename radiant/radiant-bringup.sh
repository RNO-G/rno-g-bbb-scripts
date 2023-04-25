#! /bin/bash 



echo "Turning off RADIANT... (if it's on)"
echo "#RADIANT-OFF" > /dev/ttyController
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

echo "attempting tuning" 

mask="0xffffff"
rst=0
for round in {1..12} ; 
do 
  echo "Round $round" 

  python3 examples/i02_tune_initial.py $mask $rst 
  mask=`cat /tmp/radiant-fail-mask` || `echo 0xffffff`
  echo mask is $mask 
  if [[ "$mask" -eq "0x0" ]] ; then 
    echo "Great Success!"
    #todo, verify 
    break; 
  else
    rst=$(( ($i % 4) > 0 ))
    echo reset is $rst 
  fi 
done

if [[ "$mask" -ne 0x0 ]]  ; 
then 
 echo "Not all channels tuned. Mask of shame is $mask " 
 exit 1; 
fi 
 


python3 examples/i03_calib_isels.py 

examples/radsig-cli --on --freq 99 --band 0 
python3 examples/cal_select.py 0

cd $HOME/librno-g 
. env.sh 
make daq-test-progs 
mdy=`date +%m%d%y` 
suffix=0 
lbl=$mdy.$suffix-cal0 

while [ -d $lbl ] ; 
do 
  echo $lbl already used, incrementing 
  let "suffix+=1"
  lbl=$mdy$suffix-cal0 
done

radiant-try-event -f -L $lbl 


cd $HOME/radpy-cal
python3 examples/cal_select.py 1

cd $HOME/librno-g 
lbl=$mdy.$suffix-cal1 
radiant-try-event -f -L $lbl 

cd $HOME/radpy-cal
python3 examples/cal_select.py 2

cd $HOME/librno-g 
lbl=$mdy.$suffix-cal2 
radiant-try-event -f -L $lbl 


cd $HOME/radpy-cal
python3 examples/cal_select.py 
examples/radsig-cli --off









