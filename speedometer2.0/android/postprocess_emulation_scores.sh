#!/bin/bash
CHOICE=$1
echo "User entered choice (heavy/lite): " ${CHOICE}
echo "Heavy measures GFX rich Speedometer2.0"
echo "Light measures inteactive (GFX lite) Speedometer2.0"

#SCORES_FILE=/work/kasilka/V8_study/MG_Instrs_Cycles/score_fullsuite/logcat_hw.${CHOICE}.txt
SCORES_FILE=/work/kasilka/V8_study/MG_Instrs_Cycles/score_vanillajs_babel/logcat_hw.${CHOICE}.txt

########################## Caveats##############################
##1. Handle whole time wihtout fractional part
##2. Sometimes same line is printed twice in the console.log
################################################################

#OUT_FILE=/work/kasilka/V8_study/MG_Instrs_Cycles/score_fullsuite/output.${CHOICE}.txt
OUT_FILE=/work/kasilka/V8_study/MG_Instrs_Cycles/score_vanillajs_babel/output.${CHOICE}.txt
rm -rf ${OUT_FILE}

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
    "Angular2-TypeScript-TodoMVC"
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

echo "First run: " >> ${OUT_FILE}
echo "syncTime: " >> ${OUT_FILE}

for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    line=$(grep -m1 -A1 "= ${suite}.*${test}.*" ${SCORES_FILE} | tail -n 1)
    echo $line | grep -Eo " syncTime = [0-9]+(.[0-9]+?)" | grep -Eo "[0-9]+(.[0-9]+?)" >> ${OUT_FILE}
  done
done

echo "------------------------------------------------"

echo "asyncTime: " >> ${OUT_FILE}
for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    line=$(grep -m1 -A1 "= ${suite}.*${test}.*" ${SCORES_FILE} | tail -n 1)
    echo $line | grep -Eo " asyncTime = [0-9]+(.[0-9]+?)" | grep -Eo "[0-9]+(.[0-9]+?)" >> ${OUT_FILE}
  done
done

echo "------------------------------------------------"

echo "Second run: " >> ${OUT_FILE}
echo "syncTime: " >> ${OUT_FILE}

for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    line=$(grep -m2 -A1 "= ${suite}.*${test}.*" ${SCORES_FILE} | tail -n 1)
    echo $line | grep -Eo " syncTime = [0-9]+(.[0-9]+?)" | grep -Eo "[0-9]+(.[0-9]+?)" >> ${OUT_FILE}
  done
done

echo "------------------------------------------------"

echo "asyncTime: " >> ${OUT_FILE}
for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    line=$(grep -m2 -A1 "= ${suite}.*${test}.*" ${SCORES_FILE} | tail -n 1)
    echo $line | grep -Eo " asyncTime = [0-9]+(.[0-9]+?)" | grep -Eo "[0-9]+(.[0-9]+?)" >> ${OUT_FILE}
  done
done

echo "------------------------------------------------"

echo "Third run: " >> ${OUT_FILE}
echo "syncTime: " >> ${OUT_FILE}

for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    line=$(grep -m3 -A1 "= ${suite}.*${test}.*" ${SCORES_FILE} | tail -n 1)
    echo $line | grep -Eo " syncTime = [0-9]+(.[0-9]+?)" | grep -Eo "[0-9]+(.[0-9]+?)" >> ${OUT_FILE}
  done
done

echo "------------------------------------------------"

echo "asyncTime: " >> ${OUT_FILE}
for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    line=$(grep -m3 -A1 "= ${suite}.*${test}.*" ${SCORES_FILE} | tail -n 1)
    echo $line | grep -Eo " asyncTime = [0-9]+(.[0-9]+?)" | grep -Eo "[0-9]+(.[0-9]+?)" >> ${OUT_FILE}
  done
done

echo "------------------------------------------------"
