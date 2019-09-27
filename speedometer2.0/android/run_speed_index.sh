#!/usr/bin/bash
export PATH=$PATH:/data/local/tmp

DIR=$PWD
optional_url="http://localhost:8080/InteractiveRunner.html"
#optional_url="http://172.31.200.115:8080/InteractiveRunner.html"
time=$(date)
freq_in_stat="freq_in_stat_$(echo $time | sed 's/[ :]/-/g').log"

#Core setup script
setup_env="$1"
#Taskset the application in this core
pcore=$2
#Not used now
ncore=$3
#browser type
browser_type=$4

cd $DIR
sh -x $setup_env

#To show the ncores online
for i in $(seq 0 1 7)
do
    cat /sys/devices/system/cpu/cpu$i/online >> $freq_in_stat
done

#echo "--- Speedometer Test Starts ----" >> $freq_in_stat
#echo "-- policy0 little cores --" >> $freq_in_stat
#cat /sys/devices/system/cpu/cpufreq/policy0/stats/time_in_state >> $freq_in_stat
#echo "-- policy4 big cores --" >> $freq_in_stat
#cat /sys/devices/system/cpu/cpufreq/policy4/stats/time_in_state >> $freq_in_stat

if [ "${browser_type}" == "chrome" ]; then
   am force-stop com.android.chrome
   sleep 2
   busybox-spa taskset 0x10 am start -a android.intent.action.VIEW -n com.android.chrome/com.google.android.apps.chrome.Main ${optional_url:+-d "$optional_url"}
elif [ "${browser_type}" == "chromium" ]; then
   am force-stop org.chromium.chrome
   sleep 2
   busybox-spa taskset 0x10 am start -a android.intent.action.VIEW -n org.chromium.chrome/com.google.android.apps.chrome.Main ${optional_url:+-d "$optional_url"}
else
   am force-stop org.chromium.content_shell_apk
   sleep 2
   busybox-spa taskset 0x10 am start -a android.intent.action.VIEW -n org.chromium.content_shell_apk/.ContentShellActivity ${optional_url:+-d "$optional_url"}
fi



#echo "Launched apk with URL = $optional_url" >> $freq_in_stat
#sleep $3
#F_SCORE="$DIR/score_$(date +%y%m%d_%H%M%S).png"
#screencap -p $F_SCORE
#echo "   Score report screen captured ..... $F_SCORE"
#echo "Running profile instances = $(pidof dd)"

#echo "--- Speedometer Test DONE! ----" >> $freq_in_stat
#echo "-- policy0 little cores --" >> $freq_in_stat
#cat /sys/devices/system/cpu/cpufreq/policy0/stats/time_in_state >> $freq_in_stat
#echo "-- policy4 big cores --" >> $freq_in_stat
#cat /sys/devices/system/cpu/cpufreq/policy4/stats/time_in_state >> $freq_in_stat

#for i in $(seq 0 1 7)
#do
    #cat /sys/devices/system/cpu/cpu$i/online >> $freq_in_stat
#done

#cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq >> $freq_in_stat
#cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq >> $freq_in_stat
#cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_cur_freq >> $freq_in_stat
#echo "Done the benchmark test"
