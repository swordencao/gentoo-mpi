# gentoo-mpi

### A framework in support of multiple MPI implementations

**Note: this entire repository is fully dedicated for the GSoC Gentoo MPI project.**

There are numerous MPI implementations in the Gentoo portage tree and far more in general, but most of them can't be installed together as is. The only way to do this now is by using empi \[1\] from the science overlay and empi has its shortcomings such as lack of multilib support and was not ported to the main tree.

Based on the ideas of python-r1 \[2\], a new MPI framework ported from existing MPI applications is introduced to enable Gentoo to use multiple MPI versions and relevant packages depending on them (for example, HPL). The gentoo-mpi framework is mainly based on ‘Modules’ package together with Gentoo Prefix \[3\] technique for detecting, choosing or manipulating MPI environment. Also, an mpi-r1.eclass is introduced and the packages can still be emerged normally onto the system without any trace of mpi-r1.eclass being used. The approach also enables users to easily work with different implementations at the same time without any special privileges. In order to solve the defect that empi does not support multilib \[4\], the new framework also adds support for allowing the environment to be configured and installed into different places among different architectures (amd64, x86 etc.), which is handled by using mpi-provider.eclass.

## Quick Start

You may need to set a high overlay priority to use modified ebuilds.

```bash
emerge =sys-cluster/openmpi-4.0.1 =sys-cluster/mpich-3.3
USE="mpi_targets_openmpi mpi_targets_mpich" emerge -a =sys-cluster/hpl-2.0-r3
```

A user could also use eselect interface to manage the environment among different MPI implementations.

```bash
eselect mpi set openmpi
eselect mpi list
```

## Documentation

* [mpi-r1](https://github.com/swordencao/gentoo-mpi/blob/master/docs/mpi-r1.md) - install files that may be used with one or more of installed MPI implementations
* [mpi-provider](https://github.com/swordencao/gentoo-mpi/blob/master/docs/mpi-provider.md) - providing MPI paths for ebuilds depending on specific MPI versions and multilib architectures

## Milestone

* Week 1 (5.27 - 6.2)

1. Created an overlay repository and wrote MPI and MPI-based packages (for example, hpl) module files. Based on setting up a virtual environment, they worked as expected.
2. Investigated and tested several things may influence the module files, e.g. run-time environment variables.
3. Found the MPI_TARGETS is the most important and most time-consuming part over the project.

* Week 2 (6.3 - 6.9)

Designed and implemented mpi.eselect and a MPI-based package `sys-cluster/hpl` as an example. These two eselect files can both handle 'list', 'set', 'show' and 'none'. The eselect files basically connect to moduel files' actions directly, which including environment variables operations mostly. So users are able to use eselect directly without 'module' command (actually 'module' works but it is not necessary).

* Week 3-4 (6.10 - 6.23)

Implemented gentoo-mpi and mpi-provider.eclass basically. More detailed, the modulefiles and eselect files which were done in the previous weeks are initially installed by gentoo-mpi. mpi-provider facilitates MPI packages to modify these files specifically.

* Week 5-6 (6.24 - 7.7)

The basic goal for MPI-Provider is finished:

1. Multiple MPI packages (mpich-3.3, openmpi-4.0.1 are tested) could be installed together on the same system without conflict, with the help of mpi-provider.eclass. There are four main types of paths to maintain - libpath, binpath, incpath and manpath.
2. Refactor modulefiles in order to use specific fixed MPI paths rather than modifying by sed.

* Week 7 (7.8 - 7.14)

1. Reimplement mpi.eselect using some of empi’s implementation.
2. Create mpi-r1.eclass for installing different packages satisfying among different MPI implementations, which of some ideas are based on python-r1.  A MPI_COMPAT is designed for list all available MPI implementations in an ebuild, and _MPI_SUPPORTED_IMPLS stands for currently supported MPI implementations.

* Week 8 (7.15 - 7.21)

1. Removed mpi_foreach_impl(), and porting functions – including multilib:
 
mpi-r1_src_configure
mpi-r1_src_cmopile
mpi-r1_multilib_src_configure
mpi-r1_multilib_src_cmopile
 
2. Added hpl for testing mpi-r1.

* Week 9 (7.22 - 7.28)

1. tested hpl with mpi-r1
2. wrote documentation of mpi-provider and mpi-r1

* Week 10-11 (7.29 - 8.11)

1. Found the fixed issues for current implemented packages.
2. Finish writing documentations.
3. Tested openmpi, mpich, mpich2, and mvapich2. There is an existing bug for mvapich2 - 463188 and I will look into it later.
4. Fixed installation of modulefiles and eselect files.

* Week 12 (8.12 - 8.18)

Fix issues, polish documentation, and other miscellaneous jobs.

## TODO

The core functionality (e.g. parallel install of openmpi, mpich and
hpl using either or both of them) should work, however, there are some tasks to improve the framework:

- [ ] mvapich2 cannot be installed - bug 463188.
- [ ] Use eselect template, like modulefile template, instead of in seperated package file diretories like `sys-cluster/hpl`/files.
- [ ] Use env.d to manage user environment like empi does.
- [ ] Use alternative solution instead of \$MPIHOME in modulefiles to represent status of module loadings.
- [ ] Add support for "fullly switch" for user environment. For example, switching from mpich to openmpi should work for both MPI implementation and packages depending on it.
- [ ] Add cases for multilib installation in mpi-r1 and test for them.
- [ ] Add default MPI implementation in mpi-r1.
- [ ] Add new package for testing installation phases, especially `emake install`, and add support for more install functions like `mpi_dobin` and `mpi_dolib`.
- [x] .modulespath conflict while emerging sys-cluster/gentoo-mpi.
- [ ] Add API docs to documentation if neccesary.
- [ ] Add source copy function in mpi-r1 to enable source copying in prepare phase, and modify relative code in `sys-cluster/hpl`.
- [ ] Alter modulefile paths of MPI implementations in `sys-cluster/gentoo-mpi` (need to confirm the issue whether exists or not).
- [ ] Check argument number passing to mpi-provider whether it is 0 or 1, or failing if any other number.
- [ ] Save/restore states if there are multiple inheritances existing in a single ebuild to use mpi-r1.

## Reference

\[1\] empi, https://wiki.gentoo.org/wiki/Empi  
\[2\] python-r1, https://wiki.gentoo.org/wiki/Project:Python/python-r1  
\[3\] Gentoo Prefix, https://wiki.gentoo.org/wiki/Project:Prefix  
\[4\] multilib, https://wiki.gentoo.org/wiki/Project:Multilib

## License

Copyright (C) 2019  Jian Cao

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
