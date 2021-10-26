#!/bin/bash
# Reset USB ports (so printrun can connect)
# run as root

modprobe -r ftdi_sio
modprobe -r usbserial

modprobe ftdi_sio
modprobe usbserial
