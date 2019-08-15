# mpi-provider.eclass

mpi-provider is an eclass providing MPI paths for ebuilds, depending on specific MPI versions and multilib architectures.

## Description

Different MPI implementations are installed into different locations which are specified by mpi-provider. The eclass return paths for ebuild and mpi-r1, and provide these paths for specific MPI implementations.

Different from other ebuilds, MPI ebuild using mpi-provider installs binaries, libraries, headers and manuals into split parent directories:

|   Function  |   Target  |             Location             |
|:-----------:|:---------:|:--------------------------------:|
| mpi\_incdir |  headers  |     /usr/include/mpi/\$\{PN\}    |
| mpi\_bindir |  binaries |     /usr/libexec/mpi/\$\{PN\}    |
| mpi\_libdir | libraries | /usr/\$(get_libdir)/mpi/\$\{PN\} |
| mpi\_mandir |  manuals  |    /usr/share/mpi/\$\{PN\}/man   |

In mpi-r1, the respective MPI implementation is represented by the first argument \$\{1\} in stead of \$\{PN\}, because it may handle more than one MPI implementation in sub-phases.

## Examples

```bash
src_configure() {
	local c=
	c="${c} --bindir=$(mpi_bindir)"
	c="${c} --sbindir=$(mpi_bindir)"
	c="${c} --libexecdir=$(mpi_bindir)"
	c="${c} --libdir=$(mpi_libdir)"
	c="${c} --includedir=$(mpi_incdir)"
	c="${c} --oldincludedir=$(mpi_incdir)"
	c="${c} --mandir=$(mpi_mandir)"
	ECONF_SOURCE=${S} econf ${c}
}
```
