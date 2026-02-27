#!/bin/bash -ex

# Check if a tag is given
if [ -z "$1" ];
then
  echo "Must set a tag for the model run"
  exit 1
fi

TAG=$1

echo "Creating output directory"
TAG_PATH=C:/Users/cjgue/Documents/trying_shell_files/model_runs/$TAG
mkdir -p "$TAG_PATH"
mkdir -p "$TAG_PATH/intermediary_data"
mkdir -p "$TAG_PATH/output_data"
mkdir -p "$TAG_PATH/plots"


echo "Running 01_get_data.R"
Rscript 01_get_data.R $TAG
echo "Done With 01_get_data.R"


echo "Running Matlab Code"
matlab -batch "mycode"
echo "Done With 01_get_data.R"
