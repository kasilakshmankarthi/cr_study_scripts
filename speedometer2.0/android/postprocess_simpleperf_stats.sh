#!/bin/bash
CHOICE=$1
echo "User entered choice (Split/Sub/All): " ${CHOICE}
echo "Split measures individual test (Adding/Completing/Deleting) in a suite (Not recommended)"
echo "Sub measures individual suite"
echo "All measures entire Speedometer2.0 suite"

STATS_DIR=/work/kasilka/V8_study/MG_Instrs_Cycles/stats

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
elif [[ ${CHOICE} == "All" ]]; then

    suites=(
        "All"
    )

    tests=(
        "All"
    )
else
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
        "Adding"
        "Completing"
        "Deleting"
    )
fi

echo "Instructions"

for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    grep  "instructions" ${STATS_DIR}/perf.${suite}.${test}.stat | grep -Eo '[0-9,]+(\s*instructions)' | grep -Eo '[0-9,]*'
  done
done

echo "---------------------------------"
echo "Cycles"
for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    grep  "cpu-cycles" ${STATS_DIR}/perf.${suite}.${test}.stat | grep -Eo '[0-9,]+(\s*cpu-cycles)' | grep -Eo '[0-9,]*'
  done
done

echo "---------------------------------"
echo "Total time in seconds"
for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    grep  "Total test time:" ${STATS_DIR}/perf.${suite}.${test}.stat |  grep -Eo '[0-9]+\.[0-9]+'
  done
done

echo "---------------------------------"
echo "Speedometer2.0 Total time in seconds"
LOGS_DIR=/work/kasilka/V8_study/MG_Instrs_Cycles/tmp
for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    grep -oP 'syncTime = \K\d+\.\d+' ${LOGS_DIR}/logcat_hw.${suite}.${test}.txt | awk '{sum+=sprintf("%f",$1)}END{printf "%.6f\n",sum/1000}'
  done
done

echo "---------------------------------"
