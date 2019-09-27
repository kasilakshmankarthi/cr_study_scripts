DIR=/data/local/tmp
LOGS=/sdcard/tmp

optional_url='http://localhost:8080/index_logcat.html'
iters=1
base_count=0
tot_count=${iters}

rm -rf /sdcard/tmp
mkdir -p ${LOGS}

func_setup_perf() {
 setprop security.perf_harden 0
 setprop debug.generate-debug-info true

 rm -rf /sdcard/stats/
 mkdir -p /sdcard/stats/
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
   local tot_count=1

   MAGIC_MSG="spa_started_trace";
   test_starting=${base_count}
   test_starting_curr=${base_count}
   test_count=$(($test_starting_curr-$test_starting))
   while [ "$test_count" != ${tot_count} ]
   do
      test_starting_curr=$(grep $MAGIC_MSG ${LOGS}/logcat_hw.${suite}.${test}.txt | wc -l)
      test_count=$(($test_starting_curr-$test_starting))
   done

   ${DIR}/simpleperf stat -o /sdcard/stats/perf.${suite}.${test}.stat -e instructions,cpu-cycles --app org.chromium.content_shell_apk &

   echo "   spa_started_trace string Detected"
   return
}

func_detect_completion(){
   local suite=$1
   local test=$2
   local base_count=$3
   local tot_count=$4

   MAGIC_MSG="spa_stopped_trace";
   test_completed=${base_count}
   test_completed_curr=${base_count}
   test_count=$(($test_completed_curr-$test_completed))
   while [ "$test_count" != ${tot_count} ]
   do
      test_completed_curr=$(grep $MAGIC_MSG ${LOGS}/logcat_hw.${suite}.${test}.txt | wc -l)
      test_count=$(($test_completed_curr-$test_completed))
   done

   ### Kill perf
   pperf=$(pidof ${DIR}/simpleperf)
   su -c kill -SIGINT ${pperf}

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
    #"All"
)

### Wrong duration for some reason
#suites=(
    #"React-TodoMVC"
    #"EmberJS-Debug-TodoMVC"
    #"AngularJS-TodoMVC"
    #"jQuery-TodoMVC"
#)

#tests=(
    #"Adding"
    #"Completing"
    #"Deleting"
    #"All"
#)

tests=("Sub")

###Run only once
func_setup_perf

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

    am start -a android.intent.action.VIEW -n org.chromium.content_shell_apk/.ContentShellActivity -d "$optional_url"

    ###Takes time for the PIDs to get created
    func_setupLogcat ${suite} ${test}

    ###To profile PID use -p option in simpleperf command below
    #PID=$(ps -A | grep org.chromium.content_shell_apk:sandboxed_process* | ${DIR}/busybox-spa awk '{print $2}')
    ###To profile TID use -t option in simpleperf command below
    #TID=$(ps -AT -o TID,NAME,CMD,CPU | grep CrRendererMain | ${DIR}/busybox-spa awk '{print $1}')

    input keyevent input TAB
    input keyevent input TAB
    input keyevent ENTER
    input text ${suite}
    input keyevent input TAB
    input text ${test}
    input keyevent input TAB
    input text ${iters}
    input keyevent input TAB
    input keyevent ENTER

    func_detect_start ${suite} ${test} ${base_count} ${tot_count}

    echo "   Running ..................................."

    func_detect_completion ${suite} ${test} ${base_count} ${tot_count}

    am force-stop org.chromium.content_shell_apk

    ###Kill the backgrounded logcat process
    pkill -9 -f "logcat chromium:I*"
  done
done


