# Nuclei RISC-V Processors

This folder contains TFLite kernel operations optimized for Nuclei RISC-V Processors with P/V extensions.

It is designed to be portable even to 'bare metal', so it follows the same design goals as the micro experimental port.

## How to quick explore it

## Setup

Download Nuclei Studio 2022.04 from https://nucleisys.com/download.php and extract it.

Setup up path for build system.

~~~shell
export NSTC=/path/to/NucleiStudio_IDE_202204/NucleiStudio/toolchain
export PATH=$NSTC/qemu/bin:$NSTC/gcc/bin:$NSTC/openocd/bin:$PATH
# if you don't want to download IDE again when build application, please create soft link
ln -s /path/to/NucleiStudio_IDE_202204 /path/to/tensorflow/lite/micro/tools/make/downloads/nuclei_studio
~~~

## Run

A script called `run.sh` is provided to quickly build and run on qemu.

~~~shell
./run.sh <example_name> [test_case]
~~~

* example_name: required argument, stand for the example name to be run. such as `hello_world`, `hello_world_test`, `magic_wand` and etc.
  Examples can be found in *tensorflow/lite/micro/examples*

Example usage:

~~~shell
# cd to where this script located
cd /path/to/tensorflow/tensorflow/lite/micro/nuclei_demosoc
## current CORE is nx900fd, RISV-ARCH is rv64imafdc
# select your CORE, for example, n205, n900fd
## Support CORE list can be found in SUPPORTED_CORES
## in tensorflow/lite/micro/tools/make/targets/nuclei_demosoc_corearchabi.inc
## for example, select CORE nx900fd
export CORE=nx900fd
# select your ARCH_EXT, for example, p, pv
## p: p extension present
## pv: p and v extension present
export ARCH_EXT=pv
# run micro_speech_test provided in micro_speech example
./run.sh micro_speech_test
# run detection_responder_test provided in person_detection example
./run.sh detection_responder_test
# run test case for conv kernel
./run.sh kernel_conv_test
# If you want to rebuild this app before run it, you can specify BUILD=1
BUILD=1 ./run.sh kernel_conv_test
# If you want to clean all objects and rebuilt it, you can specify CLEAN=1
CLEAN=1 ./run.sh kernel_conv_test
~~~

This `run.sh` is a simple script to make you can run on qemu easily, and you can also build tflite micro
example by make command.

~~~
pwd
# make sure you are in the root directory of tflite-micro repo
# CORE, ARCH_EXT, DOWNLOAD, SIMU are new introduced make variables supppored by TARGET=nuclei_demosoc
## CORE can be set to be one of the SUPPORTED_CORES in tensorflow/lite/micro/tools/make/targets/nuclei_demosoc_corearchabi.inc
## such as CORE=nx900f
## ARCH_EXT can be set to empty or p, v, pv
## such as ARCH_EXT=p ARCH_EXT= ARCH_EXT=pv
## ARCH_EXT= means no p/v extension is selected, and will use pure-c optimized NMSIS-NN library
## DOWNLOAD can be one of the ilm/flashxip/flash/ddr
## SIMU can be qemu, when set to qemu, it can auto-exit qemu running, if return from main
# You can set OPTIMIZED_KERNEL_DIR=nmsis_nn to select optimized nmsis_nn tflite-micro kernels
### Examples
## 1. Build kernel_conv_test for n300f with p extension, and optimized with nmsis_nn
make -f tensorflow/lite/micro/tools/make/Makefile TARGET=nuclei_demosoc CORE=n300f ARCH_EXT=p OPTIMIZED_KERNEL_DIR=nmsis_nn kernel_conv_test
## 2. If you want to run on qemu, SIMU=qemu is required to pass to make, and clean project and rebuild is required
make -f tensorflow/lite/micro/tools/make/Makefile TARGET=nuclei_demosoc SIMU=qemu CORE=n300f ARCH_EXT=p OPTIMIZED_KERNEL_DIR=nmsis_nn clean
## 3. Build and run on qemu for kernel_conv_test
make -f tensorflow/lite/micro/tools/make/Makefile TARGET=nuclei_demosoc SIMU=qemu CORE=n300f ARCH_EXT=p OPTIMIZED_KERNEL_DIR=nmsis_nn test_kernel_conv_test
## 4. Build and run on qemu for micro_speech_test without nmsis_nn optimized kernel for nx600fd - p
make -f tensorflow/lite/micro/tools/make/Makefile TARGET=nuclei_demosoc SIMU=qemu CORE=nx600fd ARCH_EXT=p OPTIMIZED_KERNEL_DIR=nmsis_nn test_micro_speech_test
## The build elf can be found in tensorflow/lite/micro/tools/make/gen/nuclei_demosoc_nx600fdp_micro/
# for micro_speech_test, it should be tensorflow/lite/micro/tools/make/gen/nuclei_demosoc_nx600fdp_micro/bin/micro_speech_test
~~~

If you want to run on hardware, you can download this built elf using openocd and gdb, and run on
hardware, and make sure the bitstream you programmed on hardware have at least 512K ILM and 512K DLM.

## Run all examples for different CORE and ARCH_EXT

In this folder, we provided a script to run all examples in one script.

~~~shell
bash runall.sh
# current version status on qemu
find gen -name "run.log" | xargs grep Pass
#gen/nx900f/p/run.log:nx900fp Pass/Total: 24/24=100.000%
#gen/nx900f/v/run.log:nx900fv Pass/Total: 21/24=87.500%
#gen/nx900f/pv/run.log:nx900fpv Pass/Total: 24/24=100.000%
#gen/nx900f/ref/run.log:nx900f Pass/Total: 24/24=100.000%
#gen/n900fd/p/run.log:n900fdp Pass/Total: 24/24=100.000%
#gen/n900fd/ref/run.log:n900fd Pass/Total: 24/24=100.000%
#gen/n600f/p/run.log:n600fp Pass/Total: 24/24=100.000%
#gen/n600f/ref/run.log:n600f Pass/Total: 24/24=100.000%
#gen/nx900fd/p/run.log:nx900fdp Pass/Total: 24/24=100.000%
#gen/nx900fd/v/run.log:nx900fdv Pass/Total: 21/24=87.500%
#gen/nx900fd/pv/run.log:nx900fdpv Pass/Total: 24/24=100.000%
#gen/nx900fd/ref/run.log:nx900fd Pass/Total: 24/24=100.000%
#gen/n205/p/run.log:n205p Pass/Total: 24/24=100.000%
#gen/n205/ref/run.log:n205 Pass/Total: 24/24=100.000%
#gen/n300/p/run.log:n300p Pass/Total: 24/24=100.000%
#gen/n300/ref/run.log:n300 Pass/Total: 24/24=100.000%
#gen/nx900/p/run.log:nx900p Pass/Total: 24/24=100.000%
#gen/nx900/ref/run.log:nx900 Pass/Total: 24/24=100.000%
# current implemented nmsis-nn fully_connected_s8 api has some issue in it for vector optimized
# please take care
~~~

This script will run all the application and record run log into log file.

## FAQs

### Default ilm/dlm size in demosoc is 64K/64K, need to change it to 512K to run these cases

If you met issue like this: `section \`.text' will not fit in region \`ilm'`, this is caused by ilm size is not big enough to store the code, 64K is not enough to run this application, please use 512K, if you want to run on hardware,
please make sure your hardware configured with 512K ILM/DLM.

Now this patching step is done by build system, no need to do any more steps.

~~~shell
sed -i "s/64K/512K/g" /path/to/tensorflow/lite/micro/tools/make/downloads/nuclei_sdk/SoC/demosoc/Board/nuclei_fpga_eval/Source/GCC/gcc_demosoc_ilm.ld
~~~
