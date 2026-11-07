# SPDX-License-Identifier: GPL-2.0
# Out-of-tree build of the Rockchip RGA3 multicore driver for the mainline kernel.
#
# The in-tree build selected features via Kconfig (CONFIG_ROCKCHIP_RGA_*).
# Out-of-tree those symbols are not in the kernel's autoconf.h, so define the
# minimal-viable set here (matches the validated in-tree config):
#   - IOMMU support (CONFIG_RGA_IOMMU; vendor code normally derives this from
#     CONFIG_RK_IOMMU + CONFIG_ION_ROCKCHIP, neither of which exists out of tree)
#   - fence/async mode (sync_file)
#   - debugfs
# Left off: procfs, ION, thunder-boot, video-reverse, genpool cmd_buf.

# --- kbuild fragment (read when invoked as `make -C $KDIR M=$PWD`) ---
obj-m += rga3.o

rga3-y += rga_drv.o
rga3-y += rga_common.o
rga3-y += rga3_reg_info.o
rga3-y += rga_iommu.o
rga3-y += rga_dma_buf.o
rga3-y += rga_job.o
rga3-y += rga_hw_config.o
rga3-y += rga2_reg_info.o
rga3-y += rga_policy.o
rga3-y += rga_mm.o
rga3-y += rga_fence.o
rga3-y += rga_debugger.o

ccflags-y += -I$(src)/include
ccflags-y += -DCONFIG_RGA_IOMMU=1
ccflags-y += -DCONFIG_ROCKCHIP_RGA_ASYNC=1
ccflags-y += -DCONFIG_ROCKCHIP_RGA_DEBUG_FS=1
ccflags-y += -DCONFIG_ROCKCHIP_RGA_DEBUGGER=1

# --- top-level targets (used by module.bbclass / a plain `make`) ---
SRC := $(shell pwd)
KERNEL_SRC ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KERNEL_SRC) M=$(SRC) modules

modules_install:
	$(MAKE) -C $(KERNEL_SRC) M=$(SRC) modules_install

clean:
	rm -f *.o *~ core .depend .*.cmd *.ko *.mod *.mod.c
	rm -f Module.markers Module.symvers modules.order
	rm -rf .tmp_versions
