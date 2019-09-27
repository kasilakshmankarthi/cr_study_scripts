#!/bin/sh

DIR=$PWD
optional_url="http://localhost:8080/index.html"
time=$(date)
freq_in_stat="freq_in_stat_$(echo $time | sed 's/[ :]/-/g').log"
setup_env="$1"

cd $DIR
sh -x $setup_env
for i in $(seq 0 1 7); do cat /sys/devices/system/cpu/cpu$i/online >> $freq_in_stat; done

#clean up browser
am force-stop org.chromium.content_shell_apk
sleep 2

echo "--- Speedometer Test Starts ----" >> $freq_in_stat

echo "-- policy0 little cores --" >> $freq_in_stat
cat /sys/devices/system/cpu/cpufreq/policy0/stats/time_in_state >> $freq_in_stat
echo "-- policy4 big cores --" >> $freq_in_stat
cat /sys/devices/system/cpu/cpufreq/policy4/stats/time_in_state >> $freq_in_stat

/data/local/tmp/busybox-spa taskset $2 am start -a android.intent.action.VIEW -n org.chromium.content_shell_apk/.ContentShellActivity -d "$optional_url"
#######More threads are created after inserting text in address bar#######
PIDS=$(ps -A | grep content_shell_apk | /data/local/tmp/busybox-spa awk '{print $2}')
for i in $PIDS;do /system/bin/taskset -ap f0 $i;done

THREADS=$(ps -AT -o TID,NAME,CMD,CPU | grep org.chromium.content_shell_apk | /data/local/tmp/busybox-spa awk '{print $1}')
for i in $THREADS;do /system/bin/taskset -p f0 $i;done
#######################################################

echo "Launched Chrome with URL = $optional_url" >> $freq_in_stat
sleep $3
F_SCORE="$DIR/score_$(date +%y%m%d_%H%M%S).png"
screencap -p $F_SCORE
echo "   Score report screen captured ..... $F_SCORE"
echo "Running profile instances = $(pidof dd)"

echo "--- Speedometer Test DONE! ----" >> $freq_in_stat

echo "-- policy0 little cores --" >> $freq_in_stat
cat /sys/devices/system/cpu/cpufreq/policy0/stats/time_in_state >> $freq_in_stat
echo "-- policy4 big cores --" >> $freq_in_stat
cat /sys/devices/system/cpu/cpufreq/policy4/stats/time_in_state >> $freq_in_stat

for i in $(seq 0 1 7); do cat /sys/devices/system/cpu/cpu$i/online >> $freq_in_stat; done

cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq >> $freq_in_stat
cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq >> $freq_in_stat
cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_cur_freq >> $freq_in_stat
echo "Done the benchmark test"

#ps -AT -o USER,PID,TID,PPID,NAME,CMD,CPU | grep content
#top -H -O CPU
