#!/usr/bin/env bash
set -euo pipefail

bucket=$1

file=jdk/jdk-11.0.8_linux-x64_bin.tar.gz

checksum=${file}.sha1

# Doc: Download the file from the specified bucket. The
# object in question must be publicly accessible.
#
# Arguments: $1 object-key
#
#Usage: download <object-key>
function download {
    local readonly file=$1

    mkdir -p $(dirname $file)

    echo "Downloading ${file} from ${bucket}..."
    curl --fail \
         --location \
         --show-error \
         --output $file \
         https://${bucket}.s3.amazonaws.com/${file}
}

# Doc: Kill the process exiting with an error code.
#
# Arguments: $1 message
#
#Usage: die <message>
function die() {
    local message=$1
    >&2 echo -e "Error: $message"
    exit 1
}

download $file

download $checksum || die "Unable to find checksum file for $file. It should be available as $checksum at the bucket $bucket"

echo "Verifying sha1 hash for ${file}..."

sha1sum  --check --warn --strict $checksum

rm -f $checksum

sudo mkdir $(dirname  $JAVA_HOME) && \
    sudo tar -xvzf jdk/jdk-11.0.8_linux-x64_bin.tar.gz -C $(dirname  $JAVA_HOME) && \
    rm -rf jdk
