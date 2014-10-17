drake-crazyflie-tools
=====================

A collection of tools to develop controllers for the Crazyflie using Drake

Installation
============
* Install drake (use releases should be automated)
* Install the lcm (lcm/install_types.sh should be automated)
* Install dev libs for crazyflie firmware (should be automated)
* Install the crazyflie client libs (should be automated)

LCM Types
=========
You can regenerate the lcm types if you have lcm installed.
* Install LCM (lcm-gen)
* add lcm.jar to CLASSPATH
* run lcm/make_types

UTILS
=====
How to use LCM logging with MATLAB:

1) Take your logs.  On a computer that is recieveing the relavent LCM messages, run

------------------------------
$ lcm-logger
------------------------------
in the directory you want your log files.  This will produce a file that contains all your LCM messages.


2) Create python LCM types

First, you must set your PYTHONPATH to contain the path with your compiled LCM types.  To compile your LCM types for python, run

------------------------------
$ lcm-gen -p <your-file>.lcm
------------------------------

this will produce a .py file that contains your LCM type.  You need to do this for every LCM type that you have.

3) Add types to your python path

------------------------------
$ export PYTHONPATH=$PYTHONPATH:<location of your LCM .py type files>
------------------------------

4) Export to .mat format

Run

------------------------------
$ python log_to_mat.py -f -l <lcm types>,<another lcm type> <lcm log file>
------------------------------

so for a file called lcmlog-2010-09.02 that contains two LCM types (lcmt_glider_optotrak and lcmt_hotrod_u), we run:

$ python log_to_mat.py -f -l vicon_t <your log file>

INSTALLING THE LIB
==================
cd client
sudo setup.py
