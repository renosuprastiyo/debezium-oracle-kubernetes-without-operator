FROM debezium/connect:latest
USER root:root
ENV KAFKA_CONNECT_JDBC_DIR=$KAFKA_CONNECT_PLUGINS_DIR/kafka-connect-jdbc
ENV INSTANT_CLIENT_DIR=/instant_client/

USER root

COPY instantclient_12_2/libocijdbc12.so /usr/lib
COPY instantclient_12_2/libclntsh.so.12.1 /usr/lib

COPY instantclient_12_2/xstreams.jar /lib
COPY instantclient_12_2/ojdbc8.jar /lib

USER 1001

COPY instantclient_12_2/* $INSTANT_CLIENT_DIR
COPY instantclient_12_2/xstreams.jar /kafka/libs
COPY instantclient_12_2/ojdbc8.jar /kafka/libs

ENV LD_LIBRARY_PATH=/instant_client:{$LD_LIBRARY_PATH}
ENV PATH=/instant_client:{$PATH}
