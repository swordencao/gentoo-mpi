# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mpi-provider.eclass
# @MAINTAINER:
# Jian Cao <sworden.cao@gmail.com>
# @AUTHOR:
# Jian Cao <sworden.cao@gmail.com>
# @BLURB: 
# @DESCRIPTION:
# An eclass depends on Modules, provides interfaces to ebuilds,
# change ${EPREFIX} for MPI or MPI-based packages, depending on
# package type, keywords, package name and version number.

inherit multilib

DEPEND+=" sys-cluster/modules"

# @FUNCTION: mpi-create-module
# @USAGE: [additional-args]
# @DESCRIPTION:
# Create an MPI module file.
mpi-create-module() {
	# TODO: check dir existence.
	mkdir -p ${EPREFIX}/etc/modulefiles/mpi
	insinto ${EPREFIX}/etc/modulefiles/mpi
	doins $1
	# TODO: restore installation location?
}

# @FUNCTION: package-create-module
# @USAGE: [additional-args]
# @DESCRIPTION:
# Create an MPI-based package module file.
package-create-module() {
	# TODO: check dir existence.
	mkdir -p ${EPREFIX}/etc/modulefiles/$1/$2
	insinto ${EPREFIX}/etc/modulefiles/$1/$2
	doins $1
	# TODO: restore installation location?
}

# @FUNCTION: mpi_incdir
# @USAGE: [additional-args]
# @DESCRIPTION:
# Return the MPI header location for installation
mpi_incdir() {
	# dodir?
	return "${EPREFIX}/usr/include/mpi/${PN}"
}

# @FUNCTION: mpi_bindir
# @USAGE: [additional-args]
# @DESCRIPTION:
# Return the MPI binary location for installation
mpi_bindir() {
	# dodir?
	return "${EPREFIX}/usr/libexec/mpi/${PN}"
}

# @FUNCTION: mpi_libdir
# @USAGE: [additional-args]
# @DESCRIPTION:
# Return the MPI libraries location for installation
mpi_libdir() {
	# dodir?
	return "${EPREFIX}/usr/$(get_libdir)/mpi/${PN}"
}
