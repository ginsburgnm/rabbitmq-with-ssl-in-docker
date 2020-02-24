FROM rabbitmq:3-management

RUN apt-get update
RUN apt-get install apt-transport-https openssl -y \
	&& mkdir -p /home/testca/certs \
	&& mkdir -p /home/testca/private \
	&& chmod 700 /home/testca/private \
	&& echo 01 > /home/testca/serial \
	&& touch /home/testca/index.txt

COPY rabbitmq.config /etc/rabbitmq/rabbitmq.conf
COPY openssl.cnf /home/testca
COPY prepare-server.sh generate-client-keys.sh /home/

RUN mkdir -p /home/server \
	&& mkdir -p /home/client \
	&& chmod +x /home/prepare-server.sh /home/generate-client-keys.sh

RUN /bin/bash /home/prepare-server.sh \
    rabbitmq-server restart

CMD /bin/bash /home/generate-client-keys.sh; rabbitmq-server
