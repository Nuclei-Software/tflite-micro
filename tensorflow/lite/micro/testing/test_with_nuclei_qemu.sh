#!/bin/bash
# Copyright 2020 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
#
# Parameters:
#  ${1} - space-separated list of binaries to test
#  ${2} - String that is checked for pass/fail.
#  ${3} - nuclei core (nx900fd, n205 etc.)/TARGET for run_xxx or test_xxx
#  ${4} - nuclei arch extension (, p, v, pv etc.)
#  ${5} - simulation runner (qemu etc.)

FILES="${1}"
PASS_STRING=${2}
CORE=${3:-nx900fd}
ARCH_EXT=${4-pv}
RUNON=${5:-qemu}
DRYRUN=${DRYRUN:-0}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFLM_ROOT_DIR=${SCRIPT_DIR}/..

# Nuclei QEMU PATH
NUCLEI_QEMU_ROOT=${TFLM_ROOT_DIR}/tools/make/downloads/nuclei_studio/NucleiStudio/toolchain/qemu

export PATH=$NUCLEI_QEMU_ROOT/bin:$PATH

function run_test {
    local testfile=${1}
    echo "Run $testfile on $RUNON"
    local runcmd="echo Unable to run on $RUNON"
    if [ "x$RUNON" == "xqemu" ] ; then
        if [[ "$CORE" == *"x"* ]] ; then
            local qemucmd="qemu-system-riscv64"
        else
            local qemucmd="qemu-system-riscv32"
        fi
        which ${qemucmd}
        runcmd="${qemucmd} -M nuclei_n,download=ilm -cpu nuclei-${CORE},ext=${ARCH_EXT} \
            -nodefaults -nographic -serial stdio -kernel $testfile"
    elif [ "x$RUNON" == "xxlspike" ] ; then
        runcmd="xl_spike $testfile"
    fi
    if [ "x$TMOUT" != "x" ] ; then
        runcmd="timeout -s 9 --preserve-status --foreground $TMOUT $runcmd"
    fi
    echo $runcmd
    eval $runcmd
}

function run_check_test {
    local testfile=${1}
    local logfile=${2}

    if [ "$PASS_STRING" == "non_test_binary" ] ; then
        run_test $testfile 2>&1 | tee $logfile
    else
        run_test $testfile > $logfile 2>&1
        local psmsg=$(cat $logfile | grep "$PASS_STRING")
        if [ "x$psmsg" == "x" ] ; then
            return 1
        else
            return 0
        fi
    fi
}

function run_all_tests {
    exitcode=0
    totalcnt=0
    passcnt=0
    echo "Record all logs into ${RESULTS_DIRECTORY}"
    for binary in ${FILES}
    do
        binlog=$RESULTS_DIRECTORY/$(basename $binary).log
        echo -n "Test $binary for $CORE${ARCH_EXT} on $RUNON, log to $binlog: "
        totalcnt=$((totalcnt+1))
        run_check_test $binary $binlog
        if [ $? == 0 ]; then
            passcnt=$((passcnt+1))
            echo "Passed"
        else
            echo "Failed"
            exitcode=1
        fi
    done
    echo "Target $CORE${ARCH_EXT}, Pass Rate($passcnt/$totalcnt)=$(echo "scale=2; $passcnt*100/$totalcnt" | bc -l)%"
    exit $exitcode
}

function run_for_target {
    for binary in ${FILES}
    do
        arrs=(${binary//\// })
        corearch=${arrs[-3]}
        corearch=${corearch//nuclei_demosoc_/}
        corearch=${corearch//nuclei_evalsoc_/}
        corearch=${corearch//_micro/}
        break
    done
    if [[ "$corearch" == *"x"* ]] ; then
        CORE=nx900fd
        ARCH_EXT=bpkv
    else
        CORE=n900fd
        ARCH_EXT=bpkv
    fi
    RESULTS_DIRECTORY=/tmp/nuclei_qemu/run_logs
    mkdir -p ${RESULTS_DIRECTORY}
    run_all_tests
}

if [[ "x$CORE" == "xnuclei"* ]] ; then
    # workaround
    # for run_xxx or test_xxx target, see helper_functions.inc
    run_for_target
else
    RESULTS_DIRECTORY=/tmp/nuclei_qemu/${CORE}${ARCH_EXT}_logs
    mkdir -p ${RESULTS_DIRECTORY}
    run_all_tests
fi


