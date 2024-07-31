#!/bin/env python3
import os
import sys
import argparse
import json
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
RUNSH=os.path.join(SCRIPT_DIR, "run.sh")

def run_app(app, case, core, archext, log):
    if os.path.isfile(log) == False:
        logdir = os.path.dirname(log)
        if os.path.isdir(logdir) == False:
            os.makedirs(logdir)
    runcmd = "TMOUT=10s CORE=%s ARCH_EXT=%s %s %s %s > %s 2>&1" % (core, archext, RUNSH, app, case, log)
    print("Run CFG=%s%s APP=%s, CASE=%s, LOG=%s :" %(core, archext, app, case, log), end = "")
    sys.stdout.flush()
    ret = os.system(runcmd)
    print(" ret %d, " % ret, end = "")
    #ret = subprocess.call(runcmd, shell=True)
    with open(log) as lf:
        if app == "hello_world":
            if ret == 0:
                ret = True
            else:
                ret = False
        else:
            ret = False
            for line in lf.readlines():
                if "~~~ALL TESTS PASSED~~~" in line:
                    ret = True
                    break
    if ret == True:
        print(" PASS")
    else:
        print(" FAIL")

    sys.stdout.flush()
    # turn echo in shell
    if sys.platform != "win32":
        os.system("stty echo 2> /dev/null")
    return ret

def run_app_in_json(jf, core, archext, logdir):
    if os.path.isfile(jf) == False:
        return
    jsd = json.load(open(jf))
    passcnt = 0
    totalcnt = 0
    for key in jsd:
        for item in jsd[key]:
            app = item
            case = ""
            lgfn = app
            if key == "nmsis_tests":
                app = key
                case = item
                lgfn = "%s_%s" % (app, case)
            log = os.path.join(logdir, lgfn + ".log")
            totalcnt += 1
            ret = run_app(app, case, core, archext, log)
            if ret == True:
                passcnt += 1

    print("%s Pass/Total: %d/%d=%.3f%%" % (core + archext, passcnt, totalcnt, passcnt * 100.0/ totalcnt))
    if passcnt != totalcnt:
        return False
    return True

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="TFLite Runner for Nuclei RISC-V Processor on QEMU")
    parser.add_argument('--cfg', help="JSON Configuration File")
    parser.add_argument('--core', default="nx900fd", help="JSON Configuration File")
    parser.add_argument('--archext', default="pv", help="Nuclei ARCH Extension, such as p, v, pv")
    parser.add_argument('--logdir', default='logs', help="logs directory, default logs")

    args = parser.parse_args()
    if args.cfg == None:
        args.cfg = os.path.join(SCRIPT_DIR, "cases.json")

    print("Run cases specified in %s, with CORE=%s, ARCH_EXT=%s" % (args.cfg, args.core, args.archext))
    ret = run_app_in_json(args.cfg, args.core, args.archext, args.logdir)
    if ret:
        sys.exit(0)
    else:
        sys.exit(1)
