#!/usr/bin/env bash

set -euxo pipefail

export NVM_VERSION=0.39.0

export     NVM_DIR=~/nvm

mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash

cat > /tmp/nvm<<EOF
#!/usr/bin/env bash \
set -eu
source $NVM_DIR/nvm.sh && nvm \$@
EOF

sudo mv /tmp/nvm  /usr/bin/nvm
sudo chmod a+x /usr/bin/nvm
