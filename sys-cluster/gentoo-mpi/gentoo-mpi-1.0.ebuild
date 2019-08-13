# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="A framework in support of multiple MPI implementations"
HOMEPAGE="https://github.com/swordencao/gentoo-mpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="
	sys-cluster/modules
	app-admin/eselect"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

S="${WORKDIR}"

src_install() {
	# install modulefiles
	insinto /etc/modulefiles
	doins "${FILESDIR}"/modulefile/template
	insinto /etc/modulefiles/mpi
	doins "${FILESDIR}"/modulefile/mpi/*

	# install eselect files
	insinto /usr/share/eselect/modules
	doins "${FILESDIR}"/mpi.eselect

	# configure modules
	# TODO: remove existing file in the first phase
	insinto /usr/share/Modules/init
	newins "${FILESDIR}"/modulespath .modulespath
}
