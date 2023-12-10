FROM argoproj/argocd:v2.6.15

USER root

RUN apt-get update && \
    apt-get install -y \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -qsL https://github.com/viaduct-ai/kustomize-sops/releases/download/v4.3.0/ksops_4.3.0_Linux_x86_64.tar.gz | tar xfz - -C /usr/local/bin/ ksops

USER argocd

ARG GCS_PLUGIN_VERSION="0.3.5"
ARG GCS_PLUGIN_REPO="https://github.com/hayorov/helm-gcs.git"

RUN helm plugin install ${GCS_PLUGIN_REPO} --version ${GCS_PLUGIN_VERSION}

ENV XDG_CONFIG_HOME="/home/argocd/.config"
ENV HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/"

