#!/bin/env bash
TARGET=nuclei_evalsoc
OPTIMIZED=${OPTIMIZED-nmsis_nn}
CORE=${CORE:-nx900fd}
DOWNLOAD=${DOWNLOAD:-ilm}
ARCH_EXT=${ARCH_EXT-p}
DRYRUN=${DRYRUN:-0}
NUCLEI_SDK_NMSIS=${NUCLEI_SDK_NMSIS-}
TOOLCHAIN_ROOT=${TOOLCHAIN_ROOT-}

SCRIPTDIR=$(dirname $(readlink -f $BASH_SOURCE))
SCRIPTDIR=$(readlink -f $SCRIPTDIR)

BUILDGENDIR=${SCRIPTDIR}/../tools/make/gen
TF_ROOT=$(readlink -f $SCRIPTDIR/../../../..)

LDSCRIPT=${LDSCRIPT-${SCRIPTDIR}/gcc_ilm_4M.ld}

BUILDCMD="make -f tensorflow/lite/micro/tools/make/Makefile TARGET=${TARGET} DOWNLOAD=${DOWNLOAD} OPTIMIZED_KERNEL_DIR=${OPTIMIZED} SIMU=qemu"

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

function run_test {
    local core=${1:-$CORE}
    local archext=${2-$ARCH_EXT}

    pushd $TF_ROOT
    if [ "x$CLEAN" == "x1" ] ; then
        clean_tflite $core $archext
    fi
    echo "Run all tflite micro test cases for CORE=$core ARCH_EXT=$archext"
    RUNCMD="$BUILDCMD CORE=$core ARCH_EXT=$archext -j test"
    echo $RUNCMD
    if [ "x$DRYRUN" == "x0" ] ; then
        eval $RUNCMD | tee $runlog
    fi
    popd
}
run_test $CORE "$ARCH_EXT"
unset NUCLEI_SDK_NMSIS
