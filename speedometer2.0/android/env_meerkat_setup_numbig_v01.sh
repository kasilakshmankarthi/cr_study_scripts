#!/sbin/sush

testCPUFreq=2100000
testMIFFreq=2100000
#Little cores 1,2,3 are turned off
lcEnd=3
#Big cores 5,6,7 are turned off
bcStart=5

#Cores 0 to 3 are little cores
#Cores 4 to 7 are big cores

#echo $testMIFFreq > /sys/class/devfreq/17000010.devfreq_mif/scaling_devfreq_min
#echo -n "MIF set to: "
#cat /sys/class/devfreq/17000010.devfreq_mif/scaling_devfreq_min
#for i in 0 1 2 3
#do
    #for j in 1 2 3 4 5 6 7
    #do
       #echo 110000 > /sys/class/thermal/thermal_zone$i/trip_point_$j\_temp
    #done
#done

#for i in 0 1 2 3
#do
    #for j in 1 2 3 4 5 6 7
    #do
        #echo -n "Tzone"$i" trip"$j" set to:"
        #cat /sys/class/thermal/thermal_zone$i/trip_point_$j\_temp
    #done
#done

echo 0 > /sys/devices/system/cpu/cpuhotplug/enabled
echo -n "CPUhotplug is set to "
cat /sys/devices/system/cpu/cpuhotplug/enabled

#setup number of little cores
for i in $(seq 1 1 $lcEnd)
do
   echo 0 > /sys/devices/system/cpu/cpu$i/online
   echo -n "Core"$i" online is set to "
   cat /sys/devices/system/cpu/cpu$i/online

   #Disable cstate (works only for online cores)
   echo 0 > /sys/devices/system/cpu/cpu$i/cpuidle/state0/disable
   echo 0 > /sys/devices/system/cpu/cpu$i/cpuidle/state1/disable
   cat /sys/devices/system/cpu/cpu$i/cpuidle/state0/disable
   cat /sys/devices/system/cpu/cpu$i/cpuidle/state0/disable
done

#setup number of big cores
for i in $(seq $bcStart 1 7)
do
   echo 0 > /sys/devices/system/cpu/cpu$i/online
   echo -n "Core"$i" online is set to "
   cat /sys/devices/system/cpu/cpu$i/online

   #Disable cstate (works only for online cores)
   echo 0 > /sys/devices/system/cpu/cpu$i/cpuidle/state0/disable
   echo 0 > /sys/devices/system/cpu/cpu$i/cpuidle/state1/disable
   cat /sys/devices/system/cpu/cpu$i/cpuidle/state0/disable
   cat /sys/devices/system/cpu/cpu$i/cpuidle/state0/disable
done

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

#Disable DTM
for i in $(seq 0 1 2)
do
    echo disabled > /sys/class/thermal/thermal_zone$i/mode
    cat /sys/class/thermal/thermal_zone$i/mode
done
