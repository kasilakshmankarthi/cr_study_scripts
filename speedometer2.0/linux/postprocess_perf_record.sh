SRC_DIR=/sarc/spa/users/kasi.a/cr_tip/chromium/src
DIR=${SRC_DIR}/third_party/android_ndk/simpleperf
NDK_DIR=${SRC_DIR}/third_party/android_ndk/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/

BINDIR=$DIR/binary_cache/data/app/*/lib/arm64/

mkdir -p $DIR/samples
mkdir -p $DIR/samples/reports
mkdir -p $DIR/samples/annotates

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

SS=$((${#suites[@]} - 1))
TS=$((${#tests[@]} - 1))

for i in `seq 0 $SS`
do
  suite=${suites[i]}

  for j in `seq 0 $TS`
  do
    test=${tests[j]}

    if [ "${suite}" == "All" ] && [ "${test}" != "All" ]; then
     continue;
    fi
    if [ "${suite}" != "All" ] && [ "${test}" == "All" ]; then
     continue;
    fi

    adb pull /sdcard/perf.${suite}.${test}.data $DIR/samples

    #####Run once to pull the libs from the device
    #python $DIR/binary_cache_builder.py

    #####Create a symbolic link to unstripped version of libcontent_shell_view.so inside binary_cache directory
    #ln -s ${SRC_DIR}/out/a64rel.ctip.prof.android/lib.unstripped/libcontent_shell_content_view.so $BINDIR/libcontent_shell_content_view.so

    ####To obtain report
    python $DIR/report.py -i $DIR/samples/perf.${suite}.${test}.data -o ${DIR}/samples/reports/perf.${suite}.${test}.report --symfs ${DIR}/binary_cache

    #####To obtain annotate (takes longer time)
    #python $DIR/annotate.py -i $DIR/samples/perf.${suite}.${test}.data -s ${SRC_DIR} --dso /sarc/spa/users/kasi.a/cr_tip/chromium/src/out/a64rel.ctip.prof.android/lib.unstripped/libcontent_shell_content_view.so --addr2line ${NDK_DIR}
    #mv $DIR/samples/annotated_files  $DIR/samples/annotates_${suite}_${test}
  done
done
