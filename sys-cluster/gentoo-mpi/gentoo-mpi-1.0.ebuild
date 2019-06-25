# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="A framework supports for multiple MPI implementations"
HOMEPAGE="https://github.com/swordencao/gentoo-mpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-admin/eselect"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_install() {
	# install eselect files
	insinto /usr/share/eselect/modules
	doins "${FILESDIR}"/mpi.eselect
	doins "${FILESDIR}"/hpl.eselect
	# install modulefiles
	dodir /etc/modulefiles/mpi
	dodir "${FILESDIR}"/modulefile/mpi /etc/modulefiles/mpi
	#dodir "${FILESDIR}"/modulefile/hpl /etc/modulefiles/hpl
	insinto /usr/share/Modules/init
	newins "${FILESDIR}"/modulespath .modulespath
}
