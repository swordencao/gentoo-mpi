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
}

pkg_postinst() {
	# append necessary modulefile paths
	MODULESPATH="/usr/share/Modules/init/.modulespath"
	if ! grep -q "/etc/modulefiles$" ${MODULESPATH}; then
		echo "/etc/modulefiles" >> ${MODULESPATH}
	fi
	if ! grep -q "/etc/modulefiles/mpi$" ${MODULESPATH}; then
		echo "/etc/modulefiles/mpi" >> ${MODULESPATH}
	fi
}
