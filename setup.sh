#!/bin/bash

cd $(dirname "$0")
#emerge -a sys-cluster/modules
cp -f modulefile/mpi/* /etc/modulefiles
cp -f modulefile/hpl /etc/modulefiles
