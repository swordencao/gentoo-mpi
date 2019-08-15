# mpi-r1

Based on python-r1, mpi-r1 is an eclass intended for ebuilds that install files that may be used with one or more of installed MPI implementations.

## Description

The mpi-r1 is the eclass that is suggested to be used for most of the packages using MPI environment. This often involves MPI bindings and conditional MPI support in applications. It provides a friendly, sub-phase function-based API to build packages.

As with in python-r1, you need to set MPI\_COMPAT (and optionally MPI\_REQ\_USE) before inheriting the eclass. This is necessary so that proper values can be generated for global scope variables.

This eclass affects ebuild metadata only by using `mpi_targets_` use flags. It also exports MPI\_DEPS and MPI\_REQUIRED\_USE that need to be explicitly used in RDEPEND, DEPEND, and REQUIRED\_USE.

The core purpose of this eclass is to provide means to install MPI code for multiple implementations. This is usually done via repeating all or some of the build steps for every enabled implementation. To implement this, an API based on multibuild.eclass is used. The eclass is built around the concept of sub-phase functions. It exports each of the following phase functions, and implements it in terms of sub-phase functions:

|      Phase     |  Per-ABI sub-phase  |    Common sub-phase    |
|:--------------:|:-------------------:|:----------------------:|
| src\_configure | mpi\_src\_configure |            -           |
|  src\_compile  |  mpi\_src\_compile  |            -           |
|    src\_test   |    mpi\_src\_test   |            -           |
|  src\_install  |  mpi\_src\_install  | mpi\_src\_install\_all |

Each of the per-ABI sub-phase functions is executed for each enabled MPI implementation ABI, in a dedicated build directory (that is different from \$\{S\}), with an environment set up for building for the particular ABI.

By default, the per-ABI sub-phase performs the same task as the original phase function, e.g. mpi\_src\_compile calls emake. However, each of those functions can be overriden in ebuild to perform different code. When adding MPI support to existing packages, it is common to start by renaming phase functions to their respective MPI sub-phases.

The additional common sub-phase can be used to perform tasks that are irrelevant to MPI. It is run inside \$\{S\}, and defaults to installing documentation. When overriden in an ebuild, einstalldocs can be used to reproduce the original behavior.

Please note that the ebuild needs to explicitly ensure the correctness of commands run in build directory. This usually requires either:

* setting ECONF\_SOURCE=\$\{S\} for src\_configure() when using autotools so that an out-of-source build will be performed,
* ~~calling mpi\_copy\_sources in src\_prepare() to create separate copies of sources in build directories.~~

There are several wrapper ebuild commands to replicate standard ebuild commands with specific MPI implementation support. The wrapper commands are for all of the \{do,new\}\* commands that need to respect the specific MPI package implementation path to install to, and `bin` and `lib` are implemented for now.

The mpi-r1 as well installs modulefiles and eselect files into relative MPI package locations, which enable users to use eselect interface to manage the environment of  multiple MPI implementations.

## Examples

```bash
MPI_COMPAT=( openmpi mpich mpich2 )

inherit mpi-r1

RDEPEND="${MPI_DEPS}
    dev-python/foo[${MPI_USEDEP}]"
DEPEND="${RDEPEND}"

REQUIRED_USE="${MPI_REQUIRED_USE}"

mpi_src_configure() {
    ECONF_SOURCE=${S} \
    default
}

mpi_src_compile() {
    HOME=${BUILD_DIR} emake -j1
}

mpi_src_test() {
    default
}

mpi_src_install() {
    mpi_dobin bin/mpix
    mpi_dolib lib/libmpi.a
}

mpi_src_install_all() {
    dodoc INSTALL BUGS COPYRIGHT HISTORY README TUNING
}

```
