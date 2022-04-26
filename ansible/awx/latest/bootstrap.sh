#!/bin/sh

# **************** Install Ansible AWX on Ubuntu ****************

required_packages_installation(){
  echo ">>>>>>>>>> Install the EPEL repository in your system"
  sudo apt install git build-essential curl jq -y
}

k3s_installation(){
  echo ">>>>>>>>>> Installing k3s"
  curl -sfL https://get.k3s.io | sudo bash -
  sudo chmod 644 /etc/rancher/k3s/k3s.yaml

  mkdir -p $HOME/.kube
  sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  echo "k3s is now installed on your Ubuntu system"
}

awx_operator_installation(){
  echo ">>>>>>>>>> Installing Ansible AWX Operator"
  git clone https://github.com/ansible/awx-operator.git

  export NAMESPACE=awx
  echo ">>>>>>>>>> Creating Kubernetes namespace for AWX"
  kubectl create ns ${NAMESPACE}

  echo ">>>>>>>>>> Set current context to $NAMESPACE"
  kubectl config set-context --current --namespace=$NAMESPACE 

  cd awx-operator/

  RELEASE_TAG=`curl -s https://api.github.com/repos/ansible/awx-operator/releases/latest | grep tag_name | cut -d '"' -f 4`

  echo ">>>>>>>>>> Latest release version for AWX Operator -> $RELEASE_TAG"
  git checkout $RELEASE_TAG

  echo "Deploying Ansible AWX Operator in cluster"
  export NAMESPACE=awx
  make deploy
  # Don’t run this unless you’re sure it uninstalls!
  # export NAMESPACE=awx
  # make undeploy

  # Check pods in cluster
  # kubectl get pods

  cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: static-data-pvc
  namespace: awx
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 5Gi
EOF
  # Check pvc resource in cluster
  # kubectl get pvc -n awx

  echo "Defining AWX deployment file with basic information about what is installed"
  cat <<EOF >> awx-deploy.yml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
  namespace: awx
spec:
  service_type: nodeport
  projects_persistence: true
  projects_storage_access_mode: ReadWriteOnce
  web_extra_volume_mounts: |
    - name: static-data
      mountPath: /var/lib/projects
  extra_volumes: |
    - name: static-data
      persistentVolumeClaim:
        claimName: static-data-pvc
---
apiVersion: v1
kind: Secret
metadata:
  name: awx-admin-password
  namespace: awx
stringData:
  password: ansible.awx2022
EOF

  echo "Applying configuration manifest file"
  kubectl apply -f awx-deploy.yml
  
  # Check awx user's password in secret 
  # kubectl get secret awx-admin-password -o jsonpath="{.data.password}" | base64 --decode
  # kubectl get secret awx-admin-password -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'

  # minikube kubectl exec pod/<awx_pod_name> -- --container awx-web -it awx-manage createsuperuser

  echo "Ansible AWX Operator is now installed on your Ubuntu system"
}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'apt-get update && apt-get upgrade'"
  exit
fi

# Update package list and upgrade all packages
apt-get update
apt-get -y upgrade

# Required packages Installation
required_packages_installation

# Docker Installation
k3s_installation

# Ansible Installation
awx_operator_installation

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created Ansible AWX virtual machine."
