#!/bin/bash

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='nihilo.conf'
CONFIGFOLDER='/root/.nihilo'
COIN_DAEMON='nihilod'
COIN_CLI='nihilod'
COIN_PATH='/usr/local/bin/'
COIN_TGZ='https://github.com/nihilocoin/pos-resources/releases/download/2.0.0/Nihilo-Linux-CLI-V2'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='Nihilo'
COIN_PORT=5353
RPC_PORT=5454

NODEIP=$(curl -s4 api.ipify.org)


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function download_node() {
  echo -e "Prepare to download ${GREEN}$COIN_NAME${NC}."
  cd $TMP_FOLDER >/dev/null 2>&1
  wget -q $COIN_TGZ
  compile_error
  chmod +x $COIN_ZIP
  strip $COIN_ZIP
  cp $COIN_ZIP $COIN_DAEMON
  cp $COIN_DAEMON $COIN_PATH
  cd - >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}


function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid

ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}


function create_config() {
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=$RPC_PORT
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
port=$COIN_PORT
EOF
}

function create_key() {
  echo -e "Enter your ${RED}$COIN_NAME Masternode Private Key${NC}. Leave it blank to generate a new ${RED}Masternode Private Key${NC} for you:"
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
  $COIN_PATH$COIN_DAEMON >/dev/null 2>&1
  sleep 5
  $COIN_PATH$COIN_DAEMON -daemon >/dev/null 2>&1
  sleep 30
  if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
   echo -e "${RED}$COIN_NAME server couldn not start. Check /var/log/syslog for errors.{$NC}"
   exit 1
  fi
  COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  if [ "$?" -gt "0" ];
    then
    echo -e "${RED}Wallet not fully loaded. Let us wait and try again to generate the Private Key${NC}"
    sleep 30
    COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  fi
  $COIN_PATH$COIN_CLI stop
fi
clear
}

function update_config() {
  sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE

logintimestamps=1
maxconnections=256
#bind=$NODEIP
masternode=1
masternodeaddr=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY
addnode=159.89.230.236:5353
addnode=104.238.151.107:5353
addnode=104.156.249.56:5353
addnode=144.202.6.195:5353
addnode=45.77.190.226:5353
addnode=45.76.17.23:5353
addnode=207.148.64.219:5353
addnode=207.148.65.66:5353
addnode=45.77.139.153:5353
addnode=139.59.63.194:5353
addnode=172.104.243.224:5353
addnode=46.38.236.102:5353
addnode=46.38.232.78:5353
addnode=144.202.115.152:5353
addnode=207.246.110.242:5353
addnode=104.238.140.250:5353
addnode=46.38.237.7:5353
addnode=45.77.111.134:5353
addnode=18.222.60.114:5353
addnode=5.45.100.98:5353
addnode=144.202.103.41:5353
addnode=107.175.95.234:5454
addnode=172.245.124.130:5454
addnode=107.172.168.218:5454
addnode=172.245.110.111:5454
addnode=23.94.69.164:5454
addnode=194.67.207.15:5353
addnode=18.222.46.20:5353
addnode=159.89.16.22:5353
addnode=45.63.66.226:5353
addnode=45.76.7.57:5353
addnode=172.104.150.79:5353
addnode=45.77.230.108:5353
addnode=45.77.248.188:5353
addnode=13.125.222.240:5353
addnode=52.78.115.206:5353
addnode=159.65.53.106:5353
addnode=159.89.106.70:5353
addnode=45.76.137.130:5353
addnode=45.76.138.220:5353
addnode=45.76.52.147:5353
addnode=90.156.157.28:5353
addnode=45.77.121.183:5353
addnode=45.77.247.215:5353
addnode=18.219.190.135:5353
addnode=159.65.129.20:5353
addnode=139.162.156.72:5353
addnode=128.199.236.140:5353
addnode=45.63.4.88:5353
addnode=199.247.16.205:5353
addnode=45.76.135.64:5353
addnode=165.227.23.125:5353
addnode=199.247.1.138:5353
addnode=45.76.63.242:5353
addnode=144.202.64.102:5353
addnode=45.32.192.222:5353
addnode=207.148.2.227:5353
addnode=108.61.182.122:5353
addnode=45.32.101.234:13535
addnode=144.202.51.54:5353
addnode=45.76.243.154:5353
addnode=185.28.103.35:5353
addnode=108.61.219.62:5353
addnode=198.13.35.32:5353
addnode=178.239.54.228:5353
addnode=45.32.127.179:5353
addnode=199.247.28.195:5353
addnode=107.175.144.13:5353
addnode=37.148.210.11:5353
addnode=45.77.136.194:5353
addnode=199.247.16.157:5353
addnode=199.247.18.246:5353
addnode=45.76.91.232:5353
addnode=104.207.130.154:5353
addnode=198.13.35.234:5353
addnode=45.63.74.6:5353
addnode=104.238.176.62:5353
addnode=45.76.132.102:5353
addnode=45.77.89.33:5353
addnode=46.38.233.91:5353
addnode=104.238.145.134:5353
addnode=45.63.51.217:5353
addnode=45.77.121.151:5353
addnode=173.199.119.78:5353
addnode=45.77.215.6:5353
addnode=82.208.35.189:13535
addnode=45.76.62.91:5353
addnode=45.77.58.63:5353
addnode=45.32.123.0:5353
addnode=45.76.143.60:5353
addnode=83.169.34.206:5353
addnode=195.201.10.32:5353
addnode=159.89.231.153:5353
addnode=159.65.233.11:5353
addnode=138.68.190.136:5353
addnode=45.32.199.144:5353
addnode=209.250.243.219:5353
addnode=46.188.45.34:5353
addnode=62.77.155.120:5353
addnode=62.77.156.179:5353
addnode=80.209.224.248:5353
addnode=165.227.38.96:5353
addnode=159.65.159.56:5353
addnode=83.169.38.133:5353
addnode=185.183.182.176:5353
addnode=199.247.28.68:5353
addnode=199.247.18.137:5353
addnode=165.227.107.73:5353
addnode=45.63.34.212:5353
addnode=45.77.145.188:5353
addnode=37.148.211.246:5353
addnode=5.175.4.62:13536
addnode=82.208.35.185:5353
addnode=82.208.35.181:5353
addnode=45.32.186.13:5353
addnode=199.247.30.114:5353
addnode=45.63.91.1:5353
addnode=199.247.31.137:5353
addnode=199.247.24.139:5353
addnode=193.33.201.48:5353
addnode=199.247.25.105:5353
addnode=45.77.140.182:5353
addnode=45.77.3.196:5353
addnode=45.63.84.48:5353
addnode=199.247.25.94:5353
addnode=108.61.103.39:5353
addnode=209.250.246.204:5353
addnode=45.76.81.116:5353
addnode=194.169.239.231:5353
addnode=194.169.239.232:5353
addnode=194.169.239.233:5353
addnode=144.202.68.95:5353
addnode=199.247.16.249:5353
addnode=82.208.35.183:5353
addnode=82.208.35.174:13535
addnode=98.100.196.174:5353
addnode=159.89.82.141:5353
addnode=198.199.121.92:5353
addnode=45.35.73.195:5353
addnode=104.223.25.3:5353
addnode=45.76.169.241:5353
addnode=45.76.246.181:5353
addnode=45.77.135.193:5353
addnode=104.238.152.234:5353
addnode=70.167.245.140:5353
addnode=45.32.33.247:5353
addnode=110.232.113.53:5353
addnode=110.232.112.81:5353
addnode=110.232.114.6:5353
addnode=199.247.25.107:5353
addnode=45.76.214.241:5353
addnode=45.76.233.170:5353
addnode=34.245.65.93:5353
addnode=45.32.141.10:5353
addnode=192.227.174.12:5353
addnode=45.76.205.55:5353
addnode=68.233.236.105:5353
addnode=195.201.92.122:5353
addnode=198.13.42.92:5353
addnode=45.32.172.140:5353
addnode=144.202.89.58:5353
addnode=45.32.162.143:5353
addnode=45.32.157.231:5353
addnode=92.222.65.177:5353
addnode=94.156.35.190:5353
addnode=146.199.185.170:5353
addnode=138.68.59.86:5353
addnode=45.32.252.226:5353
addnode=199.247.16.18:5353
addnode=45.63.49.219:5353
addnode=172.106.3.203:5353
addnode=172.106.3.204:5353
addnode=199.247.5.188:5353
addnode=45.32.174.194:13535
addnode=199.247.5.78:5353
addnode=199.247.30.249:5353
addnode=207.148.78.70:5353
addnode=85.121.196.181:5353
addnode=108.61.207.229:5353
addnode=172.245.36.171:13535
addnode=209.250.253.136:5353
addnode=103.75.190.201:5353
addnode=45.76.135.199:5353
addnode=209.250.226.106:5353
addnode=107.173.250.24:5353
addnode=128.199.79.85:5353
addnode=199.247.29.180:5353
addnode=45.35.2.203:5353
addnode=173.199.70.251:5353
addnode=45.76.239.71:5353
addnode=45.79.207.203:5353
addnode=144.202.21.14:5353
addnode=107.173.250.70:5353
addnode=207.201.218.197:5353
addnode=68.233.236.104:5353
addnode=68.233.236.111:5353
addnode=68.233.236.116:5353
addnode=68.233.236.118:5353
addnode=82.16.238.35:5353
addnode=167.99.160.136:5353
addnode=199.247.28.178:5353
addnode=209.250.254.106:5353
addnode=199.247.26.86:5353
addnode=82.223.26.113:5353
addnode=45.77.47.127:5353
addnode=45.32.104.225:5353
addnode=80.211.211.231:5353
addnode=144.202.18.161:5353
addnode=185.224.249.64:5353
addnode=104.238.147.84:5353
addnode=207.246.116.221:5353
addnode=45.77.180.230:5353
addnode=68.233.236.103:5353
addnode=68.233.236.106:5353
addnode=68.233.236.107:5353
addnode=68.233.236.108:5353
addnode=68.233.236.109:5353
addnode=199.247.17.22:5353
addnode=68.233.236.117:5353
addnode=43.254.133.122:5353
addnode=68.233.236.110:5353
EOF
}


function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}


function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 api.ipify.org))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is already installed.${NC}"
  exit 1
fi
}

function prepare_system() {
echo -e "Prepare the system to install ${GREEN}$COIN_NAME${NC} master node."
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${GREEN}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip"
 exit 1
fi
clear
}

function important_information() {
 echo -e "================================================================================================================================"
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEY${NC}"
 echo -e "Please check ${RED}$COIN_NAME${NC} daemon is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "Use ${RED}$COIN_CLI masternode status${NC} to check your MN. A running MN will show ${RED}Status 9${NC}."
 echo -e "================================================================================================================================"
}

function setup_node() {
  get_ip
  create_key
  update_config
  enable_firewall
  important_information
  configure_systemd
}


##### Main #####
clear

checks
prepare_system
download_node
setup_node

