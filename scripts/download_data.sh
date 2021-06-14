#! /bin/bash
# A script to download all data for the SIRF-Exercises course
#
# Author: Kris Thielemans, Richard Brown, Ashley Gillman
# Copyright (C) 2018-2021 University College London
# Copyright (C) 2021 CSIRO

set -e
trap "echo some error occured. Retry" ERR


print_usage() {
    echo "Usage: $0 [-p] [-m] [-o] [DEST_DIR] [DOWNLOAD_DIR] | -h"
    echo "A script to download all data for the SIRF-Exercises course"
    echo "  -p        Download only PET data"
    echo "  -m        Download only MR data"
    echo "  -o        Download only old notebook data"
    echo "  -h        Print this help"
    echo "  DEST_DIR  Optional destination directory."
    echo "            If not supplied, \"../data\" will be used, i.e., a subdirectory to the repository."
    echo "  DOWNLOAD_DIR  Optional download directory. Useful if you have the files already downloaded."
    echo "                If not supplied, DEST_DIR will be used."
    echo
    echo "Flags must be before positional arguments."
}

# get the real, absolute path
canonicalise() {
    if [[ $1 = /* ]]; then  # starts with "/"? Already absolute path
        echo "$1"
    else
        DIR=$(dirname "$1")
        BASE=$(basename "$1")
        DIR=$(cd "$DIR"; pwd -P)  # makes absolute, collapses any "/../"
        echo "${DIR}/${BASE}"
    fi
}

# parse flags
while getopts 'pmoh' flag; do
    case "${flag}" in
        p) DO_PET='true' ;;
        m) DO_MR='true' ;;
        o) DO_OLD='true' ;;
        h) print_usage
            exit 1 ;;
        *) print_usage
            exit 1 ;;
    esac
done

DEST_DIR=${@:$OPTIND:1}                  # parse optional DEST_DIR
DOWNLOAD_DIR=${@:$OPTIND+1:2}            # parse optional DOWNLOAD_DIR
# check if user put flags after paths
if [[ "$DEST_DIR" = -* || "$DOWNLOAD_DIR" = -* ]]; then
    print_usage
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
DATA_PATH="${DEST_DIR:-"${REPO_DIR}"/data}"   # if no DEST_DIR, use REPO_DIR/data
DOWNLOAD_DIR="${DOWNLOAD_DIR:-"$DATA_PATH"}"  # if no DOWNLOAD_DIR, use DEST_DIR
DATA_PATH="$(canonicalise "$DATA_PATH")"        # canonicalise
DOWNLOAD_DIR="$(canonicalise "$DOWNLOAD_DIR")"  # canonicalise
echo Destination is \""$DATA_PATH"\"
echo Download location is \""$DOWNLOAD_DIR"\"

# Old Notebooks also need MR data
if [[ "$DO_OLD" ]]; then
    DO_MR='true'
fi

# a function to download a file and check its md5
# assumes that file.md5 exists
function download {
    filename="$1"
    URL="$2"
    suffix="$3"
    if [ -r "$filename" ]
    then
        if md5sum -c "${filename}.md5"
        then
            echo "File exists and its md5sum is ok"
            return 0
        else
            echo "md5sum doesn't match. Redownloading."
            rm "$filename"
        fi
    fi

    echo curl -L -o "$filename" "${URL}${filename}${suffix}"
    curl -L -o "$filename" "${URL}${filename}${suffix}"

    if md5sum -c "${filename}.md5"
    then
        echo "Downloaded file's md5sum is ok"
    else
        echo "md5sum doesn't match. Re-execute this script for another attempt."
        exit 1
    fi
}


#
# PET
#

if [[ -n "$DO_PET" ]]
then
    echo Downloading PET data

    mkdir -p "$DOWNLOAD_DIR"
    pushd "$DOWNLOAD_DIR"
        echo Downloading UCL NEMA_IQ data

        URL=https://zenodo.org/record/1304454/files/

        filename=NEMA_IQ.zip
        # (re)download md5 checksum
        rm -f "${filename}.md5"
        # hard-wired md5 for now
        #curl -OL ${URL}${filename}.md5
        echo "ef848b8f6d5fd57b072a953b374ba4da ${filename}" > "${filename}.md5"

        download "$filename" "$URL"
    popd

    mkdir -p "${DATA_PATH}/PET/mMR"
    pushd "${DATA_PATH}/PET/mMR"
        echo "Unpacking ${filename}"
        unzip -o "${DOWNLOAD_DIR}/${filename}"
    popd
fi

#
# MR
#

if [[ -n "$DO_MR" ]]
then
    echo Downloading MR data

    mkdir -p "$DOWNLOAD_DIR"
    pushd "$DOWNLOAD_DIR"
        echo Downloading MR data

        # Get Zenodo dataset
        URL=https://zenodo.org/record/2633785/files/
        filenameGRAPPA=PTB_ACRPhantom_GRAPPA.zip
        # (re)download md5 checksum
        echo "a7e0b72a964b1e84d37f9609acd77ef2 ${filenameGRAPPA}" > "${filenameGRAPPA}.md5"
        download "$filenameGRAPPA" "$URL"
    popd

    mkdir -p "${DATA_PATH}/MR"
    pushd "${DATA_PATH}/MR"
        echo "Unpacking ${filenameGRAPPA}"
        unzip -o "${DOWNLOAD_DIR}/${filenameGRAPPA}"
    popd
fi

#
# Old Notebooks
#

if [[ -n "${DO_OLD}" ]]
then
    echo Downloading Old Notebooks MR data

    mkdir -p "$DOWNLOAD_DIR"
    pushd "$DOWNLOAD_DIR"
        # meas_MID00108_FID57249_test_2D_2x.dat -> ${DATA_PATH}/MR

        URL=https://www.dropbox.com/s/cazoi5l7oljtwsy/
        filename1=meas_MID00108_FID57249_test_2D_2x.dat
        suffix=?dl=0
        rm -f "${filename1}.md5" # (re)create md5 checksum
        echo "8f06cacf6b3f4b46435bf8e970e1fe3f ${filename1}" > "${filename1}.md5"
        download "$filename1" "$URL" "$suffix"

        # meas_MID00103_FID57244_test.dat -> ${DATA_PATH}/MR

        URL=https://www.dropbox.com/s/tz7q02fziskq9u7/
        filename2=meas_MID00103_FID57244_test.dat
        suffix=?dl=0
        rm -f "${filename2}.md5" # (re)create md5 checksum
        echo "44d9766ddbbf2a082d07ddba74a769c9 ${filename2}" > "${filename2}.md5"
        download "$filename2" "$URL" "$suffix"
    popd

    mkdir -p "${DATA_PATH}/MR"
    pushd "${DATA_PATH}/MR"
        echo "Unpacking ${filename1}"
        rsync -ua "${DOWNLOAD_DIR}/${filename1}" .
        echo "Unpacking ${filename2}"
        rsync -ua "${DOWNLOAD_DIR}/${filename2}" .
    popd
fi


# create the data_path.py files in Python library
echo "creating data_path.py in ${REPO_DIR}/lib/sirf_exercises/data_path.py"  
cat <<EOF >"${REPO_DIR}/lib/sirf_exercises/data_path.py" 
data_path = '${DATA_PATH}'
EOF

echo "All done!"
