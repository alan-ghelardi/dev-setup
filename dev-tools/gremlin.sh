#!/usr/bin/env bash
set -euxo pipefail

gremlin_version=3.7.2

curl -LO https://dlcdn.apache.org/tinkerpop/${gremlin_version}/apache-tinkerpop-gremlin-console-${gremlin_version}-bin.zip
unzip apache-tinkerpop-gremlin-console-${gremlin_version}-bin.zip
sudo mv apache-tinkerpop-gremlin-console-${gremlin_version} /opt/
rm apache-tinkerpop-gremlin-console-${gremlin_version}-bin.zip
