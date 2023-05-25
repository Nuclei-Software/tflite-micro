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

pushd $SCRIPTDIR
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
        RUNCMD="python3 runall.py --logdir $logdir --core $core --archext \"$archext\""
        echo $RUNCMD
        runlog=$logdir/run.log
        if [ "x$DRYRUN" == "x0" ] ; then
            mkdir -p $logdir
            eval $RUNCMD | tee $runlog
        fi
    done
done
popd
unset NUCLEI_SDK_NMSIS
find $LOGDIR -name "run.log" | xargs grep "Pass/Total:"
