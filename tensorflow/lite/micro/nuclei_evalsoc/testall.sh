#!/bin/env bash
DRYRUN=${DRYRUN:-0}
TARGET=nuclei_evalsoc
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

LDSCRIPT=${LDSCRIPT-${SCRIPTDIR}/gcc_ilm_8M.ld}

if [ "x$DRYRUN" == "x0" ] ; then
    rm -rf $BUILDGENDIR/nuclei_evalsoc*
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

CORE_ARCH=(
    "n205" 
    "n300" 
    "n300 _xxldsp" 
    "n300fd _xxldspn3x" 
    "n600f" 
    "n600f _zve32f" 
    "n600f _xxldsp" 
    "n600f _zve32f_xxldsp" 
    "n900fd" 
    "n900fd _zve32f" 
    "n900fd _xxldsp" 
    "n900fd _zve32f_xxldsp" 
    "nx900" 
    "nx900 _xxldsp" 
    "nx900f" 
    "nx900f _zve64f" 
    "nx900f _xxldsp" 
    "nx900f _zve64f_xxldsp"
    "nx900fd"
    "nx900fd v"
    "nx900fd _xxldsp"
    "nx900fd v_xxldsp"
)

pushd $TF_ROOT

for corearch in "${CORE_ARCH[@]}"; do
    echo "Run for $corearch"
    # determine core and archext
    read core archext <<< "$corearch"

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
popd
find $LOGDIR -name "run.log" | xargs grep -a "Pass Rate"
unset NUCLEI_SDK_NMSIS
