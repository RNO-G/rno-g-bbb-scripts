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

mask=0xffffff
rst=0
for round in {1..12} ; 
do 
  echo "Round $round" 

  python3 examples/i02_tune_initial.py $mask $rst 
  mask=printf "0x%x" $? 
  echo mask is $mask 
  if [[ $mask -eq 0x0 ]] ; then 
    echo "Great Success!"
    #todo, verify 
    break; 
  else
    rst=$(( ($i % 4) > 0 ))
    echo reset is $rst 
  fi 
done

if [[ $mask -ne 0x0 ]]  ; 
then 
 echo "Not all channels tuned. Mask of shame is $mask " 
 exit 1; 
fi 
 


python3 examples/i03_calib_isels.py 


cd $HOME/librno-g 
make 











