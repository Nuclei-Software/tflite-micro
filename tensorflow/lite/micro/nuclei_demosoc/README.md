# Nuclei RISC-V Processors

This folder contains TFLite kernel operations optimized for Nuclei RISC-V Processors with P/V extensions.

It is designed to be portable even to 'bare metal', so it follows the same design goals as the micro experimental port.

## How to quick explore it

## Install third party requirements

~~~shell
sudo apt install -y python3-pip
pip3 install Pillow
pip3 install Wave
~~~

## Setup

> Please make sure the steps are executed.
>
> Make sure you have good network connection to download files in tensorflow/lite/micro/tools/make/third_party_downloads.inc

### Setup Third Party Files

Some third party files are also required to be downloaded, but it might fail due to bad connection. So we prepare the predownload
folder `downloads` exclude only `nuclei_studio`, include `nuclei_sdk`.

Please download `tflm_third_downloads.zip` from https://drive.weixin.qq.com/s?k=ABcAKgdSAFcRHZytQu

~~~shell
# Make sure your are in tflm repo directory
cd /path/to/tensorflow
cd tensorflow/lite/micro/tools/make
# make sure no downloads in this directory exist, if yes, backup it as need and then remove it
mv downloads downloads_old
unzip /path/to/tflm_third_downloads.zip
ls -l downloads
drwxr-xr-x 34 hqfang hqfang 4096 Feb  9 10:59 flatbuffers/
drwxr-xr-x 15 hqfang hqfang 4096 Feb  9 11:06 gemmlowp/
drwxr-xr-x  5 hqfang hqfang 4096 Feb  9 11:05 kissfft/
drwxr-xr-x 11 hqfang hqfang 4096 Feb  9 11:06 nuclei_sdk/
drwxr-xr-x 79 hqfang hqfang 4096 Feb  9 11:05 pigweed/
drwxr-xr-x  7 hqfang hqfang 4096 Feb  9 11:06 ruy/
~~~

### Setup Nuclei Studio for TFLM

Download Nuclei Studio 2022.04 from https://nucleisys.com/download.php and extract it.

Setup up path for build system.

~~~shell
# Make sure your are in tflm repo directory
cd /path/to/tensorflow
export NSTC=/path/to/NucleiStudio_IDE_202204/NucleiStudio/toolchain
export PATH=$NSTC/qemu/bin:$NSTC/gcc/bin:$NSTC/openocd/bin:$PATH
# if you don't want to download IDE again when build application, please create soft link
# strongly suggest do the following steps, since network might fail
cd tensorflow/lite/micro/tools/make/downloads/
# make sure no nuclei_studio in this directory exist, if yes, backup it as need and then remove it
ln -s /path/to/NucleiStudio_IDE_202204 nuclei_studio
~~~

### Setup Nuclei SDK for TFLM

> If you download and installed third_party_downloads.zip, then there is no need to install nuclei sdk.

Manually download nuclei-sdk 0.3.8 from github release or wework share link:

- github release: https://github.com/Nuclei-Software/nuclei-sdk/releases/tag/0.3.8
- wework share link: https://drive.weixin.qq.com/s?k=ABcAKgdSAFcbD9WkdD

~~~shell
# Make sure your are in tflm repo directory
cd /path/to/tensorflow
cd tensorflow/lite/micro/tools/make/downloads/
# unzip the downloaded nuclei-sdk 0.3.8 release zip nuclei-sdk-0.3.8.zip
# make sure no nuclei_sdk in this directory exist, if yes, backup it as need and then remove it
unzip /path/to/nuclei-sdk-0.3.8.zip
mv nuclei-sdk-0.3.8 nuclei_sdk
~~~

### Check the setup

If you have setup the environment, please check the it should contains files as below.

~~~shell
# Make sure your are in tflm repo directory
cd /path/to/tensorflow
cd tensorflow/lite/micro/tools/make/downloads/
# list required third party files
$ ls -l
drwxr-xr-x 34 hqfang hqfang 4096 Feb  9 10:59 flatbuffers/
drwxr-xr-x 15 hqfang hqfang 4096 Feb  9 11:06 gemmlowp/
drwxr-xr-x  5 hqfang hqfang 4096 Feb  9 11:05 kissfft/
drwxr-xr-x 11 hqfang hqfang 4096 Feb  9 11:06 nuclei_sdk/
lrwxrwxrwx  1 hqfang hqfang   41 Feb  9 10:53 nuclei_studio -> /home/share/devtools/nucleistudio/2022.04/ # this is a soft link to existing nuclei studio
drwxr-xr-x 79 hqfang hqfang 4096 Feb  9 11:05 pigweed/
drwxr-xr-x  7 hqfang hqfang 4096 Feb  9 11:06 ruy/
# check nuclei_sdk folder
$ ls -l nuclei_sdk/
total 100
drwxr-xr-x 6 hqfang hqfang  4096 Jun  2  2022 application/
drwxr-xr-x 3 hqfang hqfang  4096 Jun  2  2022 Build/
drwxr-xr-x 2 hqfang hqfang  4096 Jun  2  2022 Components/
drwxr-xr-x 3 hqfang hqfang  4096 Jun  2  2022 doc/
-rw-r--r-- 1 hqfang hqfang 11357 Jun  2  2022 LICENSE
-rw-r--r-- 1 hqfang hqfang  2041 Jun  2  2022 Makefile
drwxr-xr-x 6 hqfang hqfang  4096 Jun  2  2022 NMSIS/
-rw-r--r-- 1 hqfang hqfang     7 Jun  2  2022 NMSIS_VERSION
-rw-r--r-- 1 hqfang hqfang   454 Jun  2  2022 npk.yml
drwxr-xr-x 5 hqfang hqfang  4096 Jun  2  2022 OS/
-rw-r--r-- 1 hqfang hqfang   310 Jun  2  2022 package.json
-rw-r--r-- 1 hqfang hqfang 12596 Jun  2  2022 README.md
-rw-r--r-- 1 hqfang hqfang  6301 Jun  2  2022 SConscript
-rw-r--r-- 1 hqfang hqfang   531 Jun  2  2022 setup.bat
-rw-r--r-- 1 hqfang hqfang   717 Jun  2  2022 setup.ps1
-rw-r--r-- 1 hqfang hqfang   563 Jun  2  2022 setup.sh
drwxr-xr-x 4 hqfang hqfang  4096 Jun  2  2022 SoC/
drwxr-xr-x 3 hqfang hqfang  4096 Jun  2  2022 test/
drwxr-xr-x 3 hqfang hqfang  4096 Jun  2  2022 tools/
$ ls -l nuclei_studio/NucleiStudio/
total 9664
-rw-r--r--  1 hqfang nucleisys  153887 Apr  1  2022 artifacts.xml
drwxr-xr-x 11 hqfang nucleisys    4096 Apr  6  2022 configuration/
drwxr-xr-x  2 hqfang nucleisys    4096 Sep 22  2020 dropins/
drwxr-xr-x 86 hqfang nucleisys   12288 Apr  1  2022 features/
drwxr-xr-x  7 hqfang nucleisys    4096 Aug 10  2021 jre/
-rwxr-xr-x  1 hqfang nucleisys   61928 Sep  3  2020 NucleiStudio
-rw-r--r--  1 hqfang nucleisys     530 Aug 10  2021 NucleiStudio.ini
-rw-rw-r--  1 hqfang nucleisys 9504982 Apr  1  2022 Nuclei_Studio_User_Guide.pdf
drwxr-xr-x  4 hqfang nucleisys    4096 Apr  6  2022 p2/
drwxr-xr-x 13 hqfang nucleisys   69632 Apr  1  2022 plugins/
drwxr-xr-x  2 hqfang nucleisys    4096 Sep 22  2020 readme/
drwxrwxr-x  5 hqfang nucleisys    4096 Apr  1  2022 toolchain/
-rw-rw-r--  1 hqfang nucleisys       0 Apr  1  2022 Ver.2022-04.txt
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
# Make sure your are in tflm repo directory
cd /path/to/tensorflow
# cd to where this script located
cd tensorflow/lite/micro/nuclei_demosoc
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

~~~shell
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
## 5. Build and run all test cases on qemu for CORE=n300f ARCH_EXT=p
## Need to use 4M ilm linker script file LINKER_SCRIPT=tensorflow/lite/micro/nuclei_demosoc/gcc_ilm_4M.ld
make -f tensorflow/lite/micro/tools/make/Makefile TARGET=nuclei_demosoc SIMU=qemu CORE=n300f ARCH_EXT=p OPTIMIZED_KERNEL_DIR=nmsis_nn LINKER_SCRIPT=tensorflow/lite/micro/nuclei_demosoc/gcc_ilm_4M.ld test
## all the test cases will be ran on qemu, and show Pass Rate
~~~

If you want to run on hardware, you can download this built elf using openocd and gdb, and run on
hardware, and make sure the bitstream you programmed on hardware have at least 512K ILM and 512K DLM.

About how to download prebuilt elf using openocd and gdb, you can follow nuclei-sdk user guide
https://doc.nucleisys.com/nuclei_sdk/quickstart.html#debug-application , and when you enter to gdb command line,
you can type following command to download program.

~~~shell
# reset cpu core and halt
(gdb) monitor reset halt
# load application
(gdb) load /path/to/tflite-micro/prebuilt_elf
# example command to load prebuilt elf
# (gdb) load /home/lab/tensorflow/lite/micro/tools/make/gen/nuclei_demosoc_nx600fdp_micro/bin/micro_speech_test
# resume core execution
(gdb) monitor resume
# quit gdb
(gdb) quit
~~~

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

## Run all test cases for different CORE and ARCH_EXT

In this folder, we provided a script to run test all the cases in qemu in one script.

> Many cases required large memory, so we use 4M ilm linker script located in gcc_ilm_4M.ld

~~~shell
LOGDIR=gentest0.37 bash testall.sh
# current version status on qemu
find gentest0.37 -name "run.log" | xargs grep "Pass Rate"
#gentest0.37/nx900f/p/run.log:Target nx900fp, Pass Rate(115/115)=100.00%
#gentest0.37/nx900f/v/run.log:Target nx900fv, Pass Rate(111/115)=96.52%
#gentest0.37/nx900f/pv/run.log:Target nx900fpv, Pass Rate(114/115)=99.13%
#gentest0.37/nx900f/ref/run.log:Target nx900f, Pass Rate(115/115)=100.00%
#gentest0.37/n900fd/p/run.log:Target n900fdp, Pass Rate(115/115)=100.00%
#gentest0.37/n900fd/ref/run.log:Target n900fd, Pass Rate(115/115)=100.00%
#gentest0.37/n600f/p/run.log:Target n600fp, Pass Rate(115/115)=100.00%
#gentest0.37/n600f/ref/run.log:Target n600f, Pass Rate(115/115)=100.00%
#gentest0.37/nx900fd/p/run.log:Target nx900fdp, Pass Rate(115/115)=100.00%
#gentest0.37/nx900fd/v/run.log:Target nx900fdv, Pass Rate(111/115)=96.52%
#gentest0.37/nx900fd/pv/run.log:Target nx900fdpv, Pass Rate(114/115)=99.13%
#gentest0.37/nx900fd/ref/run.log:Target nx900fd, Pass Rate(115/115)=100.00%
#gentest0.37/n205/p/run.log:Target n205p, Pass Rate(115/115)=100.00%
#gentest0.37/n205/ref/run.log:Target n205, Pass Rate(115/115)=100.00%
#gentest0.37/n300/p/run.log:Target n300p, Pass Rate(115/115)=100.00%
#gentest0.37/n300/ref/run.log:Target n300, Pass Rate(115/115)=100.00%
#gentest0.37/nx900/p/run.log:Target nx900p, Pass Rate(115/115)=100.00%
#gentest0.37/nx900/ref/run.log:Target nx900, Pass Rate(115/115)=100.00%
# current implemented nmsis-nn fully_connected_s8 api has some issue in it for vector optimized
# please take care
~~~

This script will run all the test cases and record run log into log file.

## FAQs

### Default ilm/dlm size in demosoc is 64K/64K, need to change it to 512K to run these cases

If you met issue like this: `section \`.text' will not fit in region \`ilm'`, this is caused by ilm size is not big enough to store the code, 64K is not enough to run this application, please use 512K, if you want to run on hardware,
please make sure your hardware configured with 512K ILM/DLM.

Some cases may need to change to bigger ilm/dlm to run on qemu, such as 4M.

Now this patching step is done by build system, no need to do any more steps.

~~~shell
sed -i "s/64K/512K/g" /path/to/tensorflow/lite/micro/tools/make/downloads/nuclei_sdk/SoC/demosoc/Board/nuclei_fpga_eval/Source/GCC/gcc_demosoc_ilm.ld
~~~

### Error 35 downloading 'https://github.com/Nuclei-Software/nuclei-sdk/archive/refs/tags/0.3.8.zip'

If you don't have good network connection, you may met following issue.

~~~shell
tensorflow/lite/micro/tools/make/downloads/nuclei_sdk patch_nuclei_sdk
downloading https://github.com/Nuclei-Software/nuclei-sdk/archive/refs/tags/0.3.8.zip
curl: (35) OpenSSL SSL_connect: SSL_ERROR_SYSCALL in connection to github.com:443
+ [[ 35 -eq 0 ]]
+ [[ 35 -ne 56 ]]
+ echo 'Error 35 downloading '\''https://github.com/Nuclei-Software/nuclei-sdk/archive/refs/tags/0.3.8.zip'\'''
Error 35 downloading 'https://github.com/Nuclei-Software/nuclei-sdk/archive/refs/tags/0.3.8.zip'
~~~

Then you need to manually delete the empty folder `tensorflow/lite/micro/tools/make/downloads/nuclei_sdk`, and you can follow
the [Setup](#setup) steps to prepare environment.

### These files are also needed to be downloaded

TFLM build system need to download third party files, so it required good network connection, and the files
are downloaded and extracted to `tensorflow/lite/micro/tools/make/downloads/`

~~~shell
flatbuffers/  gemmlowp/  kissfft/  nuclei_sdk/  pigweed/  ruy/ nuclei_studio/
~~~

### collect2: error: ld returned 1 exit status

If you failed to compile application using above steps, and met issue as below

~~~shell
/home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/bin/ld: warning: cannot find entry symbol _start; defaulting to 0000000080000000
/home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/bin/ld: /home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/lib/rv64imafdc/lp64d/libc_nano.a(lib_a-isattyr.o): in function `.L0 ':
isattyr.c:(.text._isatty_r+0x12): warning: _isatty is not implemented and will always fail
collect2: error: ld returned 1 exit status
/home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/bin/ld: /home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/lib/rv64imafdc/lp64d/libc_nano.a(lib_a-signalr.o): in function `.L0 ':
signalr.c:(.text._kill_r+0x14): warning: _kill is not implemented and will always fail
/home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/bin/ld: /home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/lib/rv64imafdc/lp64d/libc_nano.a(lib_a-lseekr.o): in function `.L0 ':
lseekr.c:(.text._lseek_r+0x16): warning: _lseek is not implemented and will always fail
make: *** [tensorflow/lite/micro/examples/micro_speech/Makefile.inc:230: tensorflow/lite/micro/tools/make/gen/nuclei_demosoc_nx900fdpv_micro/bin/micro_features_generator_test] Error 1
/home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/bin/ld: /home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/lib/rv64imafdc/lp64d/libc_nano.a(lib_a-readr.o): in function `.L0 ':
readr.c:(.text._read_r+0x16): warning: _read is not implemented and will always fail
/home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/bin/ld: /home/share/devtools/nucleistudio/2022.04/NucleiStudio/toolchain/gcc/bin/../lib/gcc/riscv-nuclei-elf/10.2.0/../../../../riscv-nuclei-elf/lib/rv64imafdc/lp64d/libc_nano.a(lib_a-writer.o): in function `.L0 ':
writer.c:(.text._write_r+0x16): warning: _write is not implemented and will always fail
~~~

Then you clean the project first by adding `CLEAN=1`, such as steps below

~~~shell
# Make sure your are in tflm repo directory
cd /path/to/tensorflow
# cd to where this script located
cd tensorflow/lite/micro/nuclei_demosoc
# Assume CORE and ARCH_EXT environment variable are exported 
# clean project first before run micro_speech_test provided in micro_speech example
CLEAN=1 ./run.sh micro_speech_test
~~~
