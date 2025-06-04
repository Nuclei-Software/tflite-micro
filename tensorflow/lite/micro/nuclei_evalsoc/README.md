# Nuclei RISC-V Processors

This folder contains some source files to support building and running for `TARGET=nuclei_evalsoc`.This folder also contains some scripts to run test and examples automatically.

It is designed to be portable even to 'bare metal', so it follows the same design goals as the micro experimental port.

# How to quick explore it

This TFLM support is done based on Nuclei SDK 0.8.0 release, see https://github.com/Nuclei-Software/nuclei-sdk/releases/tag/0.8.0

It mainly works on Nuclei Evaluation SoC, an fpga prototype SoC to test different kinds of Nuclei RISC-V Processor.

## Install TFLM

Here are two ways to install tflm(tflite micro)：

1. [Terminal](#1-install-tflm-in-terminal)
2. [Dockerfile](#2-install-tflm-in-docker) (easy and quick)

### 1. Install TFLM in terminal

**step1: Install third party requirements**

~~~shell
sudo apt install -y python3-pip
pip3 install Pillow
pip3 install Wave
~~~

**step2: Setup**

> Please make sure the following steps are executed.
  Make sure you have good network connection to download files in tensorflow/lite/micro/tools/make/third_party_downloads.inc

1. Setup Third Party Files

Some third party files are also required to be downloaded, but it might fail due to bad connection. So we prepare the predownload folder `downloads` exclude only `nuclei_studio`, include `nuclei_sdk`.

Please download `tflm_third_downloads_0.8.0.zip` from https://drive.weixin.qq.com/s?k=ABcAKgdSAFcg1gQYi2

~~~shell
# Make sure your are in tflm repo directory
cd /path/to/tensorflow
cd tensorflow/lite/micro/tools/make
# make sure no downloads in this directory exist, if yes, backup it as need and then remove it
mv downloads downloads_old
unzip /path/to/tflm_third_downloads_0.8.0.zip
ls -l downloads
drwxr-xr-x 34 hqfang hqfang 4096 Feb  9 10:59 flatbuffers/
drwxr-xr-x 15 hqfang hqfang 4096 Feb  9 11:06 gemmlowp/
drwxr-xr-x  5 hqfang hqfang 4096 Feb  9 11:05 kissfft/
drwxr-xr-x 11 hqfang hqfang 4096 Feb  9 11:06 nuclei_sdk/
drwxr-xr-x 79 hqfang hqfang 4096 Feb  9 11:05 pigweed/
drwxr-xr-x  7 hqfang hqfang 4096 Feb  9 11:06 ruy/
~~~

2. Setup Nuclei Studio for TFLM

Download Nuclei Studio 2025.02 from https://nucleisys.com/download.php and extract it.

Setup up path for build system.

~~~shell
# Make sure your are in tflm repo directory
cd /path/to/tensorflow/lite/micro/tools/make/downloads/

# make sure no nuclei_studio in this directory exist, if yes, backup it as need and then remove it
# MUST do soft link here and remove existing nuclei_studio if exist
ln -s /path/to/NucleiStudio_IDE_202502 nuclei_studio
~~~

3. Setup Nuclei SDK for TFLM

> If you download and installed ``third_party_downloads_0.8.0.zip``, then there is no need to install nuclei sdk.
>
> If you are porting this TFLM to your SoC, please take care to use the same version of NMSIS DSP/NN used in
> nuclei sdk 0.8.0 version which is currently supported in this version of TFLM.

Manually download nuclei-sdk 0.8.0 from github release or wework share link:

- github release: https://github.com/Nuclei-Software/nuclei-sdk/releases/tag/0.8.0
- wework share link: https://drive.weixin.qq.com/s?k=ABcAKgdSAFcJtLJpjE

~~~shell
# Make sure your are in tflm repo directory
cd /path/to/tensorflow
cd tensorflow/lite/micro/tools/make/downloads/
# unzip the downloaded nuclei-sdk 0.8.0 release zip nuclei-sdk-0.8.0.zip
# make sure no nuclei_sdk in this directory exist, if yes, backup it as need and then remove it
unzip /path/to/nuclei-sdk-0.8.0.zip
mv nuclei-sdk-0.8.0 nuclei_sdk
~~~

4. Check the setup

If you have setup the environment, please check that should contains files as below.

~~~shell
# Make sure your are in tflm repo directory
cd /path/to/tensorflow
cd tensorflow/lite/micro/tools/make/downloads/
# list required third party files
$ ls -l
total 24
drwxrwxr-x 36 jdqiu jdqiu 4096 Jan 17 18:50 flatbuffers/
drwxrwxr-x 15 jdqiu jdqiu 4096 Jul 25 10:52 gemmlowp/
drwxrwxr-x  5 jdqiu jdqiu 4096 Jul 25 10:49 kissfft/
drwxrwxr-x 12 jdqiu jdqiu 4096 Jan 17 18:37 nuclei_sdk/
lrwxrwxrwx  1 jdqiu jdqiu   30 Jan 20 10:19 nuclei_studio -> /home/share/devtools/nucleistudio/2025.02/ # this is a soft link to existing nuclei studio
drwxrwxr-x 79 jdqiu jdqiu 4096 Jul 25 10:50 pigweed/
drwxrwxr-x  7 jdqiu jdqiu 4096 Jul 25 10:52 ruy/
# check nuclei_sdk folder
$ ls -l nuclei_sdk/
total 104
drwxrwxr-x 7 jdqiu jdqiu  4096 Jan 17 18:37 application/
drwxrwxr-x 4 jdqiu jdqiu  4096 Jan 17 18:37 Build/
drwxrwxr-x 3 jdqiu jdqiu  4096 Jan 17 18:37 Components/
drwxrwxr-x 3 jdqiu jdqiu  4096 Jan 17 18:37 doc/
drwxrwxr-x 3 jdqiu jdqiu  4096 Jan 17 18:37 ideprojects
-rw-rw-r-- 1 jdqiu jdqiu 11357 Jan 17 18:37 LICENSE
-rw-rw-r-- 1 jdqiu jdqiu  2643 Jan 17 18:37 Makefile
drwxrwxr-x 6 jdqiu jdqiu  4096 Jan 17 18:37 NMSIS/
-rw-rw-r-- 1 jdqiu jdqiu     7 Jan 17 18:37 NMSIS_VERSION
-rw-rw-r-- 1 jdqiu jdqiu   517 Jan 17 18:37 npk.yml
drwxrwxr-x 6 jdqiu jdqiu  4096 Jan 17 18:37 OS/
-rw-rw-r-- 1 jdqiu jdqiu   310 Jan 17 18:37 package.json
-rw-rw-r-- 1 jdqiu jdqiu 14440 Jan 17 18:37 README.md
-rw-rw-r-- 1 jdqiu jdqiu  6782 Jan 17 18:37 SConscript
-rw-rw-r-- 1 jdqiu jdqiu   537 Jan 17 18:37 setup.bat
-rw-rw-r-- 1 jdqiu jdqiu   723 Jan 17 18:37 setup.ps1
-rw-rw-r-- 1 jdqiu jdqiu   569 Jan 17 18:37 setup.sh
drwxrwxr-x 5 jdqiu jdqiu  4096 Jan 17 18:37 SoC/
drwxrwxr-x 3 jdqiu jdqiu  4096 Jan 17 18:37 test/
drwxrwxr-x 3 jdqiu jdqiu  4096 Jan 17 18:37 tools/
$ ls -l nuclei_studio/NucleiStudio/
total 32548
-rw-r--r--   1 jdqiu jdqiu   580254 Jul  3  2024 artifacts.xml
drwxr-xr-x  12 jdqiu jdqiu     4096 Dec 16 16:57 configuration/
drwxr-xr-x   2 jdqiu jdqiu     4096 Jun  6  2024 dropins/
drwxr-xr-x 116 jdqiu jdqiu    12288 Jul  3  2024 features/
-rwxr-xr-x   1 jdqiu jdqiu   140566 Jun  6  2024 icon.xpm
-rw-r--r--   1 jdqiu jdqiu     1424 Jul  3  2024 install.sh
-rw-r--r--   1 jdqiu jdqiu     9260 Jun  4  2024 notice.html
-rwxr-xr-x   1 jdqiu jdqiu    90184 Jun  6  2024 NucleiStudio
-rw-r--r--   1 jdqiu jdqiu     1142 Jul  3  2024 NucleiStudio.ini
-rw-r--r--   1 jdqiu jdqiu 32376424 Jul  3  2024 NucleiStudio_User_Guide.pdf
drwxr-xr-x   5 jdqiu jdqiu     4096 Dec 16 16:58 p2/
drwxr-xr-x  13 jdqiu jdqiu    65536 Jul  3  2024 plugins/
drwxr-xr-x   2 jdqiu jdqiu     4096 Jul  3  2024 readme/
drwxr-xr-x  10 jdqiu jdqiu     4096 Jul  3  2024 toolchain/
-rw-r--r--   1 jdqiu jdqiu      149 Jul  3  2024 Ver.2024-06.txt
~~~

### 2. Install TFLM in docker

With Docker, you can install your software environment quickly.

**step1: prepare**

Download dockerfile, link is here [Dockerfile](./Dockerfile) 

Download ``tflm_third_downloads_0.8.0.zip`` from https://drive.weixin.qq.com/s?k=ABcAKgdSAFcg1gQYi2

Download ``Nuclei Studio 2025.02`` from https://nucleisys.com/download.php

Then, Copy them to your workdir.

~~~sh
$ mkdir workdir
$ cd workdir
# copy to workdir
$ ls
Dockerfile  NucleiStudio_IDE_202502-lin64.tgz  tflm_third_downloads_0.8.0.zip
~~~

**step2: build docker images**

~~~sh
$ sudo docker build -f Dockerfile -t nuclei_tflm:v0.8.0 .
~~~

**step3: build docker images**

~~~sh
$ sudo docker run -ti localhost/nuclei_tflm:v0.8.0
~~~

## Run

A script called `run.sh` is provided to quickly build and run on qemu.

~~~shell
./run.sh <example_name> [test_case]
~~~

* example_name: required argument, stand for the example name to be run. such as `hello_world`, `micro_speech_test`, `person_detection` and etc.
  Examples can be found in *tensorflow/lite/micro/examples*

Example usage:

~~~shell
# Make sure your are in tflm repo directory
cd /path/to/tensorflow
# cd to where this script located
cd tensorflow/lite/micro/nuclei_evalsoc
## current CORE is nx900fd, RISV-ARCH is rv64imafdc
# select your CORE, for example, n205, n900fd
## Support CORE list can be found in SUPPORTED_CORES
## in tensorflow/lite/micro/tools/make/targets/nuclei_evalsoc_corearchabi.inc
## for example, select CORE nx900fd
export CORE=nx900fd
# select your ARCH_EXT, for example, _xxldsp, v_xxldsp
## _xxldsp_: p extension present
## v_xxldsp: p and v extension present
export ARCH_EXT=v_xxldsp
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
# CORE, ARCH_EXT, DOWNLOAD, SIMU are new introduced make variables supppored by TARGET=nuclei_evalsoc
## CORE can be set to be one of the SUPPORTED_CORES in tensorflow/lite/micro/tools/make/targets/nuclei_evalsoc_corearchabi.inc
## such as CORE=nx900f
## ARCH_EXT can be set to empty or _xxldsp, v, v_xxldsp
## such as ARCH_EXT=_xxldsp ARCH_EXT= ARCH_EXT=v_xxldsp
## ARCH_EXT= means no p/v extension is selected, and will use pure-c optimized NMSIS-NN library
## DOWNLOAD can be one of the ilm/flashxip/flash/ddr
## SIMU can be qemu, when set to qemu, it can auto-exit qemu running, if return from main
# You can set OPTIMIZED_KERNEL_DIR=nmsis_nn to select optimized nmsis_nn tflite-micro kernels
### Examples
## 1. Build kernel_conv_test for n300f with p extension, and optimized with nmsis_nn
make -f tensorflow/lite/micro/tools/make/Makefile TARGET=nuclei_evalsoc SIMU=qemu CORE=n300f ARCH_EXT=_xxldsp OPTIMIZED_KERNEL_DIR=nmsis_nn kernel_conv_test
## 2. If you want to run on qemu, SIMU=qemu is required to pass to make, and clean project and rebuild is required
make -f tensorflow/lite/micro/tools/make/Makefile TARGET=nuclei_evalsoc SIMU=qemu CORE=n300f ARCH_EXT=_xxldsp OPTIMIZED_KERNEL_DIR=nmsis_nn clean
## 3. Build and run on qemu for kernel_conv_test
make -f tensorflow/lite/micro/tools/make/Makefile TARGET=nuclei_evalsoc SIMU=qemu CORE=n300f ARCH_EXT=_xxldsp OPTIMIZED_KERNEL_DIR=nmsis_nn test_kernel_conv_test
## 4. Build and run on qemu for micro_speech_test without nmsis_nn optimized kernel for nx600fd with p extension
make -f tensorflow/lite/micro/tools/make/Makefile TARGET=nuclei_evalsoc SIMU=qemu CORE=nx600fd ARCH_EXT=_xxldsp test_micro_speech_test
## The build elf can be found in gen/nuclei_evalsoc_nx600fd_xxldsp_micro/bin/
# for micro_speech_test, it should be gen/nuclei_evalsoc_nx600fd_xxldsp_micro/bin/micro_speech_test
## 5. Build and run all test cases on qemu for CORE=n300f ARCH_EXT=_xxldsp
## Need to use 8M ilm linker script file LINKER_SCRIPT=tensorflow/lite/micro/nuclei_evalsoc/gcc_ilm_8M.ld
make -f tensorflow/lite/micro/tools/make/Makefile TARGET=nuclei_evalsoc SIMU=qemu CORE=n300f ARCH_EXT=_xxldsp OPTIMIZED_KERNEL_DIR=nmsis_nn LINKER_SCRIPT=tensorflow/lite/micro/nuclei_evalsoc/gcc_ilm_8M.ld test
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
# (gdb) load /home/lab/tensorflow/lite/micro/tools/make/gen/nuclei_evalsoc_nx600fdp_micro/bin/micro_speech_test
# resume core execution
(gdb) monitor resume
# quit gdb
(gdb) quit
~~~

### Run all examples for different CORE and ARCH_EXT

In this folder, we provided a script [runall.sh](runall.sh) to run all examples in one script.

~~~shell
bash runall.sh
# current version status on qemu
find gen -name "run.log" | xargs grep Pass
gen/n205/ref/run.log:n205 Pass/Total: 10/10=100.000%
gen/n300/ref/run.log:n300 Pass/Total: 10/10=100.000%
gen/n300/_xxldsp/run.log:n300_xxldsp Pass/Total: 10/10=100.000%
gen/n300fd/_xxldspn3x/run.log:n300fd_xxldspn3x Pass/Total: 10/10=100.000%
gen/n600f/ref/run.log:n600f Pass/Total: 10/10=100.000%
gen/n600f/_zve32f/run.log:n600f_zve32f Pass/Total: 10/10=100.000%
gen/n600f/_xxldsp/run.log:n600f_xxldsp Pass/Total: 10/10=100.000%
gen/n600f/_zve32f_xxldsp/run.log:n600f_zve32f_xxldsp Pass/Total: 10/10=100.000%
gen/n900fd/ref/run.log:n900fd Pass/Total: 10/10=100.000%
gen/n900fd/_zve32f/run.log:n900fd_zve32f Pass/Total: 10/10=100.000%
gen/n900fd/_xxldsp/run.log:n900fd_xxldsp Pass/Total: 10/10=100.000%
gen/n900fd/_zve32f_xxldsp/run.log:n900fd_zve32f_xxldsp Pass/Total: 10/10=100.000%
gen/nx900/ref/run.log:nx900 Pass/Total: 10/10=100.000%
gen/nx900/_xxldsp/run.log:nx900_xxldsp Pass/Total: 10/10=100.000%
gen/nx900f/ref/run.log:nx900f Pass/Total: 10/10=100.000%
gen/nx900f/_zve64f/run.log:nx900f_zve64f Pass/Total: 10/10=100.000%
gen/nx900f/_xxldsp/run.log:nx900f_xxldsp Pass/Total: 10/10=100.000%
gen/nx900f/_zve64f_xxldsp/run.log:nx900f_zve64f_xxldsp Pass/Total: 10/10=100.000%
gen/nx900fd/ref/run.log:nx900fd Pass/Total: 10/10=100.000%
gen/nx900fd/v/run.log:nx900fdv Pass/Total: 10/10=100.000%
gen/nx900fd/_xxldsp/run.log:nx900fd_xxldsp Pass/Total: 10/10=100.000%
gen/nx900fd/v_xxldsp/run.log:nx900fdv_xxldsp Pass/Total: 10/10=100.000%
~~~

This script will run all the application and record run log into log file.

### Run all test cases for specified CORE and ARCH_EXT

In this folder, we provided a script [test.sh](test.sh) to test all the cases for specified `CORE` and `ARCH_EXT`.

> Many cases required large memory, so we use 8M ilm linker script located in gcc_ilm_8M.ld

~~~shell
CORE=nx900fd ARCH_EXT=v_xxldsp bash test.sh
~~~

### Run all test cases for different CORE and ARCH_EXT

In this folder, we provided a script [testall.sh](testall.sh) to test all the cases in qemu in one script.

> Many cases required large memory, so we use 8M ilm linker script [gcc_ilm_8M.ld](./gcc_ilm_8M.ld)

~~~shell
LOGDIR=gentest bash testall.sh
# current version status on qemu
find gentest -name "run.log" | xargs grep "Pass Rate"
gentest/n205/ref/run.log:Target n205, Pass Rate(127/127)=100.00%
gentest/n300/ref/run.log:Target n300, Pass Rate(127/127)=100.00%
gentest/n300/_xxldsp/run.log:Target n300_xxldsp, Pass Rate(127/127)=100.00%
gentest/n300fd/_xxldspn3x/run.log:Target n300fd_xxldspn3x, Pass Rate(127/127)=100.00%
gentest/n600f/ref/run.log:Target n600f, Pass Rate(127/127)=100.00%
gentest/n600f/_zve32f/run.log:Target n600f_zve32f, Pass Rate(127/127)=100.00%
gentest/n600f/_xxldsp/run.log:Target n600f_xxldsp, Pass Rate(127/127)=100.00%
gentest/n600f/_zve32f_xxldsp/run.log:Target n600f_zve32f_xxldsp, Pass Rate(127/127)=100.00%
gentest/n900fd/ref/run.log:Target n900fd, Pass Rate(127/127)=100.00%
gentest/n900fd/_zve32f/run.log:Target n900fd_zve32f, Pass Rate(127/127)=100.00%
gentest/n900fd/_xxldsp/run.log:Target n900fd_xxldsp, Pass Rate(127/127)=100.00%
gentest/n900fd/_zve32f_xxldsp/run.log:Target n900fd_zve32f_xxldsp, Pass Rate(127/127)=100.00%
gentest/nx900/ref/run.log:Target nx900, Pass Rate(127/127)=100.00%
gentest/nx900/_xxldsp/run.log:Target nx900_xxldsp, Pass Rate(127/127)=100.00%
gentest/nx900f/ref/run.log:Target nx900f, Pass Rate(127/127)=100.00%
gentest/nx900f/_zve64f/run.log:Target nx900f_zve64f, Pass Rate(127/127)=100.00%
gentest/nx900f/_xxldsp/run.log:Target nx900f_xxldsp, Pass Rate(127/127)=100.00%
gentest/nx900f/_zve64f_xxldsp/run.log:Target nx900f_zve64f_xxldsp, Pass Rate(127/127)=100.00%
gentest/nx900fd/ref/run.log:Target nx900fd, Pass Rate(127/127)=100.00%
gentest/nx900fd/v/run.log:Target nx900fdv, Pass Rate(127/127)=100.00%
gentest/nx900fd/_xxldsp/run.log:Target nx900fd_xxldsp, Pass Rate(127/127)=100.00%
gentest/nx900fd/v_xxldsp/run.log:Target nx900fdv_xxldsp, Pass Rate(127/127)=100.00%
~~~

This script will run all the test cases and record run log into log files.

## FAQs

### Default ilm/dlm size in evalsoc is 64K/64K which is not enough

If you met issue like this: `section '.text' will not fit in region 'ilm'`, this is caused by ilm size is not big enough to store the code, 64K is not enough to run this application, please use 512K, if you want to run on hardware, please make sure your hardware has configured with 512K ILM/DLM.

Some cases may need to change to bigger ilm/dlm to run on qemu, such as 8M.

Now this patching step is done by build system, no need to do any more steps.

~~~shell
sed -i "s/0x10000/0x80000/g" /path/to/tensorflow/lite/micro/tools/make/downloads/nuclei_sdk/SoC/evalsoc/Board/nuclei_fpga_eval/Source/GCC/evalsoc.memory
~~~

### Error 35 downloading 'https://github.com/Nuclei-Software/nuclei-sdk/archive/refs/tags/0.8.0.zip'

If you don't have good network connection, you may met following issue.

~~~shell
tensorflow/lite/micro/tools/make/downloads/nuclei_sdk patch_nuclei_sdk
downloading https://github.com/Nuclei-Software/nuclei-sdk/archive/refs/tags/0.8.0.zip
curl: (35) OpenSSL SSL_connect: SSL_ERROR_SYSCALL in connection to github.com:443
+ [[ 35 -eq 0 ]]
+ [[ 35 -ne 56 ]]
+ echo 'Error 35 downloading '\''https://github.com/Nuclei-Software/nuclei-sdk/archive/refs/tags/0.8.0.zip'\'''
Error 35 downloading 'https://github.com/Nuclei-Software/nuclei-sdk/archive/refs/tags/0.8.0.zip'
~~~

Then you need to manually delete the empty folder `tensorflow/lite/micro/tools/make/downloads/nuclei_sdk`, and you can follow
the [Install TFLM](#install-tflm) steps to prepare environment.

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
make: *** [tensorflow/lite/micro/examples/micro_speech/Makefile.inc:230: tensorflow/lite/micro/tools/make/gen/nuclei_evalsoc_nx900fdpv_micro/bin/micro_features_generator_test] Error 1
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
cd tensorflow/lite/micro/nuclei_evalsoc
# Assume CORE and ARCH_EXT environment variable are exported 
# clean project first before run micro_speech_test provided in micro_speech example
CLEAN=1 ./run.sh micro_speech_test
~~~

### qemu-system-riscv64 missing library not able to execute

Please execute `ldd $(which qemu-system-riscv64)` to check the missing libraries, and then
you can try to search missing libraries using `apt search` and install it.

Normally most will be solved by install `libglib2.0-0 libpixman-1-0`

### declared 'static' but never defined [-Werror=unused-function]

Need to add extra compiler option `-Wno-unused-function` in **PLATFORM_FLAGS** of
`tensorflow/lite/micro/tools/make/targets/nuclei_evalsoc_makefile.inc`.

### svdf.cc:272:7: error: cannot convert 'int16_t*' {aka 'short int*'} to 'q7_t*' {aka 'signed char*'}

If you are using NMSIS DSP/NN 1.1.0, you may face issue below.

~~~shell
tensorflow/lite/micro/kernels/nmsis_nn/svdf.cc:272:7: error: cannot convert 'int16_t*' {aka 'short int*'} to 'q7_t*' {aka 'signed char*'}
  272 |       (int16_t*)tflite::micro::GetTensorData<int16_t>(activation_state_tensor),
      |       ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      |       |
      |       int16_t* {aka short int*}
~~~

Using NMSIS DSP/NN 1.1.1 will fix this issue. Or update to Nuclei SDK 0.6.0 or higher version.

### Simple steps about how to port to Nuclei Subsystem SDK

1. Make sure the NMSIS version is v1.4.0 (Corresponding nuclei SDK version is v0.8.0), if not, please change to this version.
2. Adapt [nuclei_evalsoc_makefile.inc](../tools/make/targets/nuclei_evalsoc_makefile.inc) with proper compiler flags and linker flags.
3. If you are using Nuclei RISC-V CPU, please select correct `CORE` and `ARCH_EXT` according to [nuclei_evalsoc_corearchabi.inc](../tools/make/targets/nuclei_evalsoc_corearchabi.inc).
  For example, if your RISC-V ARCH is `rv32imafdc`, and CPU is 300 series, then select `CORE=n300fd`,
  if you have extra p/v extension, such as p, then `ARCH_EXT` should be `ARCH_EXT=_xxldsp`
4. Then `DOWNLOAD` should set to correct mode to match the linker script file you want to use
5. Most of the tflm examples require a lot of ram and rom, so some examples may link fail if you don't have
   enough memory.
6. Test the build via `CLEAN=1 CORE=n300fd ARCH_EXT=p NUCLEI_SDK_ROOT=/path/to/your_subsystem_sdk ./run.sh micro_speech_test`

### Where is 'nuclei_demosoc'

In branch `nuclei/nsdk_0.3.8`, we use `nuclei_demosoc` as `TARGET`, but in Nuclei SDK 0.6.0 and higher version, `nuclei_demosoc` has been replaced with `nuclei_evalsoc`.
