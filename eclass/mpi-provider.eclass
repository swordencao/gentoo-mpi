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

# Redundate DEPEND of gentoo-mpi, should be added but error happens
#DEPEND+=" sys-cluster/modules"

#TODO: check argument number if they are equal to 1/0

# @FUNCTION: mpi_incdir
# @USAGE: [additional-args]
# @DESCRIPTION:
# Return the MPI header location for installation
mpi_incdir() {
	if [ "$#" -ne 1 ]; then
		echo "${EPREFIX}/usr/include/mpi/${PN}" || die
	else
		echo "${EPREFIX}/usr/include/mpi/${1}" || die
	fi
}

# @FUNCTION: mpi_bindir
# @USAGE: [additional-args]
# @DESCRIPTION:
# Return the MPI binary location for installation
mpi_bindir() {
	if [ "$#" -ne 1 ]; then
		echo "${EPREFIX}/usr/libexec/mpi/${PN}" || die
	else
		echo "${EPREFIX}/usr/libexec/mpi/${1}" || die
	fi
}

# @FUNCTION: mpi_libdir
# @USAGE: [additional-args]
# @DESCRIPTION:
# Return the MPI libraries location for installation, which should be
# used in multilib ported functions
mpi_libdir() {
	if [ "$#" -ne 1 ]; then
		echo "${EPREFIX}/usr/$(get_libdir)/mpi/${PN}" || die
	else
		echo "${EPREFIX}/usr/$(get_libdir)/mpi/${1}" || die
	fi
}

# @FUNCTION: mpi_mandir
# @USAGE: [additional-args]
# @DESCRIPTION:
# Return the MPI manual location for installation
mpi_mandir() {
	if [ "$#" -ne 1 ]; then
		echo "${EPREFIX}/usr/share/mpi/${PN}/man" || die
	else
		echo "${EPREFIX}/usr/share/mpi/${1}/man" || die
	fi
}
