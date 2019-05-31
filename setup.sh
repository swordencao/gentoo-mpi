#!/bin/bash

cd $(dirname "$0")
#emerge -a sys-cluster/modules
cp -f modulefile/mpi/* /etc/modulefiles/mpi
cp -f modulefile/hpl /etc/modulefiles/hpl
cp -f modulespath /usr/share/Modules/init/.modulespath
