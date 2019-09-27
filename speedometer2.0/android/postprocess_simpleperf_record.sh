CHOICE=$1
echo "User entered choice (Sub/All): " ${CHOICE}
echo "Sub measures individual suite"
echo "All measures entire Speedometer2.0 suite"

ISPID=$2
echo "ISPID (=sandbox process) [or] (=0 CrRendererMain thread): " ${ISPID}

SRC_DIR=/sarc/spa/users/kasi.a/cr_tip/chromium/src
DIR=${SRC_DIR}/third_party/android_ndk/simpleperf
NDK_DIR=${SRC_DIR}/third_party/android_ndk/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/

BINDIR=$DIR/binary_cache/data/app/*/lib/arm64/

if [[ ${ISPID} == 1 ]]; then
    PID_SAMPLES=${DIR}/samples_PID_content_shell_apk_sandboxed_process

    mkdir -p ${PID_SAMPLES}
    mkdir -p ${PID_SAMPLES}/${CHOICE}/reports
    mkdir -p ${PID_SAMPLES}/${CHOICE}/annotates
else
    TID_SAMPLES=${DIR}/samples_TID_CrRenderer

    mkdir -p ${TID_SAMPLES}
    mkdir -p ${TID_SAMPLES}/${CHOICE}/reports
    mkdir -p ${TID_SAMPLES}/${CHOICE}/annotates
fi

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
        "Angular2-TypeScript-TodoMVC"
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
fi

for suite in ${suites[@]}
do
  for test in ${tests[@]}
  do
    #####Run once to pull the libs from the device
    #python $DIR/binary_cache_builder.py

    #####Create a symbolic link to unstripped version of libcontent_shell_view.so inside binary_cache directory
    #ln -s ${SRC_DIR}/out/a64rel.ctip.prof.android/lib.unstripped/libcontent_shell_content_view.so $BINDIR/libcontent_shell_content_view.so

    if [[ ${ISPID} == 1 ]]; then
      ##adb pull /sdcard/record/PID/${CHOICE} ${PID_SAMPLES}

      #####To obtain report (with call graph)
      ##python $DIR/report.py -i ${PID_SAMPLES}/${CHOICE}/perf.${suite}.${test}.data -o ${PID_SAMPLES}/${CHOICE}/reports_CallGraph/perf.${suite}.${test}.report -n -g --symfs ${DIR}/binary_cache
      #python $DIR/report.py -i ${PID_SAMPLES}/${CHOICE}/perf.${suite}.${test}.data -o ${PID_SAMPLES}/${CHOICE}/reports/perf.${suite}.${test}.report --symfs ${DIR}/binary_cache

      echo perf.${suite}.${test}.report >> $(pwd)/top_5_overhead.PID.summary
      cat ${PID_SAMPLES}/${CHOICE}/reports/perf.${suite}.${test}.report | sed '8,12!d' >> $(pwd)/top_5_overhead.PID.summary
      echo "-------------------------------------------------------------------------------------------------------------" >> $(pwd)/top_5_overhead.PID.summary
      echo "" >> $(pwd)/top_5_overhead.PID.summary

    else
      ##adb pull /sdcard/record/TID/${CHOICE} ${TID_SAMPLES}

      #####To obtain report (with call graph)
      ##python $DIR/report.py -i ${TID_SAMPLES}/${CHOICE}/perf.${suite}.${test}.data -o ${TID_SAMPLES}/${CHOICE}/reports_CallGraph/perf.${suite}.${test}.report -n -g --symfs ${DIR}/binary_cache
      python $DIR/report.py -i ${TID_SAMPLES}/${CHOICE}/perf.${suite}.${test}.data -o ${TID_SAMPLES}/${CHOICE}/reports/perf.${suite}.${test}.report --symfs ${DIR}/binary_cache
      #python $DIR/report_html.py -i ${TID_SAMPLES}/${CHOICE}/perf.${suite}.${test}.data -o ${TID_SAMPLES}/${CHOICE}/reports_html/perf.${suite}.${test}.report \
          #--ndk_path /sarc/spa/users/kasi.a/Android/Sdk/ndk-bundle --symfs ${DIR}/binary_cache
      ##$DIR/inferno.sh -sc --record_file ${TID_SAMPLES}/${CHOICE}/perf.${suite}.${test}.data -o ${TID_SAMPLES}/${CHOICE}/reports_inferno/perf.${suite}.${test}.report --symfs ${DIR}/binary_cache

      echo perf.${suite}.${test}.report >> $(pwd)/top_5_overhead.TID.summary
      cat ${TID_SAMPLES}/${CHOICE}/reports/perf.${suite}.${test}.report | sed '8,12!d' >> $(pwd)/top_5_overhead.TID.summary
      echo "-------------------------------------------------------------------------------------------------------------" >> $(pwd)/top_5_overhead.TID.summary
      echo "" >> $(pwd)/top_5_overhead.TID.summary
    fi

    #####To obtain annotate (takes longer time)
    #python $DIR/annotate.py -i $DIR/samples/perf.${suite}.${test}.data -s ${SRC_DIR} --dso /sarc/spa/users/kasi.a/cr_tip/chromium/src/out/a64rel.ctip.prof.android/lib.unstripped/libcontent_shell_content_view.so --addr2line ${NDK_DIR}
    #mv $DIR/samples/annotated_files  $DIR/samples/annotates_${suite}_${test}
  done
done
