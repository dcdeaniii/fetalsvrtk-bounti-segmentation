#! /bin/bash
#
# Run script for flywheel/fetalsvrtk-bounti-segmentation Gear.
#
# Authorship: Niall bourke and Doug Dean
#

##############################################################################
# Define directory names and containers

FLYWHEEL_BASE=/flywheel/v0
INPUT_DIR=$FLYWHEEL_BASE/input/
OUTPUT_DIR=$FLYWHEEL_BASE/output
CONFIG_FILE=$FLYWHEEL_BASE/config.json
CONTAINER='[flywheel/fetalsvrtk-bounti-segmentation]'
WORK=/flywheel/v0/work
mkdir -p ${WORK}

##############################################################################
# Parse configuration
function parse_config {

  CONFIG_FILE=$FLYWHEEL_BASE/config.json
  MANIFEST_FILE=$FLYWHEEL_BASE/manifest.json

  if [[ -f $CONFIG_FILE ]]; then
    echo "$(cat $CONFIG_FILE | jq -r '.config.'$1)"
  else
    CONFIG_FILE=$MANIFEST_FILE
    echo "$(cat $MANIFEST_FILE | jq -r '.config.'$1'.default')"
  fi
}

# define output choise:
config_output_nifti="$(parse_config 'output_nifti')"

##############################################################################
# Handle INPUT files

echo "${CONTAINER}  Running BOUNTI segmentation algorithm"

# Set initial exit status
mri_svrtk_exit_status=0

# Find input file In input directory with the extension
# .nii, .nii.gz
svr_input_file=`find $INPUT_DIR/reo -iname '*.nii' -o -iname '*.nii.gz'`

# Check that input file exists
if [[ -e $svr_input_file ]]; then
    echo "${CONTAINER}  Input file found: ${svr_input_file}"
    cp ${axi_input_file} ${WORK}/SVRTK-T2w.nii.gz
else
    echo "${CONTAINER} WARNING: Missing one or more Nifti inputs within input directory $INPUT_DIR"
#   echo "${CONTAINER} Exiting..."
#   exit 1  Don't exit, just return error code
fi


if [ "$(ls -A $WORK)" ]; then   
    echo "WORK directory contents:"
    echo "$(ls -l $WORK)"

    echo "Running BOUNTI segmentation..."
    bash /home/auto-proc-svrtk/auto-brain-bounti-segmentation-fetal.sh $WORK $OUTPUT_DIR 
    mri_svrtk_exit_status=$?
else
    echo "WORK directory is empty"
    echo "Exiting..."
    mri_svrtk_exit_status=$?
fi

##############################################################################
# Handle Exit status

if [[ $mri_svrtk_exit_status == 0 ]] && [[ "$(ls -A $OUTPUT_DIR)" ]]; then
  echo -e "${CONTAINER} Success!"
  exit 0
else
  echo "${CONTAINER}  Something went wrong! mri_svrtk exited non-zero!"
  exit 1
fi
