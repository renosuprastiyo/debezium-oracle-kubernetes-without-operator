### debezium-oracle-kubernetes-without-operator

Using operator to deploy into microservices sometimes too much with much features we not used actually. So here we using kubernetes manifests only to keep it lean.
# Prerequisite
1. Installed kubernetes and docker <br />
Here i used docker desktop with enabling kubernetes cluster by Preferences -> Kubernetes -> Enable Kubernetes -> Apply & restart <br />
You also can using minikube, kubespray to provisioning kubernetes
![docker-desktop](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/docker-desktop.png)
2. Download oracle client <br />
You can find it here [instant-client](https://www.oracle.com/database/technologies/instant-client/downloads.html) <br />
3. Oracle prep <br />
You can find how to prepare oracle database here [Oracle-Prep](https://debezium.io/documentation/reference/stable/connectors/oracle.html#_preparing_the_database)<br />
# Getting Started
First thing we have to setup local registry for docker image we built
>docker run -d -p 5000:5000 --restart=always --name registry -e REGISTRY_VALIDATION_DISABLED=true registry:2<br /><br />
>![local-registry](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/local-registry.png)<br />

Then build our debezium custom image
>docker build -f Dockerfile -t localhost:5000/debezium:latest .<br />
>![build-debezium-custom-image](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/build-docker-image.png)<br />

Push image to local registry
>docker push localhost:5000/debezium:latest<br />
>![push-image](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/push-image.png)<br />

Create namespace big-data for this project
>kubectl create namespace big-data<br />

Now we ready to deploy it to kubernetes
>kubectl create -f debezium.yaml<br />
>![deploy-kubernetes](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/deploy-kubernetes.png)<br />

Let see our pods
>kubectl get po -n big-data
>![get-pod](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/get-pod.png)<br />

Create kafka connector
>curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" debezium-connect-58f569fdfb-w4t2m:8083/connectors/ -d @- <<EOF
{
    "name": "test-connector",
    "config": {
        "connector.class": "io.debezium.connector.oracle.OracleConnector",
        "tasks.max": "1",
        "database.server.name": "DBMEISTER",
        "database.oracle.version": "11",
        "database.hostname": "192.168.0.1",
        "database.port": "1521",
        "database.user": "xxxxx",
        "database.password": "xxxxx",
        "database.dbname" : "orcltes",
        "table.include.list": "2000bgr.test",
        "database.out.server.name": "dboprxout",
        "include.schema.changes": "true",
        "snapshot.mode": "initial",
        "topic.prefix": "dbz-topic",
        "database.tablename.case.insensitive": "true",
        "database.history.skip.unparseable.ddl": "true",
        "errors.log.enable": "true",
        "database.history.kafka.topic": "schema-changes.inventory",
        "database.history.kafka.bootstrap.servers": "debezium-kafka:9092",
        "debezium.log.mining.transaction.retention.hours": "3",
        "event.processing.failure.handing.mode": "warn",
        "log.mining.batch.size.default": "100000",
        "log.mining.batch.size.min": "10000",
        "log.mining.batch.size.max": "1000000",
        "log.mining.sleep.time.default": "200",
        "log.mining.sleep.time.min": "0",
        "log.mining.sleep.time.max": "1000",
        "log.mining.sleep.time.increment": "100",
        "log.mining.scn.gap.detection.gap.size.min": "1000"
    }
}
EOF
<br />
>![kafka-connector](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/kafka-connector.png)
