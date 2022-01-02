#!/usr/bin/env bash
set -euxo pipefail

curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
curl -o aws-iam-authenticator.sha256 https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator.sha256
openssl sha1 -sha256 aws-iam-authenticator
chmod +x ./aws-iam-authenticator

sudo mv aws-iam-authenticator /usr/local/bin/
rm aws-iam-authenticator.sha256
