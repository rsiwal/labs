#!/bin/bash
# Creates Kubernetes Cluster
# The name of the Lab. All LXD resources are prefixed by this name
export LAB_NAME="k8s-lab"

# Codename for the Ubuntu Image to be used
UBUNTU_CODENAME="focal"

# Container name for Control Plane
CONTROL_PLANE_NAME="control-plane"
NODE_NAMES=${CONTROL_PLANE_NAME}
NUMBER_OF_WORKER_NODES=2

# Version of Kubernetes to be installed
K8S_VERSION=1.21.1
KUBELET_VERSION="${K8S_VERSION}-00"
KUBEADM_VERSION="${K8S_VERSION}-00"
KUBECTL_VERSION="${K8S_VERSION}-00"
POD_NETWORK_CIDR="10.244.0.0/16"

# NFS and Persistent Volumes setup
SETUP_NFS_SERVER_ON_LOCAL_MACHINE=yes
PV_SIZE=1Gi
PV_COUNT=10

# Helm
HELM_VERSION=v3.5.4

# Some beautification of console messages
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
RESET=`tput sgr0`

for node_id in `seq -f %02g 1 $NUMBER_OF_WORKER_NODES`
do
  NODE_NAMES="${NODE_NAMES} node$node_id"
done

[ $# -ne 1 ] && echo "USAGE: $0 create|destroy|info" && exit 1
case $1 in 
  create)
    echo -e "${GREEN}Installing LXD and helper packages ${RESET}"
    sudo apt install lxd
    sudo apt install lxc-utils

    echo -e "${GREEN}Installing the required packages${RESET}"
    sudo apt install jq

    echo -e "${GREEN}Adding User to the group lxd${RESET}"
    sudo usermod $USER -G lxd
    lxc image ls >/dev/null || ( echo "Please re-login to get the permissions to the socket" && exit 1 )

    echo "${GREEN}Creating Bridge Network${RESET}"
    lxc network list |awk '{print $2}'|grep -w ${LAB_NAME} || envsubst < lxd-networks.yml | lxd init --preseed

    echo "${GREEN}Creating Storage Pool${RESET}"
    lxc storage list |awk '{print $2}'|grep -w ${LAB_NAME} || envsubst < lxd-storage-pools.yml | lxd init --preseed

    echo "${GREEN}Creating LXD Profile${RESET}"
    lxc profile list |awk '{print $2}'|grep -w ${LAB_NAME} || envsubst < lxd-profiles.yml | lxd init --preseed

    echo -e "${GREEN}Creating LXC VMs${RESET}"
    for container in $NODE_NAMES
    do
      if [ `lxc list |awk '{print $2}'|grep -sw $container | wc -l` -eq 0 ]
      then
        sleep 30
        lxc init -p ${LAB_NAME} images:ubuntu/${UBUNTU_CODENAME} $container --vm -c limits.memory=4096MB -c limits.cpu=2
        lxc start $container

        echo "${GREEN}Waiting for the container to boot.${RESET}"
        sleep 30
      fi
    done

    echo -e "${GREEN}Following LXD containers created${RESET}"
    lxc list

    echo -e "${GREEN}Setting up required packages (kubeadm, kubelet, kubectl and docker-runtime) in all nodes${RESET}"
    for node in $NODE_NAMES
    do
        lxc shell $node <<EOF
        sudo apt -y install curl apt-transport-https ca-certificates  gnupg
        curl -sLO https://packages.cloud.google.com/apt/doc/apt-key.gpg 
        sudo apt-key add apt-key.gpg
        curl -fsSLO https://download.docker.com/linux/ubuntu/gpg 
        sudo apt-key add gpg
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt -y install kubelet=${KUBELET_VERSION} kubeadm=${KUBEADM_VERSION} kubectl=${KUBECTL_VERSION}
        sudo apt-mark hold kubelet kubeadm kubectl
        #echo 'Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"' >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
        systemctl daemon-reload
        sudo apt-get -y install docker-ce docker-ce-cli containerd.io
        apt-get -y install linux-image-$(uname -r)
        systemctl enable docker
        systemctl enable kubelet
        # Install cloud-guest-utils to manage disk and fill the root partition to the maximum available disk volume
        sudo apt -y install cloud-guest-utils
        # Install nfc common (Required if you are using NFS as PV)
        sudo apt -y install nfs-common
        sudo apt install jq
        growpart /dev/sda 2
        resize2fs /dev/sda2
EOF
    done

    echo "${GREEN}Configure Control-Plane if not setup${RESET}"
    lxc exec ${CONTROL_PLANE_NAME} -- bash -c "KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes" 2>/dev/null
    if [ $? -ne 0 ]
    then
      echo -e "${GREEN}Setting up Master Node ${CONTROL_PLANE_NAME} ${RESET}"
      lxc shell ${CONTROL_PLANE_NAME} <<EOF
      kubectl get nodes || kubeadm init --pod-network-cidr=${POD_NETWORK_CIDR}
      echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >/etc/profile.d/kubeconfig.sh
      mkdir -p ~/.kube/
      cp -vf /etc/kubernetes/admin.conf ~/.kube/config
      chmod 600 ~/.kube/config
      kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
      curl -LO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && tar zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz linux-amd64/helm && mv linux-amd64/helm /usr/local/bin/ 
EOF
    fi

    echo "${GREEN}Wait until all the pods in Kube-system are running${RESET}"
    while [ true ]
    do
      echo -ne "."
      sleep 1
      lxc exec ${CONTROL_PLANE_NAME} -- bash -c "KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n kube-system get pod --no-headers|grep -vw Running" || break
    done

    echo "${GREEN}Getting the join command from Control Plane${RESET}"
    lxc exec ${CONTROL_PLANE_NAME} -- kubeadm token create --print-join-command > /tmp/kubeadmin-join-command

    echo -e "${GREEN}Registering the nodes. Manual as of today${RESET}"
    for node in $NODE_NAMES
    do
      [ $node == $CONTROL_PLANE_NAME ] && continue
      lxc exec ${CONTROL_PLANE_NAME} -- kubectl get nodes |grep -w $node || ( lxc file push /tmp/kubeadmin-join-command ${node}/kubeadmin-join-command && lxc shell ${node} -- bash /kubeadmin-join-command )
    done

    echo "${GREEN}Status of Kube-System Pods Control-Plane${RESET}"
    lxc exec ${CONTROL_PLANE_NAME} -- kubectl -n kube-system get pods

    echo "${GREEN}Status of nodes${RESET}"
    lxc exec ${CONTROL_PLANE_NAME} -- kubectl get nodes

    if [ $SETUP_NFS_SERVER_ON_LOCAL_MACHINE == "yes" ]
    then
      echo "${GREEN}Setting up NFS Server. We will be needing it as a PV${RESET}"
      sudo apt -y install nfs-kernel-server && sudo systemctl enable nfs-kernel-server && sudo systemctl restart nfs-kernel-server
      sudo mkdir -p /opt/labs/
      sudo chmod 777 /opt/labs/
      grep -sq ^/opt/labs /etc/exports || echo "/opt/labs *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
      sudo exportfs -r
    fi

    echo "${GREEN}Setting up some Persistent Volumes${RESET}"
    TEMP_PV_FILE=`tempfile`.yml
    for index in `seq 1 $PV_COUNT`
    do
      cat >> $TEMP_PV_FILE <<EOF
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-labs-${index}
spec:
  capacity:
    storage: ${PV_SIZE}
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: ""
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /opt/labs
    server: $(ip a show dev `ip r |grep default|awk '{print $5}'`|grep "inet "|awk '{print $2}'|cut -d/ -f1)

EOF
    done
    lxc file push $TEMP_PV_FILE ${CONTROL_PLANE_NAME}/tmp/pv.yml
    lxc exec ${CONTROL_PLANE_NAME} -- sh -c "kubectl apply -f /tmp/pv.yml"
    rm -vf ${TEMP_PV_FILE}
    
  echo "${GREEN}Installing Argo CD CLI in ${CONTROL_PLANE_NAME}${RESET}"
  lxc exec ${CONTROL_PLANE_NAME} -- sh -c "curl -LO https://github.com/argoproj/argo-cd/releases/download/v2.0.1/argocd-util-linux-amd64 && chmod +x argocd-util-linux-amd64 && mv argocd-util-linux-amd64 /usr/local/bin/argocd"

  echo "${YELLOW}Agro CD Username: admin${RESET}"
  echo "${YELLOW}Agro CD Password: `lxc exec ${CONTROL_PLANE_NAME} -- sh -c "kubectl -n argocd-lab get secret argocd-initial-admin-secret -o json|jq -r .data.password |base64 -d"`${RESET}"
  ;;
  destroy)
    echo "${RED}Deleting VMs${RESET}"
    for container in `lxc list|awk '{print $2}'|sed 's/|//;s/NAME//'`
    do
      lxc stop $container || true
      lxc delete $container
    done

    echo "${RED}Deleting Network${RESET}"
    lxc network list |grep -qw ${LAB_NAME} && ( sudo ifconfig ${LAB_NAME} down 2>/dev/null; sudo brctl delbr ${LAB_NAME} 2>/dev/null; lxc network delete ${LAB_NAME} )

    echo "${RED}Deleting Profile${RESET}"
    lxc profile list |grep -qw ${LAB_NAME} && sudo lxc profile delete ${LAB_NAME}

    echo "${RED}Deleting storage${RESET}"
    lxc storage list |grep -qw ${LAB_NAME} && lxc storage delete ${LAB_NAME}
  ;;
  info)
  echo "Agro CD Default Username: admin"
  echo "Agro CD Default Password: `lxc exec ${CONTROL_PLANE_NAME} -- sh -c "kubectl -n argocd-lab get secret argocd-initial-admin-secret -o json|jq -r .data.password |base64 -d"`"
  echo "IP Addresses :"
  lxc list --format=json |jq -r '["VM Name", "IPv4_Address", "IPv6_Address"] ,(.[] | [ .name, .state.network.enp5s0.addresses[].address])|@tsv'

  ;;
  *)
    echo "Unknown action $1 . USAGE: $0 create|destroy"
  ;;
esac
