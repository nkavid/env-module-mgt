# env-module-mgt

> Personal environment modules setup.

 - [Linux Foundation - Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)
 - [Environment Modules (readthedocs)](https://modules.readthedocs.io/en/latest/)

Goal is to have some third party stuff available pre-built when switching between different toolchains. Some scripts are more like documenting to myself how I built something last time. See for example enabling CUDA in [nkavid/ffmpeg-install](https://github.com/nkavid/ffmpeg-install) or llvm-project CMake configuration in [nkavid/gfx-checks](https://github.com/nkavid/gfx-checks).

## generate-modulefile

```console
lorem@ipsum:~$ generate-modulefile --help
Usage: generate-modulefile [options]

Description:
  Generates a modulefile 'output_modulefile.tcl'
  in current working directory.
  '--<option>' without '=' sets Default

Required arguments:
  --package          Installed package name
  --version          Installed package version

Optional arguments:
  --prefix           Installed package path
                     (Default: /opt/pkg/<package>/<package>_<version>)

Optional relative paths appended to prefix
  --bindir=<path>         (Default: bin)
  --libdir=<path>         (Default: lib)
  --include=<path>        (Default: include)
  --cmake=<path>          (Default: <libdir>/cmake)
  --pkgconfig=<path>      (Default: <libdir>/pkgconfig)
  --manpath=<path>        (Default: share/man)
```

Example of `output_modulefile.tcl`
```tcl
#%Module
# gcc modulefile

set prefix /opt/pkg/gcc/gcc-13.1.0

set bindir $prefix/bin
set libdir $prefix/lib64
set incdir $prefix/include/c++/13.1.0

prepend-path PATH            $bindir
prepend-path LIBRARY_PATH    $libdir
prepend-path LD_LIBRARY_PATH $libdir
prepend-path CPATH           $incdir

prepend-path MANPATH            $prefix/share/man

conflict gcc
```
