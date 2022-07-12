#!/bin/env bash
DRYRUN=${DRYRUN:-0}
TARGET=nuclei_demosoc
OPTIMIZED=${OPTIMIZED-nmsis_nn}
LOGDIR=${LOGDIR:-gentest}
NUCLEI_SDK_NMSIS=${NUCLEI_SDK_NMSIS-}
TOOLCHAIN_ROOT=${TOOLCHAIN_ROOT-}
CLEAN=${CLEAN:-0}

SCRIPTDIR=$(dirname $(readlink -f $BASH_SOURCE))
SCRIPTDIR=$(readlink -f $SCRIPTDIR)

LOGDIR=$(pwd)/$LOGDIR

BUILDGENDIR=${SCRIPTDIR}/../tools/make/gen
TF_ROOT=$(readlink -f $SCRIPTDIR/../../../..)

LDSCRIPT=${LDSCRIPT-${SCRIPTDIR}/gcc_ilm_4M.ld}

if [ "x$DRYRUN" == "x0" ] ; then
    rm -rf $BUILDGENDIR/nuclei_demosoc*
fi

mkdir -p $LOGDIR

BUILDCMD="make -f tensorflow/lite/micro/tools/make/Makefile TARGET=${TARGET} OPTIMIZED_KERNEL_DIR=${OPTIMIZED} SIMU=qemu"

if [ "x$LDSCRIPT" != "x" ] && [ -f ${LDSCRIPT} ] ; then
    LDSCRIPT=$(readlink -f $LDSCRIPT)
    BUILDCMD="$BUILDCMD LINKER_SCRIPT=${LDSCRIPT} "
fi

if [ "x$TOOLCHAIN_ROOT" != "x" ] ; then
    BUILDCMD="$BUILDCMD TARGET_TOOLCHAIN_ROOT=$TOOLCHAIN_ROOT"
    echo "Using Toolchain provided in $TOOLCHAIN_ROOT"
fi

if [ "x$NUCLEI_SDK_NMSIS" != "x" ] ; then
    echo "Using NMSIS provided in $NUCLEI_SDK_NMSIS"
    export NUCLEI_SDK_NMSIS=$NUCLEI_SDK_NMSIS
    sleep 2
fi

function clean_tflite {
    local core=${1:-$CORE}
    local archext=${2-$ARCH_EXT}
    runcmd="$BUILDCMD CORE=$core ARCH_EXT=$archext -j clean"
    echo $runcmd
    if [ "x$DRYRUN" == "x0" ] ; then
        eval $runcmd
    fi
}

pushd $TF_ROOT
for core in n205 n300 n600f n900fd nx900 nx900f nx900fd
do
    for archext in "" p v pv
    do
        echo "Run for $core$archext"
        if [[ "$core" != *"x"* ]] || [[ "$core" != *"f"* ]] ; then
            if [[ "$archext" == *"v"* ]] ; then
                echo "Ignore $core$archext"
                continue
            fi
        fi
        if [ "x$archext" == "x" ] ; then
            logdir="$LOGDIR/$core/ref"
        else
            logdir="$LOGDIR/$core/$archext"
        fi
        if [ "x$CLEAN" == "x1" ] ; then
            clean_tflite $core $archext
        fi
        RUNCMD="$BUILDCMD CORE=$core ARCH_EXT=$archext -j test"
        echo $RUNCMD
        runlog=$logdir/run.log
        if [ "x$DRYRUN" == "x0" ] ; then
            mkdir -p $logdir
            eval $RUNCMD | tee $runlog
        fi
    done
done
popd
find $LOGDIR -name "run.log" | xargs grep "Pass Rate"
unset NUCLEI_SDK_NMSIS
