DIR=/sarc/spa/users/kasi.a/cr_tip/
optional_url='http://localhost:8082/index_logcat.html'
iters=1
base_count=0
tot_count=${iters}

func_setup_perf() {
 adb shell setprop security.perf_harden 0
 adb shell setprop debug.generate-debug-info true
 adb shell cmd package compile -f -m speed org.chromium.content_shell_apk

 #adb push ${DIR}/chromium/src/third_party/android_ndk/simpleperf/bin/android/arm64/simpleperf /data/local/tmp
}

func_setupLogcat(){
  local suite=$1
  local test=$2

  if [ -f /tmp/logcat_hw.${suite}.${test}.txt ]
  then
      rm -rf /tmp/logcat_hw.${suite}.${test}.txt
  fi
  # Launch new logcat
  adb shell logcat -c
  adb shell logcat chromium:I *:S > /tmp/logcat_hw.${suite}.${test}.txt &
  echo "   Logcat setup done ..........................."
}

func_detect_start(){
   local suite=$1
   local test=$2
   local base_count=$3
   local tot_count=$4

   MAGIC_MSG="spa_started_trace";
   test_starting=${base_count}
   test_starting_curr=${base_count}
   test_count=$(($test_starting_curr-$test_starting))
   while [ "$test_count" != ${tot_count} ]
   do
      sleep 1
      test_starting_curr=$(grep $MAGIC_MSG /tmp/logcat_hw.${suite}.${test}.txt | wc -l)
      test_count=$(($test_starting_curr-$test_starting))
   done
   echo "   spa_started_trace string Detected"
   return
}

func_detect_completion(){
   local suite=$1
   local test=$2
   local base_count=$3
   local tot_count=$4
   if [[ ${test} == "All" ]];then
     tm=10
   elif  [[ ${test} == "Sub" ]];then
     tm=3
   else
     tm=1
   fi

   MAGIC_MSG="spa_stopped_trace";
   test_completed=${base_count}
   test_completed_curr=${base_count}
   test_count=$(($test_completed_curr-$test_completed))
   while [ "$test_count" != ${tot_count} ]
   do
      sleep ${tm}
      test_completed_curr=$(grep $MAGIC_MSG /tmp/logcat_hw.${suite}.${test}.txt | wc -l)
      test_count=$(($test_completed_curr-$test_completed))
   done
   echo "   spa_stopped_trace string Detected"
   return
}

suites=(
    "VanillaJS-TodoMVC"
    "Vanilla-ES2015-TodoMVC"
    "Vanilla-ES2015-Babel-Webpack-TodoMVC"
    "React-TodoMVC"
    "React-Redux-TodoMVC"
    "EmberJS-TodoMVC"
    "EmberJS-Debug-TodoMVC"
    "BackboneJS-TodoMVC"
    "AngularJS-TodoMVC"
    "Angular2-Typescript-TodoMVC"
    "VueJS-TodoMVC"
    "jQuery-TodoMVC"
    "Preact-TodoMVC"
    "Inferno-TodoMVC"
    "Elm-TodoMVC"
    "Flight-TodoMVC"
    "All"
)

tests=(
    "Adding"
    "Completing"
    "Deleting"
    "All"
)
#tests=("Sub")

###Run only once
#func_setup_perf

for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    if [ "${suite}" == "All" ] && [ "${test}" != "All" ]; then
     continue;
    fi
    if [ "${suite}" != "All" ] && [ "${test}" == "All" ]; then
     continue;
    fi

    adb shell am start -a android.intent.action.VIEW -n org.chromium.content_shell_apk/.ContentShellActivity -d "$optional_url"

    ###Takes time for the PIDs to get created
    func_setupLogcat ${suite} ${test}

    #adb shell su -c /data/local/tmp/simpleperf record -o /sdcard/perf.${suite}.${test}.data -e task-clock:u -f 1000 --app org.chromium.content_shell_apk
    PID=$((adb shell "ps -A | grep org.chromium.content_shell_apk:sandboxed_process*") | awk '{print $2}')
    #TID=$((adb shell "ps -AT -o TID,NAME,CMD,CPU | grep CrRendererMain") | awk '{print $1}')

    adb shell input keyevent input TAB
    adb shell input keyevent input TAB
    adb shell input keyevent ENTER
    adb shell input text ${suite}
    adb shell input keyevent adb shell input TAB
    adb shell input text ${test}
    adb shell input keyevent adb shell input TAB
    adb shell input text ${iters}
    adb shell input keyevent adb shell input TAB

    adb shell "su -c /data/local/tmp/simpleperf record -o /sdcard/perf.${suite}.${test}.data -e task-clock:u -f 1000 -p ${PID} --duration 50 &"
    pperf=$(adb shell pidof /data/local/tmp/simpleperf)

    adb shell input keyevent ENTER

    echo "   Running ..................................."
    PID=$((adb shell "ps -A | grep org.chromium.content_shell_apk:sandboxed_process*") | awk '{print $2}')

    func_detect_completion ${suite} ${test} ${base_count} ${tot_count}

    #adb shell am force-stop org.chromium.content_shell_apk

    pperf=$(adb shell pidof simpleperf)
    adb shell "su -c kill -9 ${pperf}"

    adb shell am force-stop org.chromium.content_shell_apk

  done
done


