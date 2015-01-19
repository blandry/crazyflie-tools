drake-crazyflie-tools
=====================

A collection of tools to develop controllers for the Crazyflie using Drake

Installation
============
* install the lcm types
    
    cd lcm
    sudo python setup.py install

* install the client
    
    cd crazyflie-clients-python
    sudo bash setup.sh

* flash the firmware
    
    cd crazyflie-firmware
    make cload

* install vicon
    
    cd vicon
    cp lib/libViconDataStreamSDK_CPP.so /usr/lib/libViconDataStreamSDK_CPP.so
    make

Main Usage
=====
* run the vicon client to get sensor data

    vicon/bin/viocn_lcm_client <object_name>

* run the craziflie client, and switch to lcm mode if needed

    crazyflie-clients-python/bin/cfclient

* You can send lcm commands from the nanokontrol board

    client/bin/nanokontrol


Other Usage
===========
* You can also use drake to send these commands ("crazyflie_input" channel)
* You can log the vicon data using lcm-logger

LCM Types
=========
You can regenerate the lcm types if you have lcm installed.
* Install LCM (lcm-gen)
* add lcm.jar to CLASSPATH
* run lcm/make_types

Handling Logs
=============
How to use LCM logging with MATLAB:
* Take your logs.  On a computer that is recieveing the relavent LCM messages, run

    $ lcm-logger

in the directory you want your log files.  This will produce a file that contains all your LCM messages.
* Export to .mat format

    $ python log_to_mat.py -f -l <lcm types>,<another lcm type> <lcm log file>
