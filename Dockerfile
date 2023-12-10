FROM viaductoss/ksops:v3.0.2 as ksops

FROM argoproj/argocd:v2.6.15

USER root

COPY --from=ksops /go/src/github.com/viaduct-ai/kustomize-sops/kops /usr/local/bin/
COPY --from=ksops /go/bin/kustomize /usr/local/bin/

RUN apt-get update && \
    apt-get install -y \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER argocd

ARG GCS_PLUGIN_VERSION="0.3.5"
ARG GCS_PLUGIN_REPO="https://github.com/hayorov/helm-gcs.git"

RUN helm plugin install ${GCS_PLUGIN_REPO} --version ${GCS_PLUGIN_VERSION}

ENV HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/"

