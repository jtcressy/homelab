#!/bin/bash

function ensure_kubectl_command() {
    if ! [ -x "$(command -v kubectl)" ]; then
        kubectl_latest=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
        kubectl_url=https://storage.googleapis.com/kubernetes-release/release/$kubectl_latest/bin/linux/amd64/kubectl
        curl -sLo /usr/local/bin/kubectl $kubectl_url && chmod +x /usr/local/bin/kubectl
    fi
}

function ensure_kind_command() {
    if ! [ -x "$(command -v kind)" ]; then
        curl -sLo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
        chmod +x /usr/local/bin/kind
    fi
}

function ensure_flux_command() {
    if ! [ -x "$(command -v flux)"]; then
        curl -s https://fluxcd.io/install.sh | bash
    fi
}

ensure_kubectl_command
ensure_kind_command
ensure_flux_command