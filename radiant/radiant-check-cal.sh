#! /bin/bash
prefix=${1-`date -Is`}
do_copy=${2-0}
echo prefix=$prefix
echo do_copy=$do_copy

cd $HOME/radpy-cal
. env.sh 
examples/radsig-cli --on --freq 99 --band 0 
python3 examples/cal_select.py 0

cd $HOME/librno-g 
lbl=$prefix-cal0 
radiant-try-event -f -L $lbl 


cd $HOME/radpy-cal
python3 examples/cal_select.py 1

cd $HOME/librno-g 
lbl=$prefix-cal1 
radiant-try-event -f -L $lbl 

cd $HOME/radpy-cal
python3 examples/cal_select.py 2

cd $HOME/librno-g 
lbl=$prefix-cal2 
radiant-try-event -f -L $lbl 

cd $HOME/radpy-cal
python3 examples/cal_select.py 
examples/radsig-cli --off


if [[ $do_copy -eq 1 ]] ; 
then
  cd $HOME/rno-g-BBB-scripts/radiant
  ./radiant-copy-to-server.sh $prefix-cal0
  ./radiant-copy-to-server.sh $prefix-cal1
  ./radiant-copy-to-server.sh $prefix-cal2
fi 


