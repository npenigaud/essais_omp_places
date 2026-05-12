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
module load intel/2023.2
icc -DLINUX -c -qopenmp -O2 linux_bind.c
icc -c get_time.c
ifort -qopenmp -O2 -o ./master.x master.F90 linux_bind.o get_time.o
elif [ "x$comp" = "xifx"  ]
then
module load intel/2023.2
icx -DLINUX -c -qopenmp -O2 linux_bind.c
icx -c get_time.c
ifx -qopenmp -O2 -o ./master.x master.F90 linux_bind.o get_time.o
elif [ "x$comp" = "xrocm" ]
then
/ec/res4/hpcperm/sor/install/rocm/therock-afar-23.2.0-gfx94X-7.13.0-663ad81964a/llvm/bin/clang -DLINUX -c -fopenmp -O2 linux_bind.c
/ec/res4/hpcperm/sor/install/rocm/therock-afar-23.2.0-gfx94X-7.13.0-663ad81964a/llvm/bin/clang -c get_time.c
/ec/res4/hpcperm/sor/install/rocm/therock-afar-23.2.0-gfx94X-7.13.0-663ad81964a/llvm/bin/flang -fopenmp -O2 -o ./master.x master.F90 linux_bind.o get_time.o
elif [ "x$comp" = "xnvhpc" ]
then
module load nvidia/24.11
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

    \rm -f out.LLOMP=$LLOMP.LLBIND=${LLBIND}_hw2.txt linux_bind.000000.txt

    export OMP_DISPLAY_ENV=true
    if [ $LLBIND -eq 1 ] 
    then
      echo "llbind true"
      export OMP_PROC_BIND=close
      export OMP_PLACES="0,128,2,130,4,132,6,134"
    else
      echo "llbind false"
      unset OMP_PROC_BIND
      unset OMP_PLACES
    fi

    ./master.x > out.LLOMP=$LLOMP.LLBIND=${LLBIND}_hw2.txt 2>&1

    cat linux_bind.000000.txt >> out.LLOMP=$LLOMP.LLBIND=${LLBIND}_hw2.txt

  done
   
done
