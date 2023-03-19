#!/bin/bash
#
# Copyright (c) 2019 Anebit Inc.
# All rights reserved.
#
# "Setup VPN Server" version 1.0
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#    * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#    * Neither the name of Anebit Inc. nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL__ THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES_; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ---
# Author:  Richard
# Created: 2017-08-30 10:46:00
# E-mail:  richard.zen.liew@gmail.com
#
# ---
# Description:
#   Setup vpn server for linux.
#
# ---
# Usage:
#   nohup /bin/bash -c \
#       "$(curl -fsSL https://github.com/RichardLiew/setup-vpn-server/raw/master/setup.sh)” \
#       >> ./setup-vpn-server.log 2>&1 &
#
# ---
# TODO (@Richard):
#   1. yum remove quiet mode;
#   2. docker cp file not exists;
#   3. IKEv2 mode;
#   4. all input yes or y during installing;
#   5. getopt and getopts;
#   6. help and usage info within man command;
#   7. print info;
#   8. colorful info.
#
###############################################################################

# exit immediately if a simple command exits with a non-zero
set -e

################################################################################
#
# DEFAULT OPTIONS
#
################################################################################

WORKDIR="."

SERVER_ROOT_PASSWORD='Richard.Liew'

VPN_IPSEC_PSK='00000000000000000000'
VPN_USER='Richard'
VPN_PASSWORD='richard.liew'
VPN_ADDL_USERS='u1 u2 u3'
VPN_ADDL_PASSWORDS='p1 p2 p3'

################################################################################

# assign password to sudo command
echo "${SERVER_ROOT_PASSWORD}" | sudo -S ls > /dev/null 2>&1

################################################################################

# create directories of workdir
sudo mkdir -p ${WORKDIR}

################################################################################

# install docker in centos system
sudo yum remove -qy \
    docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum-config-manager --enable docker-ce-nightly
sudo yum makecache fast
sudo yum install -y docker-ce docker-ce-cli containerd.io

################################################################################

# start docker service
sudo systemctl start docker

################################################################################

# create environment config file
sudo echo "
${VPN_IPSEC_PSK}
${VPN_USER}
${VPN_PASSWORD}
${VPN_ADDL_USERS}
${VPN_ADDL_PASSWORDS}
" > ${WORKDIR}/ipsec-vpn.env

################################################################################

# pull docker images
sudo docker pull hwdsl2/ipsec-vpn-server

# run docker container
sudo docker run \
    --name ipsec-vpn-server \
    --env-file ${WORKDIR}/ipsec-vpn.env \
    --restart=always \
    -v /lib/modules:/lib/modules:ro \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -d \
    --privileged \
    hwdsl2/ipsec-vpn-server

# copy useful container files to current directory
sudo docker cp ipsec-vpn-server:/etc/ipsec.d/* ${WORKDIR}/

################################################################################
#
# DOCKER CONTAINER OPERATIONS
#
################################################################################

# check status of docker containers
#sudo docker ps -a

# check logs of container
#sudo docker logs ipsec-vpn-server

# check contents of /etc/ipsec.d in the container
#sudo docker exec -it ipsec-vpn-server ls -l /etc/ipsec.d

################################################################################
#
# REMOTE OPERATIONS
#
################################################################################

# connect to remote server
#ssh root@<IP> -p <PORT>

# test udp port
#nc -vuz <UDP-IP> <UDP-PORT>

# test tcp port
#telnet <TCP-IP> <TCP-PORT>

################################################################################
#
# FIREWALL OPERATIONS
#
################################################################################

# open firewall
#systemctl start firewalld

# close firewall
#systemctl stop firewalld

# enable startup
#systemctl enable firewalld

# disable startup
#systemctl disable firewalld

# add port
#firewall-cmd --zone=public --add-port=<PORT>/<tcp|udp> --permanent
#firewall-cmd --reload

# check port
#firewall-cmd --query-port=<PORT>/<tcp|udp>

# list ports
#firewall-cmd --list-port
