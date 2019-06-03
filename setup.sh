#!/bin/bash

cd $(dirname "$0")
#emerge -a sys-cluster/modules

# update modulefiles
cp -f modulefile/mpi/* /etc/modulefiles/mpi
cp -f modulefile/hpl /etc/modulefiles/hpl
cp -f modulespath /usr/share/Modules/init/.modulespath

# update eselect files
# TODO: probably hpl (or similar) packages here should consider name conflict
cp -f mpi.eselect /usr/share/eselect/modules/mpi.eselect
cp -f hpl.eselect /usr/share/eselect/modules/hpl.eselect
