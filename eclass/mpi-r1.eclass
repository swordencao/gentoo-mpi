# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mpi-r1.eclass
# @MAINTAINER:
# Jian Cao <sworden.cao@gmail.com>
# @AUTHOR:
# Jian Cao <sworden.cao@gmail.com>
# @BLURB: A common eclass for MPI packages.
# @DESCRIPTION:
# A common eclass providing helper functions to build and install
# packages supporting being installed for multiple MPI implementations.
#
# This eclass sets correct IUSE. Modification of REQUIRED_USE has to
# be done by the author of the ebuild (but MPI_REQUIRED_USE is
# provided for convenience, see below). mpi-r1 exports MPI_DEPS
# and MPI_USEDEP so you can create correct dependencies for your
# package easily. It also exports functions to easily run a command for
# each enabled MPI implementation.

inherit mpi-provider multibuild

# TODO: add dobin etc. install functions; multilib
EXPORT_FUNCTIONS src_configure src_compile src_test src_install

# @ECLASS-VARIABLE: _MPI_ALL_IMPLS
# @INTERNAL
# @DESCRIPTION:
# All supported MPI implementations, most preferred last.
_MPI_ALL_IMPLS=(
	openmpi
	mpich
	mpich2
	mvapich2
)

readonly _MPI_ALL_IMPLS

# @ECLASS-VARIABLE: MPI_COMPAT
# @REQUIRED
# @DESCRIPTION:
# This variable contains a list of MPI implementations the package
# supports. It must be set before the `inherit' call. It has to be
# an array.
#
# Example:
# @CODE
# MPI_COMPAT=( openmpi mpich mpich2 )
# @CODE
# @ECLASS-VARIABLE: MPI_REQ_USE
# @DEFAULT_UNSET
# @DESCRIPTION:
# The list of USEflags required to be enabled on the chosen MPI
# implementations, formed as a USE-dependency string. It should be valid
# for all implementations in MPI_COMPAT, so it may be necessary to
# use USE defaults.
#
# This should be set before calling `inherit'.
#
# Example:
# @CODE
# MPI_REQ_USE="java,romio(-)?"
# @CODE
#
# It will cause the MPI dependencies to look like:
# @CODE
# mpi_targets_openmpi? ( sys-cluster/openmpi[java,romio(-)?] )
# @CODE

# @ECLASS-VARIABLE: MPI_DEPS
# @DESCRIPTION:
# This is an eclass-generated MPI dependency string for all
# implementations listed in MPI_COMPAT.
#
# Example use:
# @CODE
# RDEPEND="${MPI_DEPS}
#	dev-foo/mydep"
# DEPEND="${RDEPEND}"
# @CODE
#
# Example value:
# @CODE
# mpi_targets_openmpi? ( sys-cluster/openmpi[java,romio(-)?] )
# @CODE

# @ECLASS-VARIABLE: MPI_USEDEP
# @DESCRIPTION:
# This is an eclass-generated USE-dependency string which can be used to
# depend on another MPI package being built for the same MPI
# implementations.
#
# Example use:
# @CODE
# RDEPEND="dev-mpi/foo[${MPI_USEDEP}]"
# @CODE
#
# Example value:
# @CODE
# mpi_targets_openmpi(-)?,mpi_targets_mpich(-)?
# @CODE

# @ECLASS-VARIABLE: MPI_REQUIRED_USE
# @DESCRIPTION:
# This is an eclass-generated required-use expression which ensures at
# least one MPI implementation has been enabled.
#
# This expression should be utilized in an ebuild by including it in
# REQUIRED_USE, optionally behind a use flag.
#
# Example use:
# @CODE
# REQUIRED_USE="mpi? ( ${MPI_REQUIRED_USE} )"
# @CODE
#
# Example value:
# @CODE
# || ( mpi_targets_openmpi mpi_targets_mpich )
# @CODE

# @FUNCTION: _mpi_impl_supported
# @USAGE: <impl>
# @INTERNAL
# @DESCRIPTION:
# Check whether the implementation <impl> (MPI_COMPAT-form)
# is still supported.
#
# Returns 0 if the implementation is valid and supported. If it is
# unsupported, returns 1 -- and the caller should ignore the entry.
# If it is invalid, dies with an appopriate error messages.
_mpi_impl_supported() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${#} -eq 1 ]] || die "${FUNCNAME}: takes exactly 1 argument (impl)."

	local impl=${1}
	debug-print "${FUNCNAME}: implementation: ${impl}"

	# keep in sync with _MPI_ALL_IMPLS!
	# (not using that list because inline patterns shall be faster)
	case "${impl}" in
		openmpi)
			return 0
			;;
		mpich|mpich2)
			return 0
			;;
		mvapich2)
			return 0
			;;
		*)
			die "Invalid implementation in MPI_COMPAT: ${impl}"
	esac
}

# @FUNCTION: _mpi_set_impls
# @INTERNAL
# @DESCRIPTION:
# Check MPI_COMPAT for well-formedness and validity, then set
# two global variables:
#
# - _MPI_SUPPORTED_IMPLS containing valid implementations supported
#   by the ebuild,
#
# - and _MPI_UNSUPPORTED_IMPLS containing valid implementations that
#   are not supported by the ebuild.
#
# Implementations in both variables are ordered using the pre-defined
# eclass implementation ordering.
#
# This function must be called once in global scope by an eclass
# utilizing MPI_COMPAT.
_mpi_set_impls() {
	debug-print-function ${FUNCNAME} "${@}"
	local i

	if ! declare -p MPI_COMPAT &>/dev/null; then
		die 'MPI_COMPAT not declared.'
	fi
	if [[ $(declare -p MPI_COMPAT) != "declare -a"* ]]; then
		die 'MPI_COMPAT must be an array.'
	fi
	for i in "${MPI_COMPAT[@]}"; do
		# trigger validity checks
		_mpi_impl_supported "${i}"
	done

	local supp=() unsupp=()

	for i in "${_MPI_ALL_IMPLS[@]}"; do
		if has "${i}" "${MPI_COMPAT[@]}"; then
			supp+=( "${i}" )
		else
			unsupp+=( "${i}" )
		fi
	done

	if [[ ! ${supp[@]} ]]; then
		die "No supported implementation in MPI_COMPAT."
	fi

	_MPI_SUPPORTED_IMPLS=( "${supp[@]}" )
	_MPI_UNSUPPORTED_IMPLS=( "${unsupp[@]}" )
	readonly _MPI_SUPPORTED_IMPLS _MPI_UNSUPPORTED_IMPLS
}

_mpi_set_globals() {
	debug-print-function ${FUNCNAME} "${@}"
	local deps i MPI_PKG_DEP

	_mpi_set_impls

	for i in "${_MPI_SUPPORTED_IMPLS[@]}"; do
		# TODO: modify this variable using utils helper function
		#mpi_export "${i}" MPI_PKG_DEP
		case ${i} in
			openmpi)
				MPI_PKG_DEP='sys-cluster/openmpi';;
			mpich)
				MPI_PKG_DEP='sys-cluster/mpich';;
			mpich2)
				MPI_PKG_DEP='sys-cluster/mpich2';;
			mvapich2)
				MPI_PKG_DEP='sys-cluster/mvapich2';;
			*)
				die "Invalid implementation: ${i}"
		esac
		if [[ ${MPI_REQ_USE} ]]; then
			MPI_PKG_DEP+=[${MPI_REQ_USE}]
		fi
		deps+="mpi_targets_${i}? ( ${MPI_PKG_DEP} ) "
	done

	local flags=( "${_MPI_SUPPORTED_IMPLS[@]/#/mpi_targets_}" )
	local requse="|| ( ${flags[*]} )"
	local optflags=${flags[@]/%/(-)?}
	local usedep=${optflags// /,}

	IUSE=${flags[*]}

	MPI_DEPS=${deps}
	MPI_REQUIRED_USE=${requse}
	MPI_USEDEP=${usedep}
	readonly MPI_DEPS MPI_REQUIRED_USE
}

_mpi_set_globals
unset -f _mpi_set_globals

# @FUNCTION: mpi_toolchain_setup
# @DESCRIPTION:
# Setup necessary toolchain or flags for specific MPI implementation.
mpi_toolchain_setup() {
	debug-print-function ${FUNCNAME} "${@}"
	local impl

	impl=${1}

	# TODO: save/restore state
	case ${impl} in
		mpich|openmpi)
			export CC="$(mpi_bindir ${impl})"/mpicc
			export CXX="$(mpi_bindir ${impl})"/mpic++
			export FC="$(mpi_bindir ${impl})"/mpifort
			export F77="$(mpi_bindir ${impl})"/mpif77
			export LD="$(mpi_bindir ${impl})"/mpic++
			;;
		mpich2)
			export CC="$(mpi_bindir ${impl})"/mpicc
			export CXX="$(mpi_bindir ${impl})"/mpic++
			export FC="$(mpi_bindir ${impl})"/mpif90
			export F77="$(mpi_bindir ${impl})"/mpif77
			export LD="$(mpi_bindir ${impl})"/mpic++
			;;
		mvapich2)
			# TODO: bug 463188
			export CC="$(mpi_bindir ${impl})"/mpicc
			export CXX="$(mpi_bindir ${impl})"/mpic++
			export FC="$(mpi_bindir ${impl})"/mpifort
			export F77="$(mpi_bindir ${impl})"/mpif77
			export LD="$(mpi_bindir ${impl})"/mpic++
			;;
		*)
			die "Invalid implementation: ${i}"
	esac
	# CCFLAGS LINKER LINKFLAGS
}

# @FUNCTION: _mpi_multibuild_wrapper
# @USAGE: <command> [<args>...]
# @INTERNAL
# @DESCRIPTION:
# Initialize the environment for MPI implementation selected
# for multibuild.
_mpi_multibuild_wrapper() {
	debug-print-function ${FUNCNAME} "${@}"
	mpi_toolchain_setup "${MULTIBUILD_VARIANT}"
	"${@}"
}

# @FUNCTION: mpi_foreach_impl
# @USAGE: <command> [<args>...]
# @DESCRIPTION:
# Run the given command for each of the enabled MPI implementations.
# If additional parameters are passed, they will be passed through
# to the command.
#
# The function will return 0 status if all invocations succeed.
# Otherwise, the return code from first failing invocation will
# be returned.
#
# For each command being run, specified MPI toolchain, flags and
# BUILD_DIR are set locally, and the former two are exported to the
# command environment.
mpi_foreach_impl() {
	debug-print-function ${FUNCNAME} "${@}"
	local MULTIBUILD_VARIANTS
	MULTIBUILD_VARIANTS=()

	local impl
	for impl in "${_MPI_SUPPORTED_IMPLS[@]}"; do
		has "${impl}" "${MPI_COMPAT[@]}" && \
		use "mpi_targets_${impl}" && MULTIBUILD_VARIANTS+=( "${impl}" )
	done
	multibuild_foreach_variant _mpi_multibuild_wrapper "${@}"
}

# @FUNCTION: _mpi_do
# @USAGE: $1 - Standard ebuild command to replicate.
# @INTERNAL
# @DESCRIPTION: Large wrapping class for all of the {do,new}* commands
# that need to respect the new root to install to.
# Currently supports:
# @CODE
# dobin    newbin    dodoc     newdoc
# doexe    newexe    dohtml    dolib
# dolib.a  newlib.a  dolib.so  newlib.so
# dosbin   newsbin   doman     newman
# doinfo   dodir     dohard    doins
# dosym
# @CODE
_mpi_do() {
	debug-print-function ${FUNCNAME} "${@}"

	local rc prefix d
	local cmd=${1}
	local ran=1
	local slash=/

	shift
	if [ "${cmd#do}" != "${cmd}" ]; then
		prefix="do"; cmd=${cmd#do}
	elif [ "${cmd#new}" != "${cmd}" ]; then
		prefix="new"; cmd=${cmd#new}
	else
		die "Unknown command passed to _mpi_do: ${cmd}"
	fi
	case ${cmd} in
		#bin)
		#	(
		#		insinto $(mpi_bindir ${MULTIBUILD_VARIANT})
		#		doins "${@}"
		#	)
		#	rc=$?;;
		bin|sbin)
			DESTTREE="$(mpi_bindir ${MULTIBUILD_VARIANT})" ${prefix}${cmd} $*
			rc=$?;;
		lib|lib.a|lib.so)
			DESTTREE="$(mpi_libdir ${MULTIBUILD_VARIANT})/${CATEGORY}/${PN}" ${prefix}${cmd} $*
			rc=$?;;
		#doc)
		#	_E_DOCDESTTREE_="../../../../${mdir}usr/share/doc/${PF}/${_E_DOCDESTTREE_}" \
		#		${prefix}${cmd} $*
		#	rc=$?
		#	for d in "/share/doc/${P}" "/share/doc" "/share"; do
		#		rmdir ${D}/usr${d} &>/dev/null
		#	done
		#	;;
		#html)
		#	_E_DOCDESTTREE_="../../../../${mdir}usr/share/doc/${PF}/www/${_E_DOCDESTTREE_}" \
		#		${prefix}${cmd} $*
		#	rc=$?
		#	for d in "/share/doc/${P}/html" "/share/doc/${P}" "/share/doc" "/share"; do
		#		rmdir ${D}/usr${d} &>/dev/null
		#	done
		#	;;
		#exe)
		#	_E_EXEDESTTREE_="${mdir}${_E_EXEDESTTREE_}" ${prefix}${cmd} $*
		#	rc=$?;;
		#man|info)
		#	[ -d "${D}"usr/share/${cmd} ] && mv "${D}"usr/share/${cmd}{,-orig}
		#	[ ! -d "${D}"${mdir}usr/share/${cmd} ] \
		#		&& install -d "${D}"${mdir}usr/share/${cmd}
		#	[ ! -d "${D}"usr/share ] \
		#		&& install -d "${D}"usr/share
		#
		#	ln -snf ../../${mdir}usr/share/${cmd} ${D}usr/share/${cmd}
		#	${prefix}${cmd} $*
		#	rc=$?
		#	rm "${D}"usr/share/${cmd}
		#	[ -d "${D}"usr/share/${cmd}-orig ] \
		#		&& mv "${D}"usr/share/${cmd}{-orig,}
		#	[ "$(find "${D}"usr/share/)" == "${D}usr/share/" ] \
		#		&& rmdir "${D}usr/share"
		#	;;
		#dir)
		#	dodir "${@/#${slash}/${mdir}${slash}}"; rc=$?;;
		#hard|sym)
		#	${prefix}${cmd} "${mdir}$1" "${mdir}/$2"; rc=$?;;
		#ins)
		#	INSDESTTREE="${mdir}${INSTREE}" ${prefix}${cmd} $*; rc=$?;;
		*)
			rc=0;;
	esac

	[[ ${ran} -eq 0 ]] && die "mpi_do passed unknown command: ${cmd}"
	return ${rc}
}
mpi_dobin()     { _mpi_do "dobin"        $*; }
mpi_newbin()    { _mpi_do "newbin"       $*; }
mpi_dodoc()     { _mpi_do "dodoc"        $*; }
mpi_newdoc()    { _mpi_do "newdoc"       $*; }
mpi_doexe()     { _mpi_do "doexe"        $*; }
mpi_newexe()    { _mpi_do "newexe"       $*; }
mpi_dohtml()    { _mpi_do "dohtml"       $*; }
mpi_dolib()     { _mpi_do "dolib"        $*; }
mpi_dolib.a()   { _mpi_do "dolib.a"      $*; }
mpi_newlib.a()  { _mpi_do "newlib.a"     $*; }
mpi_dolib.so()  { _mpi_do "dolib.so"     $*; }
mpi_newlib.so() { _mpi_do "newlib.so"    $*; }
mpi_dosbin()    { _mpi_do "dosbin"       $*; }
mpi_newsbin()   { _mpi_do "newsbin"      $*; }
mpi_doman()     { _mpi_do "doman"        $*; }
mpi_newman()    { _mpi_do "newman"       $*; }
mpi_doinfo()    { _mpi_do "doinfo"       $*; }
mpi_dodir()     { _mpi_do "dodir"        $*; }
mpi_dohard()    { _mpi_do "dohard"       $*; }
mpi_doins()     { _mpi_do "doins"        $*; }
mpi_dosym()     { _mpi_do "dosym"        $*; }

mpi-r1_src_configure() {
	debug-print-function ${FUNCNAME} "${@}"

	mpi-r1_abi_src_configure() {
		debug-print-function ${FUNCNAME} "${@}"

		mkdir -p "${BUILD_DIR}" || die
		pushd "${BUILD_DIR}" >/dev/null || die
		if declare -f mpi_src_configure >/dev/null ; then
			mpi_src_configure
		else
			default_src_configure
		fi
		popd >/dev/null || die
	}

	mpi_foreach_impl mpi-r1_abi_src_configure
}

mpi-r1_src_compile() {
	debug-print-function ${FUNCNAME} "${@}"

	mpi-r1_abi_src_compile() {
		debug-print-function ${FUNCNAME} "${@}"

		pushd "${BUILD_DIR}" >/dev/null || die
		if declare -f mpi_src_compile >/dev/null ; then
			mpi_src_compile
		else
			default_src_compile
		fi
		popd >/dev/null || die
	}

	mpi_foreach_impl mpi-r1_abi_src_compile
}

mpi-r1_src_test() {
	debug-print-function ${FUNCNAME} "${@}"

	mpi-r1_abi_src_test() {
		debug-print-function ${FUNCNAME} "${@}"

		pushd "${BUILD_DIR}" >/dev/null || die
		if declare -f mpi_src_test >/dev/null ; then
			mpi_src_test
		else
			default_src_test
		fi
		popd >/dev/null || die
	}

	mpi_foreach_impl mpi-r1_abi_src_test
}

mpi-r1_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	mpi-r1_abi_src_install() {
		debug-print-function ${FUNCNAME} "$@"

		pushd "${BUILD_DIR}" >/dev/null || die
		if declare -f mpi_src_install >/dev/null ; then
			mpi_src_install
		else
			# default_src_install will not work here as it will
			# break handling of DOCS wrt #468092
			# so we split up the emake and doc-install part
			# this is synced with __eapi4_src_install
			if [[ -f Makefile || -f GNUmakefile || -f makefile ]] ; then
				emake DESTDIR="${D}" install
			fi
		fi

		popd >/dev/null || die
	}

	mpi_foreach_impl mpi-r1_abi_src_install

	if declare -f mpi_src_install_all >/dev/null ; then
		mpi_src_install_all
	else
		einstalldocs
	fi
}

mpi-r1_multilib_src_configure() {
	debug-print-function ${FUNCNAME} "${@}"

	mpi-r1_multilib_abi_src_configure() {
		debug-print-function ${FUNCNAME} "${@}"

		# Should "${BUILD_DIR}" be fixed here?
		mkdir -p "${BUILD_DIR}" || die
		pushd "${BUILD_DIR}" >/dev/null || die
		if declare -f mpi_multilib_src_configure >/dev/null ; then
			mpi_multilib_src_configure
		else
			multilib_src_configure
		fi
		popd >/dev/null || die
	}

	# and for each multilib ABI
	mpi_foreach_impl mpi-r1_multilib_abi_src_configure
}

mpi-r1_multilib_src_compile() {
	debug-print-function ${FUNCNAME} "${@}"

	mpi-r1_multilib_abi_src_compile() {
		debug-print-function ${FUNCNAME} "${@}"

		pushd "${BUILD_DIR}" >/dev/null || die
		if declare -f mpi_multilib_src_compile >/dev/null ; then
			mpi_multilib_src_compile
		else
			multilib_src_compile
		fi
		popd >/dev/null || die
	}

	mpi_foreach_impl mpi-r1_multilib_abi_src_compile
}
