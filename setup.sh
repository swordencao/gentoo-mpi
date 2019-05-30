#!/bin/bash

cd $(dirname "$0")
#emerge -a sys-cluster/modules
cp -f modulefiles/mpi/* /usr/share/Modules/modulefiles
cp -f modulefiles/hpl /usr/share/Modules/modulefiles
