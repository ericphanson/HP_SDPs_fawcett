#!/bin/bash
#! Which partition (queue) should be used
#SBATCH -p skylake
#! Number of required nodes
#SBATCH --ntasks=1                   # Run a single task	
#SBATCH --cpus-per-task=12            # Number of CPU cores per task
#!How much wallclock time will be required (HH:MM:SS)
#SBATCH --time=12:00:00
# Job name
#SBATCH -J test-threading

echo '-------------------------------'
cd ${SLURM_SUBMIT_DIR}
echo ${SLURM_SUBMIT_DIR}
echo Running on host $(hostname)
echo Time is $(date)
echo SLURM_NODES are $(echo ${SLURM_NODELIST})
echo SLURM JobID is $SLURM_JOBID
echo '-------------------------------'
echo -e '\n\n'


export OMP_NUM_THREADS=1
stdbuf -o0 -e0 /home/eh540/bin/julia-1.1.0/bin/julia --project=/home/eh540/code/HP_SDPs_fawcett/testing-SDPA/ /home/eh540/code/HP_SDPs_fawcett/testing-SDPA/threading-test.jl

export OMP_NUM_THREADS=4
stdbuf -o0 -e0 /home/eh540/bin/julia-1.1.0/bin/julia --project=/home/eh540/code/HP_SDPs_fawcett/testing-SDPA/ /home/eh540/code/HP_SDPs_fawcett/testing-SDPA/threading-test.jl

export OMP_NUM_THREADS=8
stdbuf -o0 -e0 /home/eh540/bin/julia-1.1.0/bin/julia --project=/home/eh540/code/HP_SDPs_fawcett/testing-SDPA/ /home/eh540/code/HP_SDPs_fawcett/testing-SDPA/threading-test.jl

export OMP_NUM_THREADS=12
stdbuf -o0 -e0 /home/eh540/bin/julia-1.1.0/bin/julia --project=/home/eh540/code/HP_SDPs_fawcett/testing-SDPA/ /home/eh540/code/HP_SDPs_fawcett/testing-SDPA/threading-test.jl

export OMP_NUM_THREADS=16
stdbuf -o0 -e0 /home/eh540/bin/julia-1.1.0/bin/julia --project=/home/eh540/code/HP_SDPs_fawcett/testing-SDPA/ /home/eh540/code/HP_SDPs_fawcett/testing-SDPA/threading-test.jl