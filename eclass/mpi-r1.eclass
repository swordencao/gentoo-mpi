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

inherit multibuild

_mpi_set_impls() {
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
	local deps i MPI_PKG_DEP

	_mpi_set_impls

	for i in "${_MPI_SUPPORTED_IMPLS[@]}"; do
		# TODO: export variables; MPI_PKG_DEP
		mpi_export "${i}" MPI_PKG_DEP
		# TODO: consider deps
		#deps+="mpi_targets_${i}? ( ${MPI_PKG_DEP} ) "
	done

	local flags=( "${_MPI_SUPPORTED_IMPLS[@]/#/mpi_targets_}" )

	# TODO: consider the following block, how to manage MPI deps?

	#local optflags=${flags[@]/%/(-)?}

	#local flags_st=( "${_MPI_SUPPORTED_IMPLS[@]/#/-mpi_single_target_}" )
	#optflags+=,${flags_st[@]/%/(-)}
	#local requse="|| ( ${flags[*]} )"
	#local usedep=${optflags// /,}

	IUSE=${flags[*]}

	#MPI_DEPS=${deps}
	#MPI_REQUIRED_USE=${requse}
	#MPI_USEDEP=${usedep}
	#readonly MPI_DEPS MPI_REQUIRED_USE
}

_python_set_globals
unset -f _python_set_globals

mpi_foreach_impl() {
	local MULTIBUILD_VARIANTS
	#TODO: implement
	_mpi_obtain_impls
	#TODO: multibuild_foreach_variant
}
