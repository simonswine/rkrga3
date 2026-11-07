# rkrga3

Out-of-tree build of the Rockchip **RGA3 multicore** 2D-blit accelerator driver,
ported to the **mainline Linux kernel** (builds against 6.12, 6.18 and 7.3).

Sources were extracted from the Rockchip BSP kernel (`drivers/video/rockchip/multi_rga/`,
vendor tree `develop-6.12` branch) — see `../rockchip-linux/` for the original tree.

## Status / scope

Minimal-viable configuration (matches the validated vendor in-tree config):

- IOMMU support (`CONFIG_RGA_IOMMU`; the vendor code derives this from
  `CONFIG_RK_IOMMU && CONFIG_ION_ROCKCHIP`, neither of which exists mainline, so
  it is now defined directly)
- async/fence mode (`CONFIG_ROCKCHIP_RGA_ASYNC`, sync_file fences)
- debugfs + debugger (`CONFIG_ROCKCHIP_RGA_DEBUG_FS`/`_DEBUGGER`)
- Left off: procfs, ION, thunder-boot, video-reverse, genpool cmd_buf

Vendor-tree-only APIs were removed: the hand-rolled page-table-walk fallback in
`rga_get_user_pages()` (used `pte_offset_map_lock`, which is not exported to
modules on mainline) now falls back to a plain `get_user_pages_remote()` failure
instead. Mainline API deltas are version-guarded in place:
`hrtimer_setup()` (≥ 6.13), string-form `MODULE_IMPORT_NS()` (≥ 6.13),
`strscpy_pad()` instead of removed `strncpy()` (7.x).

The driver binds the `rockchip,rga3` / `rockchip,rga2` device tree nodes
(`rockchip,rk3588-rga` style) and exposes `/dev/rga` for the vendor `librga`
userspace.

## Build (out-of-tree)

```sh
make -C /path/to/kernel/build M=$PWD modules
# or via the standard wrapper target:
make KERNEL_SRC=/path/to/kernel/build
```

On device:

```sh
modprobe rga3
dmesg | grep -i rga
```

## Nix builds and CI

The flake pins nixpkgs in `flake.lock` and builds against Linux 6.12, 6.18,
and 7.3 with their configured headers and symbol versions. On ARM64 Linux:

```sh
nix build .#linux-6_12 -L
nix build .#linux-6_18 -L
nix build .#linux-7_3 -L
# Build all checks:
nix flake check -L
```

Modules are installed under `result/lib/modules/<version>/extra/rga3.ko`.
GitHub Actions builds each kernel separately on `ubuntu-24.04-arm` and uploads
successful modules as artifacts. These are compile/link checks, not hardware
tests; artifacts must match the target kernel configuration to load.

## License

GPL-2.0-only. See [LICENSE](LICENSE).
