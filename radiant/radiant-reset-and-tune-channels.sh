#! /bin/sh 
mask=${1-0xffffff}

cd $HOME/radpy-cal
. env.sh 
python3 examples/i02_tune_initial.py $mask 1
