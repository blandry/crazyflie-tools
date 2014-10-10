#!/bin/bash

echo "export PYTHONPATH=\$PYTHONPATH:${PWD}/crazyflie_t" >> ~/.bashrc
echo "export CLASSPATH=\$CLASSPATH:${PWD}/crazyflie_t.jar" >> ~/.bashrc
source ~/.bashrc
