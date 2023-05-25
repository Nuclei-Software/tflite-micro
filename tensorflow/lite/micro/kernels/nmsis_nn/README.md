# Introduction

NMSIS-NN is a library containing kernel optimizations for Nuclei RISC-V Processors.
Nuclei RISC-V Processor contains 200/300/600/900 series, which provides different performance,
and have different RISC-V standard extension, such B/P/V extension, which can be used to speed up
AI computing.

NMSIS-NN is optimized using P/V extesion, and also provided optimized pure c libraries which is
now integrated into TFLite-Micro.

To use NMSIS-NN optimized kernels instead of reference kernels, add
`OPTIMIZED_KERNEL_DIR=nmsis_nn` to the make command line. See examples below.

For more information about the optimizations, check out
[NMSIS-NN documentation](https://doc.nucleisys.com/nmsis/nn/index.html).

By default Nuclei-SDK is downloaded to the TFLM tree, and inside Nuclei-SDK there is prebuilt NMSIS-NN library.

And it also possible to use prebuilt NMSIS-NN library built in NMSIS source code,
if you have that version of prebuilt library, you can specify NUCLEI_SDK_NMSIS=</path/to/NMSIS/NMSIS>.

# Example - Run on Nuclei Demosoc QEMU machine.

Building the kernel conv unit test.

For more information about this specific target, check out
[Nuclei Demosoc QEMU software](https://github.com/tensorflow/tflite-micro/blob/main/tensorflow/lite/micro/nuclei-evalsoc/README.md).

Using prebuilt NMSIS-NN library prebuilt in downloaded Nuclei SDK.

```
make -f tensorflow/lite/micro/tools/make/Makefile OPTIMIZED_KERNEL_DIR=nmsis_nn TARGET=nuclei_evalsoc kernel_conv_test
```

Using prebuilt NMSIS-NN library built in NMSIS repo, not the one in Nuclei SDK.

```
make -f tensorflow/lite/micro/tools/make/Makefile OPTIMIZED_KERNEL_DIR=nmsis_nn NUCLEI_SDK_NMSIS=<external/path/to/NMSIS/NMSIS> TARGET=nuclei_evalsoc kernel_conv_test
```

**Notice:**

- Performance and/or size might be affected when using and external NMSIS-NN library as different compiler options may have been used.
- External prebuilt NMSIS-NN library need to be built successfully before using it, and make sure you are using a compatiable version.
- Current intergated NMSIS-NN version is 1.0.4, which don't provide INT16 and dilated conv/deepwise-conv support.
- The ILM/DLM size are not 64K, it is changed to 512K, so if you want to run on hardware, please take care the ILM/DLM size in Soc running on your FPGA board.
