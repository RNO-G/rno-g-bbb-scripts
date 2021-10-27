#! /usr/bin/env python3

# This continually checks for the LTE modem and 

#TODO rewrite in C or maybe bash if we need the free memory 
#    Note: this uses ~7 MB of RAM in python, plus ~2 MB transiently to run ping.  


# Cosmin Deaconu <cozzyd@kicp.uchicago.edu> 

import serial 
import sys 
import os 
import re 
import time
import signal 
import subprocess 
import sdnotify 

#this doesn't seem to help... 
import gc 



acm = None 
host = "10.1.0.1"
ping_count = 5 
check_serial_sleep_amt = 60 
check_connection_sleep_amt = 30 
interrupt_flag = False 
moni_file = open("/data/lte.log","a"); 



notifier = sdnotify.SystemdNotifier() 

# read a line and convert it to a string
def rl(): 
    r = acm.readline().decode("utf-8") 
#    print(r) 
    return r

def moni():  
    acm.write("AT#MONI\r\n".encode("utf-8")); 
    res = "None\r\n"
    line = None
    while line != "OK\r\n": 
        line = rl(); 
        if line.startswith("#MONI"):
            res = line
    moni_file.write(str(time.time())+":"+res); 
    moni_file.flush() 

def interruptible_sleep(t, max_sleep =1): 
    global interrupt_flag 
    desired_end = time.time()+t; 
    while not interrupt_flag: 
        left = desired_end-time.time() 
        if left <= 0:
            break 
        sleep_amt = left if left < max_sleep else max_sleep 
        time.sleep(sleep_amt) 
        
    #reset the interrupt
    interrupt_flag = False 

# write a line, eat the echoed and blank line 
def wl(text):
    acm.write(text.encode("utf-8"))
    rl() #echoed line
    rl() #blank line 

def check_ok(cmd, throw_exception = True):
    wl(cmd)
    r = rl(); 
    if  r!= 'OK\r\n':
        if throw_exception: 
            raise IOError("did not get an ok from " + cmd + " , got: "+r)
        print ("did not get an ok from " + cmd +"+ , got: "+r)
        return 1
    return 0 

def receive_signal(signum, stack): 
    global interrupt_flag
    print('received ',signum) 
    interrupt_flag = True


def check_serial(): 
    return os.path.exists("/dev/ttyLTE")

def run(cmd): 
    print(cmd) 
    os.system(cmd) 


def wwan0_up(): 
    with open("/sys/class/net/wwan0/operstate") as f: 
        state = f.readline(); 
        print("wwan0 is " + state); 
        return state == "up\n" 


def check_connection(): 

    if not wwan0_up(): 
        return 1

    #ping 
    return subprocess.call(["ping","-c", str(ping_count),"-n","-q", host])



def open_serial(): 
    global acm 
    acm = serial.Serial("/dev/ttyLTE",115200,timeout=1, write_timeout=1)   

def try_to_connect(): 


    #flush a line 
    wl('\r\n') 
    acm.flush() 

    # Check for ok 
    if (check_ok("AT\r\n")): 
        return 1 

    wl('AT#RFSTS\r\n'); 
    rfsts = rl() 
    print(rfsts); 
    rl() #blank line
    rl() #ok line

    # Get the ip address 
    wl('AT+CGPADDR=1\r\n') 
    addrline = rl() 
    rl() # blank line 
    rl() # ok line 
    
    print(addrline) 
    match = re.search('\+CGPADDR: 1,\"(\S+)\"',addrline)
    print(match) 
    if match == None or len(match.groups()) < 1: 
        print ("Didn't get an IP?")
        return 2

    addr = match.groups()[0] 
    print("IP address is %s" %(addr))

    #Now let's set up the modem properly 
    if (check_ok('AT#NCM=1,1\r\n')): return 1
    wl('AT+CGDATA="M-RAW_IP",1\r\n') 

    #Wait for either a connect or error 
    while True: 
        text = rl() 
        if text =='CONNECT\r\n':
            print("Connected!\n") 
            break
        if text =='ERROR\r\n': 
            print("Didn't connect :(")
            return 3 

    if wwan0_up(): 
        run("ifconfig wwan0 down")

    run("ip addr flush dev wwan0") 

    #set up the connection 
    run("ifconfig wwan0 %s netmask 255.0.0.0 up" % (addr))
    time.sleep(1) 

    #set up the routes
    run("ip route add 10.2.0.0/24 via 10.2.0.1"); 

    run("ip route add default via 10.2.0.1"); 
    run('echo "nameserver 8.8.8.8" > /etc/resolv.conf')
    time.sleep(10) 
    return  0

def reboot_modem_via_uc(): 
    print ("COMMENTED OUT Trying to restart modem via micro") 
    time.sleep(1)
#    os.system('echo "#LTE-OFF" > /dev/ttyController') 
    time.sleep(5)
#    os.system('echo "#LTE-ON" > /dev/ttyController') 
    time.sleep(15)

def reboot_modem(): 
    print ("COMMENTED OUT Trying to restart modem directly") 
    #return check_ok("AT#ENHRST=1,0",False)  #reboot router 


if __name__=="__main__": 

    signal.signal(signal.SIGUSR1,receive_signal) 

    time.sleep(5) #wait five seconds to avoid dying too quickly
    print("Started!"); 

    while True: 
        print("Kicking watchdog"); 
        notifier.notify("WATCHDOG=1") 

        if not check_serial(): 
            if acm is not None: 
                acm.close() 
                acm = None 
            reboot_modem_via_uc() 
            interruptible_sleep(check_serial_sleep_amt) 
        else:  
            if acm is None:
               try: 
                   print("Opening serial") 
                   open_serial()
                   time.sleep(3) 
                   check_ok("AT\r\n") 
                   time.sleep(1) 
               except IOError: 
                   print("error while reading serial") 
                   reboot_modem_via_uc(); 
                   acm = None 
               time.sleep(5) 
               continue

            moni() 
            if not check_connection(): 
                interruptible_sleep(check_connection_sleep_amt) 
            else: 

                print("Connection check failed") 
                time.sleep(5) 
                success= False; 
                for i in range(5): 
                    if not check_connection(): 
                        print("Connection check is actually ok") 
                        success = True
                    else: 
                        success = not try_to_connect() 
                    if success: 
                        time.sleep(5) 
                        break 
                    interruptible_sleep(30); 
                if not success: 
                    check_ok("AT+COPS=0\r\n") #make sure automatic network selection 
                    time.sleep(5) 
                    reboot_modem() 
                    acm.close() 
                    acm = None
                    time.sleep(20) 


        gc.collect() 











