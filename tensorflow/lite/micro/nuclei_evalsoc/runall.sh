#!/bin/env bash
DRYRUN=${DRYRUN:-0}
LOGDIR=${LOGDIR:-gen}
NUCLEI_SDK_NMSIS=${NUCLEI_SDK_NMSIS-}

SCRIPTDIR=$(dirname $(readlink -f $BASH_SOURCE))
SCRIPTDIR=$(readlink -f $SCRIPTDIR)

BUILDGENDIR=${SCRIPTDIR}/../tools/make/gen

if [ "x$NUCLEI_SDK_NMSIS" != "x" ] ; then
    echo "Using NMSIS provided in $NUCLEI_SDK_NMSIS"
    export NUCLEI_SDK_NMSIS=$NUCLEI_SDK_NMSIS
    sleep 2
fi

LOGDIR=$(pwd)/$LOGDIR

rm -rf $BUILDGENDIR/nuclei_evalsoc*

mkdir -p $LOGDIR

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

pushd $SCRIPTDIR
for corearch in "${CORE_ARCH[@]}"; do
    echo "Run for $corearch"
    # determine core and archext
    read core archext <<< "$corearch"

    if [ "x$archext" == "x" ] ; then
        logdir="$LOGDIR/$core/ref"
    else
        logdir="$LOGDIR/$core/$archext"
    fi
    RUNCMD="python3 runall.py --logdir $logdir --core $core --archext \"$archext\""
    echo $RUNCMD
    runlog=$logdir/run.log
    if [ "x$DRYRUN" == "x0" ] ; then
        mkdir -p $logdir
        eval $RUNCMD | tee $runlog
    fi
done
popd
unset NUCLEI_SDK_NMSIS
find $LOGDIR -name "run.log" | xargs grep "Pass/Total:"
