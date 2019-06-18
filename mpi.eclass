# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mpi.eclass
# @MAINTAINER:
# Jian Cao <sworden.cao@gmail.com>
# @AUTHOR:
# Jian Cao <sworden.cao@gmail.com>
# @BLURB: 
# @DESCRIPTION:
# An eclass depends on Modules, provides interfaces to ebuilds,
# change ${EPREFIX} for MPI or MPI-based packages, depending on
# package type, keywords, package name and version number.

DEPEND=">=sys-cluster/modules-3.2.9c-r1"

# @FUNCTION: mpi-create-module
# @USAGE: [additional-args]
# @DESCRIPTION:
# Create an MPI module file.
mpi-create-module() {
	# TODO: check dir existence.
	mkdir -p /etc/modulefiles/mpi
	insinto /etc/modulefiles/mpi
	doins $1
	# TODO: restore installation location?
}

# @FUNCTION: package-create-module
# @USAGE: [additional-args]
# @DESCRIPTION:
# Create an MPI-based package module file.
package-create-module() {
	# TODO: check dir existence.
	mkdir -p /etc/modulefiles/$1/$2
	insinto /etc/modulefiles/$1/$2
	doins $1
	# TODO: restore installation location?
}

# @FUNCTION: package-create-module
# @USAGE: [additional-args]
# @DESCRIPTION:
# Return the base MPI location for installation
mpi_dir() {
	return "${ED}/usr/$(get_libdir)/mpi"
}
