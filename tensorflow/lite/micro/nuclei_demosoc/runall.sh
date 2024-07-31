#!/bin/env bash
DRYRUN=${DRYRUN:-0}
LOGDIR=${LOGDIR:-gen}

mkdir -p $LOGDIR
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
