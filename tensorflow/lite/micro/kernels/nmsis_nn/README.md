# Introduction

NMSIS-NN is a library containing kernel optimizations for Nuclei RISC-V Processors.
Nuclei RISC-V Processor contains 200/300/600/900 series, which provides different performance,
and have different RISC-V standard extension, such B/P/V extension, which can be used to speed up
AI computing.

NMSIS-NN is optimized using P/V extesion, and also provided optimized pure c libraries which is
now integrated into TFLite-Micro.

To use NMSIS-NN optimized kernels instead of reference kernels, add
`OPTIMIZED_KERNEL_DIR=nmsis_nn` to the make command line. See [example](#example---run-on-nuclei-evalsoc-qemu-machine) below.

For more information about the optimizations, check out [NMSIS-NN documentation](https://doc.nucleisys.com/nmsis/nn/index.html).

By default Nuclei-SDK is downloaded to the TFLM tree, and inside Nuclei-SDK there is a prebuilt NMSIS-NN library.

And it is also possible to use prebuilt NMSIS-NN library built in NMSIS source code,
if you have that version of prebuilt library, you can specify `NUCLEI_SDK_NMSIS=</path/to/NMSIS/NMSIS>`.

# Example - Run on Nuclei Evalsoc QEMU machine.

Building the kernel convolution unit test.

For more information about this specific target, check out [Nuclei RISC-V Processors](../../nuclei_evalsoc/README.md).

Using prebuilt NMSIS-NN library prebuilt in downloaded Nuclei SDK.

```
make -f tensorflow/lite/micro/tools/make/Makefile OPTIMIZED_KERNEL_DIR=nmsis_nn TARGET=nuclei_evalsoc kernel_conv_test
```

Using prebuilt NMSIS-NN library built in NMSIS repo, not the one in Nuclei SDK.

```
make -f tensorflow/lite/micro/tools/make/Makefile OPTIMIZED_KERNEL_DIR=nmsis_nn NUCLEI_SDK_NMSIS=<external/path/to/NMSIS/NMSIS> TARGET=nuclei_evalsoc kernel_conv_test
```

**Notice:**

- Performance and/or size might be affected when using external NMSIS-NN library as different compiler options may have been used.
- External prebuilt NMSIS-NN library need to be built successfully before using it, and make sure you are using a compatiable version.
- Current intergated NMSIS-NN version is 1.2.1 provides the following optimized kernels:
  - [x] add (int8/int16)
  - [x] depthwise_conv_2d (int4/int8/int16)
  - [x] fully_connected (int4/int8/int16)
  - [x] mul (int8/int16)
  - [x] average_pool_2d (int8/int16)
  - [x] max_pool_2d (int8/int16)
  - [x] softmax (int8/int16)
  - [x] svdf (int8/int16)
  - [ ] conv_2d
  - [ ] transpose_conv
  - [ ] unidirectional_sequence_lstm
  - [ ] mean
  - [ ] reduce_max
  - [ ] sum
  - [ ] ... 
  
  all kernel operations are listed in [micro_ops.h](../micro_ops.h), except kernel operations listed above, other kernels are also not optimized yet.

- The ILM/DLM size are not 64K, it is changed to 512K, so if you want to run on hardware, please take care the ILM/DLM size in Soc running on your FPGA board.
