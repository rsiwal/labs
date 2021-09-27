#!/bin/bash
set +x
#
# Setup the local Kubernetes Cluster
[ $# -ne 1 ] && echo "USAGE: [create|start|stop|delete|linkerd_desktop]" && exit 1

# Some beautification of console messages
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

# Login shell in local host machine
login_shell="zsh"   # Local aliases will be created

# Install the packages required for creating the K8s Cluster
required_packages="argocd k3d k9s helm kubectl terraform linkerd kubeseal kustomize"
docker_version="20.10.7"
docker_compose_version="1.29.2"
argocd_version="v2.1.2"
k3d_version="v4.4.8"
k9s_version="v0.24.15"
kubectl_version="v1.22.0"
helm_version="v3.7.0"
terraform_version="1.0.7"
metallb_version="v0.10.2"
lens_version="5.2.2-latest.20210918.1"
linkerd_version="stable-2.10.2"
linkerd_buoyant_version=v0.4.5
kubeseal_version="v0.16.0"
kustomize_version="v4.3.0"

cluster_name="lab"
no_of_master_nodes=1
no_of_worker_nodes=1
cluster_subnet="10.255.0.0/16"

service_names="argo-cd jenkins devtron vault sealed-secrets"
service_domain="example.com"

action=$1

case $action in
  create)
    export BIN_DIR=${HOME}/bin/
    [ "${SHELL}" = "*/bash" ]  && . "${HOME}"/.${login_shell}rc
    echo "${PATH}" | grep -q "${BIN_DIR}" || echo "export PATH=${BIN_DIR}:${PATH}" >> "${HOME}"/.${login_shell}rc
    export PATH=${PATH}:${BIN_DIR}

    mkdir -p "${BIN_DIR}"

    function install_linkerd_extensions() 
    {
      echo "${yellow}Install linkerd viz extension, which will install an on-cluster metric stack${reset}"
      linkerd viz install | kubectl apply -f -

      echo "${yellow}Install buoyant-cloud extension, which will connect to a hosted metrics stack.${reset}"
      export LINKERD_BUOYANT_VERSION=${linkerd_buoyant_version}
      export INSTALLROOT=${HOME}
      curl -sL buoyant.cloud/install | sh # get the installer
      linkerd buoyant install | kubectl apply -f - # connect to the hosted metrics stack

      echo "${yellow}Validating Linkerd${reset}"
      linkerd check

    }

    # Install required packages
    function install_package()
    {
      package_name=$1
      echo "${yellow}Installing Package ${package_name} :${reset}"
      case $package_name in
        k3d)
          curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | \
            USE_SUDO=false K3D_INSTALL_DIR=${BIN_DIR} TAG=${k3d_version} bash
          ;;
        k9s)
          curl -L  https://github.com/derailed/k9s/releases/download/${k9s_version}/k9s_Linux_x86_64.tar.gz --output /tmp/k9s_Linux_x86_64.tar.gz
          tar zxvf /tmp/k9s_Linux_x86_64.tar.gz
          mv k9s ${BIN_DIR}
         ;;
        helm)
          pushd /tmp/
          curl -LO https://get.helm.sh/helm-${helm_version}-linux-amd64.tar.gz
          tar zxvf helm-${helm_version}-linux-amd64.tar.gz
          mv linux-amd64/helm ${BIN_DIR}/
          popd
          ;;
        kubectl)
          curl -L https://dl.k8s.io/release/${kubectl_version}/bin/linux/amd64/kubectl \
            --output ${BIN_DIR}/kubectl
          ;;
        terraform)
          pushd /tmp/
          curl -LO https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
          unzip terraform_${terraform_version}_linux_amd64.zip
          mv terraform ${BIN_DIR}/
          ;;
        argocd)
          curl -L https://github.com/argoproj/argo-cd/releases/download/${argocd_version}/argocd-linux-amd64 \
            --output ${BIN_DIR}/argocd
          ;;
        linkerd)
          export LINKERD2_VERSION=${linkerd_version} 
          export INSTALLROOT=${HOME} 
          curl -sL run.linkerd.io/install | sh
          ;;
        kubeseal)
          curl -L https://github.com/bitnami-labs/sealed-secrets/releases/download/${kubeseal_version}/kubeseal-linux-amd64 --output ${HOME}/bin/kubeseal
          ;;
        kustomize)
          curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${kustomize_version}/kustomize_${kustomize_version}_linux_amd64.tar.gz \
            --output /tmp/kustomize.tgz
          tar zxvf /tmp/kustomize.tgz 
          mv kustomize ${HOME}/bin/
          ;;
      esac
    }

    function install_if_missing()
    {
      package_name=$1
      is_installed=1
      echo "${yellow}Install if $package_name is missing ${reset}"
      if [ ! -f ${BIN_DIR}/${package_name} ]
      then
        install_package ${package_name}
      else
        case $package_name in
          argocd)
            ${BIN_DIR}/argocd version --client 2>/dev/null |grep 'argocd:' | awk '{print $2}' |grep -q "^${argocd_version}"\
              || is_installed=0
            ;;
          k3d)
            [ `${BIN_DIR}/k3d version|grep 'k3d version'|awk '{print $3}'` != ${k3d_version} ] \
              && is_installed=0
            ;;
          k9s)
            [ `${BIN_DIR}/k9s version -s|grep "^Version"|awk '{print $2}'` != ${k9s_version} ] \
              && is_installed=0
            ;;
          helm)
            ${BIN_DIR}/helm version --short |grep -q "^${helm_version}" || is_installed=0
            ;;
          kubectl)
            [ `${BIN_DIR}/kubectl version --short|grep "Client Version:"|awk '{print $3}'` != ${kubectl_version} ] \
              && is_installed=0
            ;;
          terraform)
            [ `${BIN_DIR}/terraform version|grep "^Terraform"|awk '{print $2}'` != "v${terraform_version}" ] \
              && is_installed=0
            ;;
          linkerd)
            [ "$(linkerd version --short --client 2>/dev/null)" != "${linkerd_version}" ] \
              && is_installed=0
          ;;
          kubeseal)
          [ "$(kubectl version --short --client |awk '{print $3}' 2>/dev/null )" != "${kubectl_version}" ] \
            && is_installed=0
          ;;
          kustomize)
            [ "$(kustomize version --short |awk '{print $1}' 2>/dev/null )" != "\{kustomize/${kustomize_version}" ] \
              && is_installed=0
          ;;
        esac
        if [ ${is_installed} -eq 0 ]
        then
          install_package ${package}
        fi
      fi
    }

    function setup_nfs()
    {
      [ $(which /sbin/mount.nfs) ] || sudo apt install nfs-common
      mkdir -p ${HOME}/exports

    }

    for package in $required_packages
    do
      install_if_missing "${package}"
    done


    echo "${gren}Installing jq (if absent) ${reset}"
    command jq --version 2>/dev/null || sudo apt -y install jq

    echo "${yellow}Installing sipcalc (IP Calculation program) ${reset}"
    command sipcalc -v 2>/dev/null || sudo apt -y install sipcalc

    echo "${yellow}Settings up K8s cluster ${cluster_name} ${reset}"
    "${BIN_DIR}"/k3d cluster list --output json|jq -r .[].name |grep -wq "${cluster_name}" || \
      "${BIN_DIR}"/k3d cluster create "${cluster_name}" --servers ${no_of_master_nodes} \
      --agents ${no_of_worker_nodes} --wait \
      --subnet ${cluster_subnet}

    chmod +x -R "${BIN_DIR}"

    echo "${yellow}Settings up NFS Server ${reset}"
    setup_nfs

    echo "${yellow}Settings up the kubeconfig ${reset}"
    export KUBECONFIG=$(k3d kubeconfig write ${cluster_name})

    echo "${yellow}Fixing permission for local-path-config persistent volumes"
    kubectl apply -f $(dirname $0)/local-path-config.yaml

    echo "${yellow}Installing Devtron ${reset}"
    pushd ../terraform/helm-charts
    terraform init
    terraform apply
    popd

    #echo "${yellow}Setting up Ingresses for Services"

    echo "${yellow}Adding Secret for Ingress${reset}"
    kubectl apply -f $(dirname $0)/example-com-tls-cert.yaml

    node_ips=$(kubectl get nodes  -o jsonpath='{.items[*].status.addresses[].address}')
    for service in $service_names
    do
      echo "${yellow}Setting up Ingress for $service${reset}"
      service_name=${service}
      namespace=${service}
      service_port=80
      case $service in
        jenkins)
          export service_port="8080"
          ;;
        vault)
          namespace="hashicorp-vault"
          service_name="hashicorp-vault-internal"
          service_port="8200"
          ;;
        argo-cd)
          service_name="argo-cd-argocd-server"
          service_port="80"
          ;;
        sealed-secrets)
          service_port="8080"
          ;;
        *)
          service_port=80
          ;;
      esac
      export service
      export service_name
      export namespace
      export service_port
      envsubst <ingresses-template.yaml | kubectl apply -f -

      echo "${yellow}Updating the hosts entries"
      for ip in $node_ips
      do
        echo "${yellow}Adding Hosts entries${reset}"
        grep -q "$ip  ${service}.${service_domain}" /etc/hosts || echo "$ip  ${service}.${service_domain}" | sudo -p "Enter local host password for updating the hosts file" tee -a /etc/hosts
      done
    done

    echo "${yellow}Checking and Installing Linked${reset}"
    linkerd check --pre && linkerd install | kubectl apply -f -
    install_linkerd_extensions

    echo "${yellow}Download the Kubeseal Certificate${reset}"
    mkdir -p ${HOME}/certs
    curl -L http://sealed-secrets.example.com/v1/cert.pem --output ${HOME}/certs/kubeseal.pem
    #kubeseal --fetch-cert --controller-name=sealed-secrets --controller-namespace=sealed-secrets > ${HOME}/certs/kubeseal.pem

    grep -q 'export SEALED_SECRETS_CERT=' ${HOME}/.${login_shell}rc || echo 'export SEALED_SECRETS_CERT=${HOME}/certs/kubeseal.pem' >> ${HOME}/.${login_shell}rc
    ;;
  stop)
    k3d cluster stop ${cluster_name}
    ;;
  start)
    k3d cluster start ${cluster_name} 
    ;;
  delete)
    k3d cluster delete ${cluster_name} 
    ;;
  status)
    k3d cluster list
    # echo -e "\n${yellow}Login details for Devtron Dashboard ${reset}"
    # echo Devtron UserName: admin
    # echo Devtron Password: `kubectl -n devtroncd get secret devtron-secret -o jsonpath='{.data.ACD_PASSWORD}' | base64 -d`
    # echo "Grafana UserName: admin"
    # echo "Grafana Password: `kubectl -n devtroncd get secret devtron-grafana-cred-secret -o jsonpath='{.data.admin-password}' | base64 -d`"

    echo -e "\n${yellow}Login details for Jenkins${reset}"
    jsonpath="{.data.jenkins-admin-password}"
    secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
    password=$(echo $(echo $secret | base64 --decode))
    echo "Jenkins URL: http://jenkins.example.com/"
    echo "UserName: admin"
    echo "Password: ${password}"

    echo -e "\n${yellow}Argo-CD URL: https://argo-cd.example.com:30443${reset}"
    argocd_password=$(kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64 -d)
    echo "UserName: admin"
    echo "Password: ${argocd_password}"

    echo -e "\n${yellow}Vault URL: http://vault.example.com/${reset}" 
    echo "Make sure to initialise Vault if NOT already done"
    echo "1. SSH to vault pod"
    echo "2. vault operator init"
    echo "3. vault operator unseal"

    echo -e "\nLinkerd Desktop : Run the command 'linkerd viz dashboard' "
    echo -e "\nKubeseal Certificate URL : http://sealed-secrets.example.com/v1/cert.pem"
    echo -e "Kubeseal Certificate location : ${HOME}/certs/kubeseal.pem"
    ;;
  linkerd_desktop)
    linkerd viz dashboard
    ;;
  help)
    echo -e "\n${yellow}Creating Selaed Secret${reset}: kubeseal < test-secret.yaml > test-secret-encrypted.yaml"
    ;;
  *)
    echo "UNKNOWN Action"
    ;;
esac

