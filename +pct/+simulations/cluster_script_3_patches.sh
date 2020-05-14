#!/bin/bash
#SBATCH --partition=long
#SBATCH --time=48:00:00
#SBATCH --job-name=pct_strategy_simulation_3_patches
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=28
#SBATCH --mem-per-cpu=8192
#SBATCH --mail-type=ALL

module load MATLAB/2019b
matlab -nodisplay -nosplash -r "run('/gpfs/milgram/project/chang/CHANG_LAB/pg496/repositories/pct/script/run_main_3_patches_sim_cluster.m');"