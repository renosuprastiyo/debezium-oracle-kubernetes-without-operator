### debezium-oracle-kubernetes-without-operator

Using operator to deploy into microservices sometimes too much with much features we not used actually [Strimzi](https://strimzi.io) for example. So here we using kubernetes manifests for the sake of simplicity.
# Prerequisite
1. Installed kubernetes and docker <br />
Here i used docker desktop with enabling kubernetes cluster by Preferences -> Kubernetes -> Enable Kubernetes -> Apply & restart <br />
You also can using minikube, kubespray or native kubernetes(latest kubernetes version no longger support docker as container runtime only left cri-o or containerd as container runtime)
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
>docker build -f Dockerfile -t localhost:5000/debezium_custom:latest .<br />
>![build-debezium-custom-image](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/build-docker-image.png)<br />

Push image to local registry
>docker push localhost:5000/debezium_custom:latest<br />
>![push-image](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/push-image.png)<br />

Create namespace big-data for this project
>kubectl create namespace big-data<br />

Now we ready to deploy it to kubernetes
>kubectl create -f debezium.yaml<br />
>![deploy-kubernetes](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/deploy-kubernetes.png)<br />

Let see our pods
>kubectl get po -n big-data
>![get-pods](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/get-pods.png)<br />

Create debezium connector
>kubectl exec -it debezium-connect-7d45648fbb-rnmml -n big-data -- curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" debezium-connect-7d45648fbb-rnmml:8083/connectors/ -d @- <<EOF
{
    "name": "test-connector",
    "config": {
        "connector.class": "io.debezium.connector.oracle.OracleConnector",
        "tasks.max": "1",
        "database.server.name": "xxxxx",
        "database.oracle.version": 11,
        "database.hostname": "xxxxx",
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
        "database.history.kafka.topic": "dbz-history-topic",
        "database.history.kafka.bootstrap.servers": "debezium-kafka:9092",
        "debezium.log.mining.transaction.retention.hours": "1",
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
>![debezium-connector](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/debezium-connector.png)<br />

Let see our kafka topic
>kubectl run kafka-topics -it -n big-data --image=debezium/kafka:latest --rm=true --restart=Never -- bin/kafka-topics.sh --list --bootstrap-server debezium-kafka:9092
>![kafka-topic](https://github.com/renosuprastiyo/debezium-oracle-kubernetes-without-operator/blob/main/kafka-topic.png)
