#!/usr/bin/env bash

export GRPC_DEFAULT_SSL_ROOTS_FILE_PATH=~/.secrets/tekton-results.crt

function tknr() {
    local readonly method=$1
    local readonly args=$2

    grpc_cli call \
             --channel_creds_type=ssl \
             --ssl_target=tekton-results-api-service.tekton-pipelines.svc.cluster.local \
             --call_creds=access_token=$(kubectl get secrets -n tekton-pipelines -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='tekton-results-debug')].data.token}"|base64 --decode) \
             localhost:50051 \
             tekton.results.v1alpha2.Results.${method} "${args}"
}
