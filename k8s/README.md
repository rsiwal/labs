# Kubernetes Lab
This is a lab setup, that uses LXD Virtual Machines to setup the Kubernetes cluster

# Setting up a new K8s cluster
```
:~/labs/k8s$./kubernetes_cluster.sh create
```

# Destroying the K8s Cluster
```
:~/labs/k8s$./kubernetes_cluster.sh destroy
```

# Customization is required
Feel free to update the variables as per your needs.
1. NUMBER_OF_WORKER_NODES : In case you need more than one
2. K8S_VERSION : In case you want to play with Cluster upgrade process

Apply the changes by the following command:
```
$./kubernetes_cluster.sh create
```

# Upgrading the K8s Cluster Version
Please recreate the K8s cluster in you need to upgrade / downgrade the K8s cluster
```
:~/labs/k8s$./kubernetes_cluster.sh destroy
:~/labs/k8s$./kubernetes_cluster.sh create

```
# How to login into the server 
```
:~/labs/k8s$ lxc shell control-plane
root@control-plane:~# kubectl get nodes
NAME            STATUS   ROLES    AGE   VERSION
control-plane   Ready    master   42m   v1.19.10
node01          Ready    <none>   41m   v1.19.10
root@control-plane:~# kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6799fc88d8-sjpwl   1/1     Running   0          9m19s
root@control-plane:~# 

```
```
:~/labs/k8s$ lxc shell node01
root@node01:~# 
```
