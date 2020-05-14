#!/bin/bash
#SBATCH --partition=long
#SBATCH --time=2-
#SBATCH --job-name=pct_strategy_simulation_long
#SBATCH --nodes=2 --ntasks=1 --cpus-per-task=50
#SBATCH --mem-per-cpu=5G
#SBATCH --mail-type=ALL

module load MATLAB/2019b
matlab -nodisplay -nosplash -r "run('/gpfs/milgram/project/chang/CHANG_LAB/pg496/repositories/pct/script/run_main_sim_cluster.m');"