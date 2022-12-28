### debezium-oracle-kubernetes-without-operator

Using operator to deploy into microservices sometimes too much with much features we not used actually. So here we using kubernetes manifests only to keep it lean.
# Prerequisite
1. Installed kubernetes and docker <br />
Here i used docker desktop with enabling kubernetes cluster by Preferences -> Kubernetes -> Enable Kubernetes -> Apply & restart <br />
You also can using minikube, kubespray to provisioning kubernetes
![docker-desktop](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/docker-desktop.png)
2. Oracle client <br />
You can find it here [instant-client](https://www.oracle.com/database/technologies/instant-client/downloads.html)
