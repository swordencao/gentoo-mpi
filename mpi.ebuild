# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="A framework supports for multiple MPI implementations"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-admin/eselect"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	insinto /usr/share/eselect/modules
	doins "${FILESDIR}"/mpi.eselect
}
