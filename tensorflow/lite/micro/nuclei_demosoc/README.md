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
* test_case: only necessary when `example_name` is `nmsis_tests`

Example usage:

~~~shell
# cd to where this script located
cd /path/to/tensorflow/tensorflow/lite/micro/nuclei_demosoc
## current base arch is rv64imafdc
# select your ARCH_EXT, for example, p, pv
## p: p extension present
## pv: p and v extension present
export ARCH_EXT=pv
# run micro_speech_test provided in micro_speech example
./run.sh micro_speech_test
# run detection_responder_test_int8 provided in person_detection example
./run.sh detection_responder_test_int8
# run test case for depthwise_conv provided by nmsis_tests
./run.sh nmsis_tests depthwise_conv
~~~

## Run all examples

In this folder, we provided a script to run all examples in one script.

~~~shell
python3 runall.py
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
