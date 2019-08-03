# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4
MPI_COMPAT=( openmpi mpich )

inherit eutils multilib mpi-r1

DESCRIPTION="Portable Implementation of the Linpack Benchmark for Distributed-Memory Clusters"
HOMEPAGE="http://www.netlib.org/benchmark/hpl/"
SRC_URI="http://www.netlib.org/benchmark/hpl/hpl-${PV}.tar.gz"

SLOT="0"
LICENSE="HPL"
KEYWORDS="~x86 ~amd64"
IUSE="doc"

COMMON_DEPEND="${MPI_DEPS}"

RDEPEND="${COMMON_DEPEND}
	virtual/blas
	virtual/lapack
	"
DEPEND="${DEPEND}
	${COMMON_DEPEND}
	virtual/pkgconfig"

mpi_src_configure() {
	local a=""
	# TODO: change lib 
	local locallib="${EPREFIX}/usr/$(get_libdir)/lib"
	local localblas="$(for i in $($(tc-getPKG_CONFIG) --libs-only-l blas lapack);do a="${a} ${i/-l/${locallib}}.so "; done; echo ${a})"

	# copy all source files using multibuild in pkg_prepare stage
	cp -r "${S}"/* . || die
	#cp "${S}"/Makefile Makefile || die
	#cp "${S}"/Make.top Make.top || die
	#cp "${S}"/setup/Make.Linux_PII_FBLAS Make.gentoo_hpl_fblas_x86 || die
	cp setup/Make.Linux_PII_FBLAS Make.gentoo_hpl_fblas_x86 || die

	sed -i \
		-e "/^TOPdir/s,= .*,= ${BUILD_DIR}," \
		-e '/^HPL_OPTS\>/s,=,= -DHPL_DETAILED_TIMING -DHPL_COPY_L,' \
		-e '/^ARCH\>/s,= .*,= gentoo_hpl_fblas_x86,' \
		-e '/^MPdir\>/s,= .*,=,' \
		-e '/^MPlib\>/s,= .*,=,' \
		-e "/^LAlib\>/s,= .*,= ${localblas}," \
		-e "/^LINKER\>/s,= .*,= ${CC}," \
		-e "/^CC\>/s,= .*,= ${CC}," \
		-e '/^CCFLAGS\>/s|= .*|= $(HPL_DEFS) ${CFLAGS}|' \
		-e "/^LINKFLAGS\>/s|= .*|= ${LDFLAGS}|" \
		Make.gentoo_hpl_fblas_x86 || die

	default
}

mpi_src_compile() {
	# parallel make failure bug #321539
	HOME=${WORKDIR} emake -j1 arch=gentoo_hpl_fblas_x86
}

mpi_src_install() {
	dobin bin/gentoo_hpl_fblas_x86/xhpl
	dolib lib/gentoo_hpl_fblas_x86/libhpl.a
	dodoc INSTALL BUGS COPYRIGHT HISTORY README TUNING \
		bin/gentoo_hpl_fblas_x86/HPL.dat
	doman man/man3/*.3
	if use doc; then
		dohtml -r www/*
	fi
}

pkg_postinst() {
	einfo "Remember to copy /usr/share/hpl/HPL.dat to your working directory"
	einfo "before running xhpl.  Typically one may run hpl by executing:"
	einfo "\"mpiexec -np 4 /usr/bin/xhpl\""
	einfo "where -np specifies the number of processes."
}
