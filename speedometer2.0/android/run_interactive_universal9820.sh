#!/bin/sh

echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor
echo performance > /sys/devices/system/cpu/cpufreq/policy6/scaling_governor

echo disabled > /sys/class/thermal/thermal_zone0/mode
echo disabled > /sys/class/thermal/thermal_zone1/mode
echo disabled > /sys/class/thermal/thermal_zone2/mode

####Turn off the big core to avoid OCP throttling
echo "0" > /sys/devices/system/cpu/cpu6/online
echo "Turned off cpu6"

####Start contentshell (Test2)
optional_url="http://localhost:8080/InteractiveRunner.html"
am start -a android.intent.action.VIEW -n org.chromium.content_shell_apk/.ContentShellActivity -d "$optional_url"
echo "Launched Chrome with URL = $optional_url"
sleep 5

#####Extract the TID of CrRenderedMain and taskset to big cpu7
THREAD=$(ps -AT -o TID,NAME,CMD,CPU | grep -i "CrRendererMain*" | awk '{print $1}')
/system/bin/taskset -p 80 ${THREAD}
echo "taskset CrRendererMain to run in cpu7"
