CHOICE=$1
echo "User entered choice (Sub/All): " ${CHOICE}
echo "Sub measures individual suite"
echo "All measures entire Speedometer2.0 suite"

ISPID=$2
echo "ISPID (=sandbox process) [or] (=0 CrRendererMain thread): " ${ISPID}

DIR=/data/local/tmp
LOGS=/sdcard/tmp

optional_url='http://localhost:8082/index_logcat.html'
iters=1
base_count=0
tot_count=${iters}

rm -rf /sdcard/tmp
mkdir -p ${LOGS}

func_setup_perf() {
 setprop security.perf_harden 0
 setprop debug.generate-debug-info true
 cmd package compile -f -m speed org.chromium.content_shell_apk

 if [[ ${ISPID} == 1 ]]; then
     rm -rf   /sdcard/record/PID/${CHOICE}
     mkdir -p /sdcard/record/PID/${CHOICE}
 else
     rm -rf   /sdcard/record/TID/${CHOICE}
     mkdir -p /sdcard/record/TID/${CHOICE}
 fi

 #adb push ${DIR}/chromium/src/third_party/android_ndk/simpleperf/bin/android/arm64/simpleperf ${DIR}
}

func_setupLogcat(){
  local suite=$1
  local test=$2

  ### Clean the exiting logcat process
  logcat -d > /dev/null 2>&1
  logcat -c

  if [ -f ${LOGS}/logcat_hw.${suite}.${test}.txt ]
  then
      rm -rf ${LOGS}/logcat_hw.${suite}.${test}.txt
  fi

  ### Launch new logcat
  logcat chromium:I *:S -f ${LOGS}/logcat_hw.${suite}.${test}.txt &
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
      test_starting_curr=$(grep $MAGIC_MSG ${LOGS}/logcat_hw.${suite}.${test}.txt | wc -l)
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
     tm=0
   else
     tm=0
   fi

   MAGIC_MSG="spa_stopped_trace";
   test_completed=${base_count}
   test_completed_curr=${base_count}
   test_count=$(($test_completed_curr-$test_completed))
   while [ "$test_count" != ${tot_count} ]
   do
      sleep ${tm}
      test_completed_curr=$(grep $MAGIC_MSG ${LOGS}/logcat_hw.${suite}.${test}.txt | wc -l)
      test_count=$(($test_completed_curr-$test_completed))
      ###Fix for console.log sync errors
      if [[ "$test_count" == 2 ]]; then
        break;
      fi
   done
   echo "   spa_stopped_trace string Detected"
   return
}

if [[ ${CHOICE} == "Sub" ]]; then
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
    )

    tests=(
        "Sub"
    )
else
    suites=(
        "All"
    )

    tests=(
        "All"
    )
fi

###Run only once
func_setup_perf

for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    am start -a android.intent.action.VIEW -n org.chromium.content_shell_apk/.ContentShellActivity -d "$optional_url"

    ###Takes time for the PIDs to get created
    func_setupLogcat ${suite} ${test}

    #${DIR}/simpleperf record -o /sdcard/perf.${suite}.${test}.data -e task-clock:u -f 1000 --app org.chromium.content_shell_apk
    if [[ ${ISPID} == 1 ]]; then
      ###To profile PID
      PID=$(ps -A | grep org.chromium.content_shell_apk:sandboxed_process* | ${DIR}/busybox-spa awk '{print $2}')
    else
      ###To profile TID
      TID=$(ps -AT -o TID,NAME,CMD,CPU | grep CrRendererMain | ${DIR}/busybox-spa awk '{print $1}')
    fi

    input keyevent input TAB
    input keyevent input TAB
    input keyevent ENTER
    input text ${suite}
    input keyevent input TAB
    input text ${test}
    input keyevent input TAB
    input text ${iters}
    input keyevent input TAB

    if [[ ${ISPID} == 1 ]]; then
      ${DIR}/simpleperf record -o /sdcard/record/PID/${CHOICE}/perf.${suite}.${test}.data -e task-clock:u -f 4000 -g -p ${PID} --duration 100 &
    else
      ${DIR}/simpleperf record -o /sdcard/record/TID/${CHOICE}/perf.${suite}.${test}.data -e task-clock:u -f 4000 -g -t ${TID} --duration 100 &
    fi
    pperf=$(pidof ${DIR}/simpleperf)

    input keyevent ENTER

    echo "   Running ..................................."

    func_detect_completion ${suite} ${test} ${base_count} ${tot_count}

    ###Kill the simpleperf process
    su -c kill -SIGINT ${pperf}

    am force-stop org.chromium.content_shell_apk

    ###Kill the backgrounded logcat process
    pkill -9 -f "logcat chromium:I*"
  done
done


