TARGET_TOOLCHAIN_PREFIX := riscv-nuclei-elf-
CORE ?= nx900fd
ARCH_EXT ?= pv
DOWNLOAD ?= ilm
SIMU ?=

override BUILD_TYPE := micro
override TARGET_ARCH := $(CORE)$(ARCH_EXT)

uc = $(shell echo $(1) | tr a-z A-Z)
lc = $(shell echo $(1) | tr A-Z a-z)
check_item_exist = $(strip $(if $(filter 1, $(words $(1))),$(filter $(1), $(sort $(2))),))

include $(MAKEFILE_DIR)/targets/nuclei_demosoc_corearchabi.inc

CORE_UPPER := $(call uc, $(CORE))
CORE_ARCH_ABI := $($(CORE_UPPER)_CORE_ARCH_ABI)
ifeq ($(filter $(CORE), $(SUPPORTED_CORES)),)
$(error Here we only support these cores: $(SUPPORTED_CORES))
endif
# Check whether CORE_ARCH_ABI is presented for CORE
ifneq ($(words $(wordlist 1, 2, $(CORE_ARCH_ABI))), 2)
$(error No correct CORE_ARCH_ABI setting for CORE=$(CORE) found in $(realpath $(MAKEFILE_DIR)/targets/nuclei_demosoc_corearchabi.inc)
endif

# Handle Nuclei RISC-V ARCH/ABI/CMODEL/TUNE
## ARCH_EXT could be combination of in order of bkpv, legal combination is list as below:
## bp: Bitmanip and Packed SIMD Extension present
## bpv: Bitmanip, Packed SIMD and Vector Extension present
## bkpv: Bitmanip, Packed SIMD, Scalar Cryptography and Vector Extension present
RISCV_ARCH ?= $(word 1, $(CORE_ARCH_ABI))$(ARCH_EXT)
RISCV_ABI ?= $(word 2, $(CORE_ARCH_ABI))
RISCV_TUNE ?= $(word 3, $(CORE_ARCH_ABI))

DOWNLOAD_UPPER = $(call uc, $(DOWNLOAD))
# Set default RISC_CMODEL=medlow for rv32, otherwise medany
ifeq ($(RISCV_CMODEL),)
ifneq ($(findstring 32,$(RISCV_ABI)),)
override RISCV_CMODEL := medlow
else
override RISCV_CMODEL := medany
endif
endif

$(eval $(call add_third_party_download,$(NUCLEI_STUDIO_URL),$(NUCLEI_STUDIO_MD5),nuclei_studio,))
$(eval $(call add_third_party_download,$(NUCLEI_SDK_URL),$(NUCLEI_SDK_MD5),nuclei_sdk,patch_nuclei_sdk))

TARGET_DEFAULT_TOOLCHAIN_ROOT := $(MAKEFILE_DIR)/downloads/nuclei_studio/NucleiStudio/toolchain/gcc/bin/
TARGET_TOOLCHAIN_ROOT := $(TARGET_DEFAULT_TOOLCHAIN_ROOT)

NUCLEI_SDK_PATH := $(MAKEFILE_DIR)/downloads/nuclei_sdk
NUCLEI_SDK_ROOT ?= $(NUCLEI_SDK_PATH)
NUCLEI_SDK_NMSIS ?= $(NUCLEI_SDK_ROOT)/NMSIS

$(info Using NUCLEI SDK: $(NUCLEI_SDK_ROOT))
$(info Using NMSIS: $(NUCLEI_SDK_NMSIS))

PLATFORM_FLAGS = \
  -march=$(RISCV_ARCH) \
  -mabi=$(RISCV_ABI) \
  -mtune=$(RISCV_TUNE) \
  -mcmodel=$(RISCV_CMODEL) \
  -fno-common \
  -mexplicit-relocs \
  -fno-builtin-printf \
  -fno-exceptions \
  -DTF_LITE_USE_GLOBAL_MIN \
  -DTF_LITE_USE_GLOBAL_MAX \
  -DTF_LITE_MCU_DEBUG_LOG \
  -DTF_LITE_USE_GLOBAL_CMATH_FUNCTIONS \
  -DDOWNLOAD_MODE=DOWNLOAD_MODE_$(DOWNLOAD_UPPER) \
  -DDOWNLOAD_MODE_STRING=\"$(DOWNLOAD_UPPER)\" \
  -D_DEFAULT_SOURCE \
  -fno-unwind-tables \
  -ffunction-sections \
  -fdata-sections \
  -funsigned-char \
  -Wvla \
  -Wall \
  -Wextra \
  -Wsign-compare \
  -Wdouble-promotion \
  -Wshadow \
  -Wunused-variable \
  -Wmissing-field-initializers \
  -Wno-unused-parameter \
  -Wno-write-strings \
  -Wunused-function \
  -fno-delete-null-pointer-checks \
  -fomit-frame-pointer

## SIMU=xlspike/qemu
### enable run on xlspike and qemu auto-exit if return from main
ifneq ($(SIMU),)
SIMULATION_MODE=SIMULATION_MODE_$(call uc, $(SIMU))
PLATFORM_FLAGS += -DSIMULATION_MODE=$(SIMULATION_MODE)
endif
# Add extra cflags for SoC related
ifeq ($(DOWNLOAD),flash)
PLATFORM_FLAGS += -DVECTOR_TABLE_REMAPPED
endif

CXXFLAGS += $(PLATFORM_FLAGS) \
  -fno-threadsafe-statics \
  -fno-use-cxa-atexit \
  -fpermissive \
  -fno-rtti \
  --std=gnu++11

CCFLAGS += $(PLATFORM_FLAGS)


INCLUDES += \
  -I$(NUCLEI_SDK_NMSIS)/Core/Include \
  -I$(NUCLEI_SDK_NMSIS)/DSP/Include \
  -I$(NUCLEI_SDK_NMSIS)/DSP/Include/dsp \
  -I$(NUCLEI_SDK_NMSIS)/NN/Include \
  -I$(NUCLEI_SDK_ROOT)/SoC/demosoc/Board/nuclei_fpga_eval/Include \
  -I$(NUCLEI_SDK_ROOT)/SoC/demosoc/Common/Include


MICROLITE_CC_SRCS += \
  $(wildcard tensorflow/lite/micro/nuclei_demosoc/*.cc)

NUCLEI_SDK_SRCS := \
$(wildcard $(NUCLEI_SDK_ROOT)/SoC/demosoc/Common/Source/Drivers/*.c) \
$(wildcard $(NUCLEI_SDK_ROOT)/SoC/demosoc/Common/Source/GCC/*.S) \
$(wildcard $(NUCLEI_SDK_ROOT)/SoC/demosoc/Common/Source/Stubs/newlib/*.c) \
$(wildcard $(NUCLEI_SDK_ROOT)/SoC/demosoc/Common/Source/*.c) \
$(wildcard $(NUCLEI_SDK_ROOT)/SoC/demosoc/Board/nuclei_fpga_eval/Source/*.c)

THIRD_PARTY_CC_SRCS += $(NUCLEI_SDK_SRCS)

LDFLAGS += \
 -T$(NUCLEI_SDK_ROOT)/SoC/demosoc/Board/nuclei_fpga_eval/Source/GCC/gcc_demosoc_$(DOWNLOAD).ld \
 -Wl,-M,-Map=$(BINDIR)build.map \
 -nostartfiles \
 --specs=nano.specs -u _printf_float \
 --specs=nosys.specs \
 -Wl,--gc-sections -Wl,--check-sections \
 -u _isatty -u _write -u _sbrk -u _read -u _close -u _fstat -u _lseek -u _getpid -u _kill \
 -L$(NUCLEI_SDK_NMSIS)/Library/DSP/GCC \
 -L$(NUCLEI_SDK_NMSIS)/Library/NN/GCC

$(info Use and link with NMSIS DSP/NN library, ARCH=$(RISCV_ARCH))
LDLIBS = -lnmsis_nn_$(RISCV_ARCH) -lnmsis_dsp_$(RISCV_ARCH)

LDFLAGS += $(LDLIBS)

# Excludes memory_arena_threshold_test because of the size difference between
# reference OP and optimized OP.
# see https://github.com/tensorflow/tflite-micro/issues/498
EXCLUDED_TESTS := \
  tensorflow/lite/micro/memory_arena_threshold_test.cc

MICROLITE_TEST_SRCS := $(filter-out $(EXCLUDED_TESTS), $(MICROLITE_TEST_SRCS))

TEST_SCRIPT := tensorflow/lite/micro/testing/test_with_nuclei_qemu.sh

# We are setting this variable to non-zero to allow us to have a custom
# implementation of `make test` for our target
TARGET_SPECIFIC_MAKE_TEST := 1

TEST_TARGET_BINARIES = $(shell ls -1 $(BINDIR)*_test)

test: build
	$(TEST_SCRIPT) "$(TEST_TARGET_BINARIES)" $(TEST_PASS_STRING) $(CORE) "$(ARCH_EXT)" "$(SIMU)"
