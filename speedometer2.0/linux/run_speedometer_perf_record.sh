export PERF_PATH=/home/shunya/tools/perf
#$PERF_PATH/perf record -e cpu-cycles -F 5000 -k mono ./d8 --perf-prof $1
#$PERF_PATH/perf inject -j -i perf.data -o perf.data.jitted
#$PERF_PATH/perf report -i perf.data.jitted
sudo sh -c 'echo -:w11 >/proc/sys/kernel/perf_event_paranoid'
sudo sh -c 'echo kernel.perf_event_paranoid=-1 > /etc/sysctl.d/local.conf'
sudo sh -c "echo 0 > /proc/sys/kernel/kptr_restrict"

LOG_FILE=~/.config/chromium/chrome_debug.log

OUT=/tmp/results
mkdir -p ${OUT}

optional_url='http://localhost:8082/index_logcat.html'
iters=1
base_count=0
tot_count=${iters}

rm -rf /sdcard/tmp
mkdir -p ${OUT}

func_setup_perf() {

}

func_setupLog(){
  suite=$1
  test=$2

  ### Clean the exiting logcat process
  if [ -f ${LOG_FILE} ]
  then
      rm -rf ${LOG_FILE}
  fi

  echo "   Log setup done ..........................."
}

func_detect_start(){
   suite=$1
   test=$2
   base_count=$3
   tot_count=$4

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
   suite=$1
   test=$2
   base_count=$3
   tot_count=$4
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

    chromium-browser --enable-logging --log-level=0 --js-flags="--perf-prof" -d "$optional_url" &

    ###Takes time for the PIDs to get created
    func_setupLog ${suite} ${test}

    ###To profile PID use -p option in perf command below
    PID=$(ps -A | grep org.chromium.content_shell_apk:sandboxed_process* | ${DIR}/busybox-spa awk '{print $2}')
    ###To profile TID use -t option in perf command below
    TID=$(ps -AT -o TID,NAME,CMD,CPU | grep CrRendererMain | ${DIR}/busybox-spa awk '{print $1}')

    input keyevent input TAB
    input keyevent input TAB
    input keyevent ENTER
    input text ${suite}
    input keyevent input TAB
    input text ${test}
    input keyevent input TAB
    input text ${iters}
    input keyevent input TAB

    ${PERF_PATH}/perf record -o ${OUT}/perf.${suite}.${test}.data -e cpu-cycles -F 5000 -p ${PID} --duration 60 &
    pperf=$(pidof ${PERF_PATH}/perf)

    input keyevent ENTER

    echo "   Running ..................................."

    func_detect_completion ${suite} ${test} ${base_count} ${tot_count}

    am force-stop org.chromium.content_shell_apk

    ###Kill processes for fresh start
    su -c kill -SIGINT ${pperf}
  done
done


