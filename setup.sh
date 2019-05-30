#!/bin/bash

cd $(dirname "$0")
#emerge -a sys-cluster/modules
cp -f modulefile/mpi/* /usr/share/Modules/modulefiles
cp -f modulefile/hpl /usr/share/Modules/modulefiles
