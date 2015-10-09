FROM 				centos:centos7

COPY 				tor-0.2.6.8-tor.1.rh7_1_1503.x86_64.rpm .

RUN 				yum install -y epel-release && \
						yum install -y supervisor ruby ruby-devel make gcc
RUN  	 			yum install -y ./tor-0.2.6.8-tor.1.rh7_1_1503.x86_64.rpm
RUN 				mkdir -p /tmp/{run,tmp} && mkdir -p /tmp/log/supervisord
RUN 				mkdir -p /tmp/tordata/tor_port_{9050..9100}
RUN					gem install -N bundler

WORKDIR 		/src

ENTRYPOINT 	/usr/bin/supervisord -c /src/supervisord.conf

EXPOSE 			9292
EXPOSE 			9050-9100

COPY 				. /src/.
RUN					bundle install -j 4
