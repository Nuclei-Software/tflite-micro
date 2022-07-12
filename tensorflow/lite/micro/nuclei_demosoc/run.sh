#!/bin/env bash
TARGET=nuclei_demosoc
OPTIMIZED=${OPTIMIZED-nmsis_nn}
TARGET=nuclei_demosoc
CORE=${CORE:-nx900fd}
DOWNLOAD=${DOWNLOAD:-ilm}
ARCH_EXT=${ARCH_EXT-pv}
CLEAN=${CLEAN:-0}
BUILD=${BUILD:-0}
RUNON=${RUNON:-qemu}
DRYRUN=${DRYRUN:-0}
TMOUT=${TMOUT:-}
NUCLEI_SDK_NMSIS=${NUCLEI_SDK_NMSIS-}
TOOLCHAIN_ROOT=${TOOLCHAIN_ROOT-}

SCRIPTDIR=$(dirname $(readlink -f $BASH_SOURCE))
SCRIPTDIR=$(readlink -f $SCRIPTDIR)

APP=${1:-gesture_accelerometer_handler_test}
CASE=${2:-add}

TF_ROOT=$(readlink -f $SCRIPTDIR/../../../..)

APPBINS=tensorflow/lite/micro/tools/make/gen/${TARGET}_${CORE}${ARCH_EXT}_micro/bin

makeopts="-f ${TF_ROOT}/tensorflow/lite/micro/tools/make/Makefile -j DOWNLOAD=${DOWNLOAD} TARGET=${TARGET} CORE=${CORE} ARCH_EXT=${ARCH_EXT} OPTIMIZED_KERNEL_DIR=${OPTIMIZED}"

if [ "x$RUNON" == "xqemu" ] ; then
    makeopts="$makeopts SIMU=qemu"
elif [ "x$RUNON" == "xxlspike" ] ; then
    makeopts="$makeopts SIMU=xlspike"
fi

if [ "x$TOOLCHAIN_ROOT" != "x" ] ; then
    makeopts="$makeopts TARGET_TOOLCHAIN_ROOT=$TOOLCHAIN_ROOT"
    echo "Using Toolchain provided in $TOOLCHAIN_ROOT"
fi

if [ "x$NUCLEI_SDK_NMSIS" != "x" ] ; then
    echo "Using NMSIS provided in $NUCLEI_SDK_NMSIS"
    export NUCLEI_SDK_NMSIS=$NUCLEI_SDK_NMSIS
    sleep 2
fi

echo "Tensorflow root is $TF_ROOT"

function env_setup {
    local ENVFILE=/home/share/devtools/env.sh
    echo "Setup build environment"
    if [ -f $ENVFILE ] ; then
        source $ENVFILE
    else
        local NSTC=$TF_ROOT/tensorflow/lite/micro/tools/make/downloads/nuclei_studio/NucleiStudio/toolchain
        export PATH=$NSTC/gcc/bin:$NSTC/qemu/bin:$NSTC/openocd/bin:$PATH
    fi
}

function clean_app {
    runcmd="make ${makeopts} clean"
    echo $runcmd
    if [ "x$DRYRUN" == "x0" ] ; then
        eval $runcmd
    fi
}

function build_app {
    local appname=${1:-hello_world_test}
    local appcase=${2:-add}
    echo "Build APP=$appname, CASE=$appcase"
    local runcmd="make ${makeopts} TEST_CASE=${appcase} build"
    echo $runcmd
    if [ "x$DRYRUN" == "x0" ] ; then
        eval $runcmd
    fi
}

function rm_app {
    local appname=${1:-hello_world_test}
    local appfile=${APPBINS}/$appname
    echo "Remove prebuilt $appfile"
    if [ "x$DRYRUN" == "x0" ] ; then
        rm -f $appfile
    fi
}

function run_app {
    local appname=${1:-hello_world_test}
    local appfile=${APPBINS}/$appname
    echo "Run $appfile on $RUNON"
    local runcmd="echo Unable to run on $RUNON"
    if [ "x$RUNON" == "xqemu" ] ; then
        if [[ "$CORE" == *"x"* ]] ; then
            local qemucmd="qemu-system-riscv64"
        else
            local qemucmd="qemu-system-riscv32"
        fi
        which ${qemucmd}
        runcmd="${qemucmd} -M nuclei_n,download=${DOWNLOAD} -cpu nuclei-${CORE},ext=${ARCH_EXT} \
            -nodefaults -nographic -serial stdio -kernel $appfile"
    elif [ "x$RUNON" == "xxlspike" ] ; then
        runcmd="xl_spike $appfile"
    fi
    if [ "x$TMOUT" != "x" ] ; then
        runcmd="timeout -s 9 --preserve-status --foreground $TMOUT $runcmd"
    fi
    echo $runcmd
    if [ "x$DRYRUN" == "x0" ] ; then
        eval $runcmd
    fi
}

function do_run {
    local appname=${1:-hello_world_test}
    local appcase=${2:-add}
    local appfile=${APPBINS}/$appname

    pushd $TF_ROOT
    if [ "x$CLEAN" == "x1" ] ; then
        clean_app
    fi
    if [ "x$appname" == "xnmsis_tests" ] ; then
        rm_app $appname
    fi
    # only build app if app not exist
    if [ ! -f $appfile ] || [ "x$BUILD" == "x1" ]; then
        build_app $appname $appcase
    fi
    run_app $appname
    popd
}

env_setup
do_run $APP $CASE
