# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mpi-r1.eclass
# @MAINTAINER:
# Jian Cao <sworden.cao@gmail.com>
# @AUTHOR:
# Jian Cao <sworden.cao@gmail.com>
# @BLURB: A helper eclass for MPI packages.
# @DESCRIPTION:
# This eclass manages building and installing MPI packages for multiple
# MPI implementations.

inherit mpi-provider multibuild

# TODO: add src_install; add dobin etc. install functions; multilib
#EXPORT_FUNCTIONS src_configure src_compile src_test src_install
EXPORT_FUNCTIONS src_configure src_compile

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
		deps+="mpi_targets_${i}? ( ${MPI_PKG_DEP} ) "
	done

	local flags=( "${_MPI_SUPPORTED_IMPLS[@]/#/mpi_targets_}" )

	# TODO: MPI_REQUIRED_USE
	#local optflags=${flags[@]/%/(-)?}

	#local flags_st=( "${_MPI_SUPPORTED_IMPLS[@]/#/-mpi_single_target_}" )
	#optflags+=,${flags_st[@]/%/(-)}
	#local requse="|| ( ${flags[*]} )"
	#local usedep=${optflags// /,}

	IUSE=${flags[*]}

	MPI_DEPS=${deps}
	#MPI_REQUIRED_USE=${requse}
	#MPI_USEDEP=${usedep}
	readonly MPI_DEPS
	#readonly MPI_DEPS MPI_REQUIRED_USE
}

_mpi_set_globals
unset -f _mpi_set_globals

mpi_export() {
	debug-print-function ${FUNCNAME} "${@}"
	local impl

	impl=${1}

	# initial test, add cases later
	# for hpl, is there a better way to find out all available variables?
	#local -x CXX PATH LD_LIBRARY_PATH {C,CXX,F,FC}FLAGS
	#case mpich openmpi?
	export CC="$(mpi_bindir ${impl})"/mpicc
	export CXX="$(mpi_bindir ${impl})"/mpic++
	export FC="$(mpi_bindir ${impl})"/mpif77
	# CCFLAGS LINKER LINKFLAGS
}

_mpi_multibuild_wrapper() {
	debug-print-function ${FUNCNAME} "${@}"
	mpi_export "${MULTIBUILD_VARIANT}"
	"${@}"
}

mpi_foreach_impl() {
	debug-print-function ${FUNCNAME} "${@}"
	local MULTIBUILD_VARIANTS
	MULTIBUILD_VARIANTS=()

	local impl
	for impl in "${_MPI_SUPPORTED_IMPLS[@]}"; do
		has "${impl}" "${MPI_COMPAT[@]}" && \
		use "mpi_targets_${impl}" && MULTIBUILD_VARIANTS+=( "${impl}" )
	done
	#multibuild_foreach_variant mpi_export "${MULTIBUILD_VARIANT}" "${@}"
	multibuild_foreach_variant _mpi_multibuild_wrapper "${@}"
}

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
