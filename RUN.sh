#!/bin/bash -ex

if [ -z "$1" ]; then
  echo "Must set a tag for the model run"
  exit 1
fi

TAG=$1

# Create directories
TAG_PATH=C:/Users/cjgue/Documents/trying_shell_files/model_runs/$TAG
mkdir -p "$TAG_PATH/intermediary_data"
mkdir -p "$TAG_PATH/output_data"
mkdir -p "$TAG_PATH/plots"

# Save TAG to a file MATLAB can read
echo "$TAG" > TAG.txt

# Run R script
echo "Running 01_get_data.R"
Rscript 01_get_data.R $TAG
echo "Done With 01_get_data.R"

# Run MATLAB in batch
echo "Running MATLAB Code"
matlab -batch "TAG='$TAG'; mycode"
echo "Done With MATLAB Code"