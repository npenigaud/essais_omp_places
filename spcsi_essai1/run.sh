#!/bin/bash

comp=$1

module purge                   

if [ "x$comp" = "xgcc" ]
then
module load gcc/14.1.0
gcc -DLINUX -c -fopenmp -O2 linux_bind.c
gcc -c get_time.c
gfortran -fopenmp -O2 -o ./master.x master.F90 linux_bind.o get_time.o
elif [ "x$comp" = "xintel" ]
then
module load gcc/9.2.0          
module load intel/oneapi/2023.2
module load compiler/2023.2.0
icc -DLINUX -c -qopenmp -O2 linux_bind.c
icc -c get_time.c
ifort -qopenmp -O2 -o ./master.x master.F90 linux_bind.o get_time.o
elif [ "x$comp" = "xifx"  ]
then
module load intel/oneapi/2024.1
module load tbb/2021.12
module load compiler-rt/2024.1.0
module load oclfpga/2024.1.0
module load compiler-intel-llvm/2024.1.0
icx -DLINUX -c -qopenmp -O2 linux_bind.c
icx -c get_time.c
ifx -qopenmp -O2 -o ./master.x master.F90 linux_bind.o get_time.o
elif [ "x$comp" = "xnvhpc" ]
then
module load nvhpc/24.7
pgcc -DLINUX -mp -c -O2 linux_bind.c
pgcc -c get_time.c
pgf90 -mp -O2 -o master.x master.F90 linux_bind.o get_time.o
else
  echo "Usage: $0 gcc|intel|nvhpc"
  exit 1
fi

export OMP_NUM_THREADS=8

for LLOMP in 0 1 
do

  export LLOMP

  for LLBIND in 0 1 
  do

    export LLBIND

    \rm -f out.LLOMP=$LLOMP.LLBIND=$LLBIND.txt linux_bind.000000.txt

    export OMP_DISPLAY_ENV=true
    if [ $LLBIND -eq 1 ] 
    then
      echo "llbind true"
      export OMP_PROC_BIND=close
      export OMP_PLACES="0,1,2,3,4,5,6,7"
    else
      echo "llbind false"
      unset OMP_PROC_BIND
      unset OMP_PLACES
    fi

    ./master.x > out.LLOMP=$LLOMP.LLBIND=$LLBIND.txt 2>&1

    cat linux_bind.000000.txt >> out.LLOMP=$LLOMP.LLBIND=$LLBIND.txt

  done
   
done
