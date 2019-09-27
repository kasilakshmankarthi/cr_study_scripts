#!/bin/sh

####Turn off the big core to avoid OCP throttling
echo "0" > /sys/devices/system/cpu/cpu0/online
echo "0" > /sys/devices/system/cpu/cpu1/online
echo "0" > /sys/devices/system/cpu/cpu2/online
echo "0" > /sys/devices/system/cpu/cpu3/online
echo "0" > /sys/devices/system/cpu/cpu7/online
echo "Turned off cpu7"

####Start contentshell (Test1)
optional_url="http://localhost:8080/index.html"
am start -a android.intent.action.VIEW -n org.chromium.content_shell_apk/.ContentShellActivity -d "$optional_url"
echo "Launched Chrome with URL = $optional_url"
sleep 5

#####Extract the TID of CrRenderedMain and taskset to big cpu6
THREAD=$(ps -AT -o TID,NAME,CMD,CPU | grep -i "CrRendererMain*" | awk '{print $1}')
/system/bin/taskset -p 40 ${THREAD}
echo "taskset CrRendererMain to run in cpu6"
