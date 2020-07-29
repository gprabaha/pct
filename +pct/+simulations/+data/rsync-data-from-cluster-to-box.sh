#!/bin/bash
# rsync script

SOURCEDIR=pg496@milgram.hpc.yale.edu:/gpfs/milgram/project/chang/CHANG_LAB/pg496/repositories/pct/+pct/+simulations/+data/

DESTDIR=~/Box/Mac-synced/repositories/pct/+pct/+simulations/+data

rsync -azP $SOURCEDIR $DESTDIR