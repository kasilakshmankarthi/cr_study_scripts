CHOICE=$1
echo "User entered choice (heavy/lite): " ${CHOICE}
echo "Heavy measures GFX rich Speedometer2.0"
echo "Light measures inteactive (GFX lite) Speedometer2.0"

DIR=/data/local/tmp
LOGS=/sdcard/tmp

if [[ ${CHOICE} == "heavy" ]]; then
  optional_url='http://localhost:8080/index_logcat.html'
else
  optional_url='http://localhost:8081/InteractiveRunnerIters_logcat.html'
fi
iters=3
base_count=0
tot_count=${iters}

rm -rf /sdcard/tmp
mkdir -p ${LOGS}

func_setupLogcat(){
  ### Clean the exiting logcat process
  logcat -d > /dev/null 2>&1
  logcat -c

  if [ -f ${LOGS}/logcat_hw.${CHOICE}.txt ];then
      rm -rf ${LOGS}/logcat_hw.${CHOICE}.txt
  fi

  ### Launch new logcat
  logcat chromium:I *:S -f ${LOGS}/logcat_hw.${CHOICE}.txt &
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
      test_starting_curr=$(grep $MAGIC_MSG ${LOGS}/logcat_hw.${CHOICE}.txt | wc -l)
      test_count=$(($test_starting_curr-$test_starting))
   done

   echo "   spa_started_trace string Detected"
   return
}

func_detect_completion(){
   local base_count=$1
   local tot_count=$2
   local test_number=$3
   test_number=$(( test_number * tot_count ))

   MAGIC_MSG="spa_stopped_trace";
   test_completed=${base_count}
   test_completed_curr=${base_count}
   test_count=$(($test_completed_curr-$test_completed))
   while [ 1 ]
   do
      test_completed_curr=$(grep $MAGIC_MSG ${LOGS}/logcat_hw.${CHOICE}.txt | wc -l)
      test_count=$(($test_completed_curr-$test_completed))
      ###Fix for console.log sync errors
      if [[ $test_count -eq ${test_number} ]]; then
        echo "   spa_stopped_trace string Detected for test: "${test_count}
        break;
      fi
   done

   return
}

suites=(
    "Vanilla-ES2015-Babel-Webpack-TodoMVC"
    "React-Redux-TodoMVC"
    "EmberJS-TodoMVC"
    "BackboneJS-TodoMVC"
    "AngularJS-TodoMVC"
    "Angular2-Typescript-TodoMVC"
    "Elm-TodoMVC"
    "Flight-TodoMVC"
    #"All"
)

tests=(
  #"All"
  "Sub"
)

###Takes time for the PIDs to get created
func_setupLogcat ${CHOICE}
number=0

for suite in ${suites[@]}
do
  number=$(( number + 1 ))

  for test in ${tests[@]}
  do
    am start -a android.intent.action.VIEW -n org.chromium.content_shell_apk/.ContentShellActivity -d "$optional_url"

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

    echo "   Running ..................................."

    func_detect_completion ${base_count} ${tot_count} ${number}

    am force-stop org.chromium.content_shell_apk
  done
done

##Kill the backgrounded logcat process
pkill -9 -f "logcat chromium:I*"
