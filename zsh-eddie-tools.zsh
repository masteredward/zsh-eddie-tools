# Envs

KUBE_EDITOR="code --wait"; export KUBE_EDITOR

# Aliases

alias ls="lsd"
alias kubectl="kubecolor"
alias enable_venv="source .venv/bin/activate"
alias argocdpasswd='kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d'

# Functions

## Python Virtualenv

create_venv() {
  rm -rf .venv
  python3 -m virtualenv .venv
}

update_venv() {
  pip install --require-virtualenv --upgrade pip
  pip install --require-virtualenv --upgrade -r requirements.txt -r requirements-dev.txt
}

## Kubernetes

kube_exec() {
  local NAMESPACE="$1"
  local DEPLOY="$2"
  local COMMANDS=("${@:3}")
  if ! command -v kubectl > /dev/null 2>&1; then
    echo "kubectl is not installed in your machine."
    exit 1
  fi
  kubectl exec -it -n "$NAMESPACE" deploy/"$DEPLOY" -- ${COMMANDS[@]}
}

## Install/Update Apps

update_k9s() {
  local TARFILE=$(mktemp)
  local INSTALL_DIR=$(mktemp -d)
  case $(uname -m) in
    x86_64)
      local k9s_arch="amd64"
      ;;
    aarch64)
      local k9s_arch="arm64"
      ;;
    *) # Default case to handle other architectures or error
      echo "This function only supports x86_64 and aarch64 archs, not $(uname -m)"
      exit 1
      ;;
  esac
  curl -L https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_"$k9s_arch".tar.gz -o "$TARFILE"
  tar xvf "$TARFILE" -C "$INSTALL_DIR"
  sudo mv "$INSTALL_DIR"/k9s /usr/local/bin
  sudo chmod +x /usr/local/bin/k9s
  k9s version
}

update_awscli() {
  local ZIPFILE=$(mktemp)
  local INSTALL_DIR=$(mktemp -d)
  curl -L https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip -o "$ZIPFILE"
  unzip -q "$ZIPFILE" -d "$INSTALL_DIR"
  sudo "$INSTALL_DIR"/aws/install --update
  aws --version
}

update_ubuntu() {
  sudo apt update
  sudo apt full-upgrade -y
  sudo apt autoremove -y
  sudo snap refresh
}