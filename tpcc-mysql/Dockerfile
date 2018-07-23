FROM arm64v8/ubuntu:16.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive  apt-get install -y gcc libc6-dev zlib1g-dev make libmysqlclient-dev mysql-server emacs

ADD . /tpcc-mysql
ENV PATH /tpcc-mysql:$PATH
WORKDIR /tpcc-mysql
RUN cd src && make
#RUN /tpcc-mysql/entrypoint.sh
#ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["/tpcc-mysql/entrypoint.sh"]