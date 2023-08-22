#
# Docker image of tflm (nuclei)
#
FROM ubuntu:20.04

MAINTAINER nuclei

ENV WORK_PATH /home
WORKDIR ${WORK_PATH}

# Install packages required to build
RUN apt update          \
    &&                  \
    apt install -y git  \
        make            \
        python3-pip     \
        unzip           \
        libpixman-1-dev \
        vim             \
        bc              \
    &&                  \
    pip3 install Pillow -i https://pypi.tuna.tsinghua.edu.cn/simple  \
    &&                                                               \
    pip3 install Wave -i https://pypi.tuna.tsinghua.edu.cn/simple    \
    &&                                                               \
    pip3 install numpy -i https://pypi.tuna.tsinghua.edu.cn/simple

RUN DEBIAN_FRONTEND=noninteractive apt install -y libglib2.0-dev

# Git clone tflm
RUN git clone -b nuclei/nsdk_0.4.1 https://github.com/Nuclei-Software/tflite-micro.git

# Download Nuclei toolchain and third part
ENV TFLM_ROOT ${WORK_PATH}/tflite-micro
ENV TFLM_DOWNLOADS ${TFLM_ROOT}/tensorflow/lite/micro/tools/make/downloads
ENV TFLM_WORK ${TFLM_ROOT}/tensorflow/lite/micro/nuclei_evalsoc

WORKDIR $TFLM_DOWNLOADS
COPY NucleiStudio_IDE_202212-lin64.tgz .
COPY tflm_third_downloads_0.4.1.zip .
RUN tar -zxvf NucleiStudio_IDE_202212-lin64.tgz > /dev/null \
    &&                                                      \
    ln -s NucleiStudio_IDE_202212 nuclei_studio

RUN unzip tflm_third_downloads_0.4.1.zip  > /dev/null \
    &&                                                \
    cp downloads/* . -rf                              \
    &&                                                \
    sed -i "s/64K/512K/g" nuclei_sdk/SoC/evalsoc/Board/nuclei_fpga_eval/Source/GCC/gcc_evalsoc_ilm.ld

# Check file preparare OK
RUN ls -l

WORKDIR $TFLM_WORK


