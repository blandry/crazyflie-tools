drake-crazyflie-tools
=====================

A collection of tools to develop controllers for the Crazyflie using Drake

Installation
============
* install the lcm types
```    
    cd lcm
    sudo python setup.py install
```

* install the client
```    
    cd crazyflie-clients-python
    sudo bash setup.sh
```

* flash the firmware
```    
    cd crazyflie-firmware-2
    make cload
```

* install vicon
```    
    cd vicon
    cp lib/libViconDataStreamSDK_CPP.so /usr/lib/libViconDataStreamSDK_CPP.so
    make
```

Main Usage
=====
* run the vicon client to get sensor data
```
    vicon/bin/vicon_lcm_client objectname
```

* run the crazyflie client
```
    ./simpleclient
```

* You can send lcm commands from the nanokontrol board
```
    ./nanokontrol
```

* You can also use drake to send commands ("crazyflie_input" channel), and therefore build pretty sophisticated controllers. See Drake's documentation for more details.

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

```
    $ lcm-logger
```

in the directory you want your log files.  This will produce a file that contains all your LCM messages.
* Export to .mat format
```
    $ python log_to_mat.py -f -l lcmtypesmodule,anotherlcmtypemodule lcmlogfile
```

Running the visualizer
======================
After running ``make -j`` in the drake-distro/director folder:

```
drake-distro/build/bin/ddConsoleApp -m crazyflieviewer
```
you can play a log back
```
lcm-logplayer -s .5 lcmlog-2015-04-02.00
```
and visualize it in matlab 
```
addpath_crazyflie
cf=Crazyflie()
cf.visualizeStateEstimates()
```
