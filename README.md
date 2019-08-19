# gentoo-mpi

### A framework in support of multiple MPI implementations

**Note: this entire repository is fully dedicated for the GSoC Gentoo MPI project.**

There are numerous MPI implementations in the Gentoo portage tree and far more in general, but most of them can't be installed together as is. The only way to do this now is by using empi from the science overlay and empi has its shortcomings such as lack of multilib support and was not ported to the main tree.

Based on the ideas of python-r1, a new MPI framework ported from existing MPI applications is introduced to enable Gentoo to use multiple MPI versions and relevant packages depending on them (for example, HPL). The gentoo-mpi framework is mainly based on ‘Modules’ package together with Gentoo Prefix technique for detecting, choosing or manipulating MPI environment. Also, an mpi-r1.eclass is introduced and the packages can still be emerged normally onto the system without any trace of mpi-r1.eclass being used. The approach also enables users to easily work with different implementations at the same time without any special privileges. In order to solve the defect that empi does not support multilib, the new framework also adds support for allowing the environment to be configured and installed into different places among different architectures (amd64, x86 etc.), which is handled by using mpi-provider.eclass.

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

## TODO

The core functionality (e.g. parallel install of openmpi, mpich and
hpl using either or both of them) should work, however, there are some tasks to improve the framework:

- [x] Add support for all MPI implementations (mvapich2 - bug 463188).
- [ ] Use eselect template, like modulefile template, instead of in seperated package file diretories like `sys-cluster/hpl`/files.
- [ ] Use env.d to manage user environment like empi does.
- [ ] Use alternative solution instead of \$MPIHOME in modulefiles to represent status of module loadings.
- [ ] Add support for "fullly switch" for user environment. For example, switching from mpich to openmpi should work for both MPI implementation and packages depending on it.
- [ ] Add cases for multilib installation in mpi-r1 and test for them.
- [ ] Add default MPI implementation in mpi-r1.
- [ ] Add new package for testing installation phases, especially `emake install`, and add support for more install functions like `mpi_dobin` and `mpi_dolib`.
- [ ] .modulespath conflict while emerging sys-cluster/gentoo-mpi.
- [ ] Add API docs to documentation if neccesary.
- [ ] Add source copy function in mpi-r1 to enable source copying in prepare phase.
