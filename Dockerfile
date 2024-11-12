ARG UPSTREAM_VERSION="v2.13.0"
FROM quay.io/argoproj/argocd:$UPSTREAM_VERSION

ENV HELM_PLUGINS=/custom-tools/helm-plugins/ \
  HELM_SECRETS_CURL_PATH=/custom-tools/curl \
  HELM_SECRETS_SOPS_PATH=/custom-tools/sops \
  HELM_SECRETS_VALS_PATH=/custom-tools/vals \
  HELM_SECRETS_KUBECTL_PATH=/custom-tools/kubectl \
  HELM_SECRETS_BACKEND=sops \
  HELM_SECRETS_VALUES_ALLOW_SYMLINKS="false" \
  HELM_SECRETS_VALUES_ALLOW_ABSOLUTE_PATH="true" \
  HELM_SECRETS_VALUES_ALLOW_PATH_TRAVERSAL="false" \
  HELM_SECRETS_WRAPPER_ENABLED="true" \
  HELM_SECRETS_DECRYPT_SECRETS_IN_TMP_DIR="true" \
  HELM_SECRETS_HELM_PATH=/usr/local/bin/helm

ARG HELM_SECRETS_VERSION="4.5.1"
ARG HELM_GIT_VERSION="0.15.1"
ARG KUBECTL_VERSION="1.28.5"
ARG VALS_VERSION="0.24.0"
ARG SOPS_VERSION="3.8.1"
ARG JQ_VERSION="1.6"
ARG DOCTL_VERSION="1.117.0"

USER root
RUN apt-get update && \
  apt-get install -y \
  wget curl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN \
  export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac); \
  export OS=$(uname | awk '{print tolower($0)}'); \
  \
  mkdir -p /custom-tools/helm-plugins; \
  mkdir -p /custom-tools/helm-plugins/helm-git; \
  \
  wget -qO- https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/helm-secrets.tar.gz | tar -C /custom-tools/helm-plugins -xzf-; \
  wget -qO- https://github.com/aslafy-z/helm-git/archive/refs/tags/v${HELM_GIT_VERSION}.tar.gz | tar --strip-components=1 -C /custom-tools/helm-plugins/helm-git -xzf-; \
  wget -qO- https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${ARCH}.tar.gz | tar -xzf- -C /custom-tools/ vals; \
  wget -qO- https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-${ARCH}.tar.gz | tar -xzf- -C /custom-tools/ doctl; \
  \
  wget -qO /custom-tools/curl https://github.com/moparisthebest/static-curl/releases/latest/download/curl-amd64; \
  wget -qO /custom-tools/sops https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64; \
  wget -qO /custom-tools/jq https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64; \
  wget -qO /custom-tools/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl; \
  wget -qO /custom-tools/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64; \
  \
  cp /custom-tools/helm-plugins/helm-secrets/scripts/wrapper/helm.sh /custom-tools/helm; \
  \
  chmod a+x /custom-tools/sops; \
  chmod a+x /custom-tools/jq; \
  chmod a+x /custom-tools/yq; \
  chmod a+x /custom-tools/curl; \
  chmod a+x /custom-tools/kubectl; \
  chmod a+x /custom-tools/doctl

USER argocd
