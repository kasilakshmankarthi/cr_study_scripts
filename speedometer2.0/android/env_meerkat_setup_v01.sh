#!/sbin/sush

testCPUFreq=$1
testMIFFreq=$2

echo $testMIFFreq > /sys/class/devfreq/17000010.devfreq_mif/scaling_devfreq_min
echo -n "MIF set to: "
cat /sys/class/devfreq/17000010.devfreq_mif/scaling_devfreq_min
for i in 0 1 2 3 ; do
        for j in 1 2 3 4 5 6 7; do
                echo 110000 > /sys/class/thermal/thermal_zone$i/trip_point_$j\_temp; done
                done;

for i in 0 1 2 3 ; do
        for j in 1 2 3 4 5 6 7; do
                echo -n "Tzone"$i" trip"$j" set to:"
                cat /sys/class/thermal/thermal_zone$i/trip_point_$j\_temp; done
                done;

echo 0 > /sys/devices/system/cpu/cpuhotplug/enabled
echo -n "CPUhotplug is set to "
cat /sys/devices/system/cpu/cpuhotplug/enabled

for i in 5 6 7; do
        echo 0 > /sys/devices/system/cpu/cpu$i/online;
        echo -n "Core"$i" online is set to "
        cat /sys/devices/system/cpu/cpu$i/online;done
		
f_set=$testCPUFreq
echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
echo -n "Big core max freq set to "
cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
echo -n "Big core min freq set to "
cat /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
echo -n "Big core cur freq "