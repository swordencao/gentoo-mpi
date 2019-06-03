#!/bin/bash

cd $(dirname "$0")
#emerge -a sys-cluster/modules

# update modulefiles
mkdir -p /etc/modulefiles/mpi
cp -f modulefile/mpi/* /etc/modulefiles/mpi
# TODO: need to consider furter, what if two MPI-based hpl packages happens here?
cp -fr modulefile/hpl /etc/modulefiles/hpl
cp -f modulespath /usr/share/Modules/init/.modulespath

# update eselect files
# TODO: probably hpl (or similar) packages here should consider name conflict
cp -f mpi.eselect /usr/share/eselect/modules/mpi.eselect
cp -f hpl.eselect /usr/share/eselect/modules/hpl.eselect
