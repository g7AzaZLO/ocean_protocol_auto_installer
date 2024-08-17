#!/bin/bash

echo -e "\033[1;36m"
echo -e "░██████╗░███████╗░░░░░░███████╗██╗░░░░░░█████╗░████████╗██╗░█████╗░███╗░░██╗░█████╗░██████╗░███████╗░██████╗"
echo -e "██╔════╝░╚════██║░░░░░░██╔════╝██║░░░░░██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔══██╗██╔══██╗██╔════╝██╔════╝"
echo -e "██║░░██╗░░░░░██╔╝█████╗█████╗░░██║░░░░░███████║░░░██║░░░██║██║░░██║██╔██╗██║██║░░██║██║░░██║█████╗░░╚█████╗░"
echo -e "██║░░╚██╗░░░██╔╝░╚════╝██╔══╝░░██║░░░░░██╔══██║░░░██║░░░██║██║░░██║██║╚████║██║░░██║██║░░██║██╔══╝░░░╚═══██╗"
echo -e "╚██████╔╝░░██╔╝░░░░░░░░███████╗███████╗██║░░██║░░░██║░░░██║╚█████╔╝██║░╚███║╚█████╔╝██████╔╝███████╗██████╔╝"
echo -e "░╚═════╝░░░╚═╝░░░░░░░░░╚══════╝╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝░╚════╝░╚═════╝░╚══════╝╚═════╝░"
echo -e "\033[1;34m"
echo
echo -e "\033[1;32mG7 community: \033[5;31mhttps://t.me/g7monitor\033[0m"
echo -e "\033[1;32mElatioNodes community: \033[5;31mhttps://discord.gg/KvQGajqDUW\033[0m"
echo -e "\033[0m"

# Проверка и установка Docker
if ! command -v docker &> /dev/null; then
    echo "Docker не установлен. Установка Docker..."
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo "Docker успешно установлен."
else
    echo "Docker уже установлен. Пропускаем установку."
fi

# Обновление пакетов
sudo apt update && sudo apt upgrade -y

# Установка необходимых пакетов
sudo apt install screen curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar net-tools clang git ncdu pkg-config libssl-dev -y

# Установка NodeJS & NPM (версии 20.16.1 минимум)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Установка Typesense (API KEY - 'xyz' по умолчанию, вы можете изменить его)
export TYPESENSE_API_KEY=xyz
    
sudo mkdir "$(pwd)"/typesense-data

sudo docker run -d -p 8108:8108 \
            -v "$(pwd)"/typesense-data:/data typesense/typesense:26.0 \
            --data-dir /data \
            --api-key=$TYPESENSE_API_KEY \
            --enable-cors

# Клонирование и запуск Ocean Node
sudo git clone https://github.com/oceanprotocol/ocean-node.git && cd ocean-node

# Сборка образа (может занять до 15 минут в зависимости от оборудования)
sudo docker build -t ocean-node:mybuild .

# Запрос приватного ключа у пользователя
read -p "Введите ваш приватный ключ (в формате 0x...): " PRIVATE_KEY

# Запрос IP-адреса у пользователя
read -p "Введите IP-адрес вашего сервера: " SERVER_IP

# Запрос адреса кошелька 
read -p "Введите адрес кошелька, с которого будете заходить в админ-панель: " ADMIN_ADDRESS

# Создание .env файла
cat <<EOF > .env
# Environmental Variables

#check env.md file for examples and descriptions on each variable

#----------------- REQUIRED --------------------------
#This is the only required/mandatory variable
#Node will simply not run without this variable
#All the other variables can remain blank (because they have defaults) or simply commented
PRIVATE_KEY=$PRIVATE_KEY
#-----------------------------------------------------

## core
INDEXER_NETWORKS=["23295", "11155420"]
RPCS={"23295":{"rpc":"https://testnet.sapphire.oasis.io","chainId":23295,"network":"oasis_saphire_testnet","chunkSize":100},"11155420":{"rpc":"https://sepolia.optimism.io","chainId":11155420,"network":"optimism-sepolia","chunkSize":100}}
DB_URL=http://localhost:8108/?apiKey=xyz
IPFS_GATEWAY=https://ipfs.io/
ARWEAVE_GATEWAY=https://arweave.net/
LOAD_INITIAL_DDOS=
FEE_TOKENS=
FEE_AMOUNT=
ADDRESS_FILE=
NODE_ENV=
AUTHORIZED_DECRYPTERS=
OPERATOR_SERVICE_URL=
INTERFACES=
ALLOWED_VALIDATORS=
INDEXER_INTERVAL=
ALLOWED_ADMINS=["$ADMIN_ADDRESS"]
DASHBOARD=true
RATE_DENY_LIST=
MAX_REQ_PER_SECOND=
MAX_CHECKSUM_LENGTH=
LOG_LEVEL=
HTTP_API_PORT=

## p2p

P2P_ENABLE_IPV4=
P2P_ENABLE_IPV6=
P2P_ipV4BindAddress=
P2P_ipV4BindTcpPort=
P2P_ipV4BindWsPort=
P2P_ipV6BindAddress=
P2P_ipV6BindTcpPort=
P2P_ipV6BindWsPort=
P2P_ANNOUNCE_ADDRESSES=["/ip4/$SERVER_IP/tcp/8000"]
P2P_ANNOUNCE_PRIVATE=
P2P_pubsubPeerDiscoveryInterval=
P2P_dhtMaxInboundStreams=
P2P_dhtMaxOutboundStreams=
P2P_mDNSInterval=
P2P_connectionsMaxParallelDials=
P2P_connectionsDialTimeout=
P2P_ENABLE_UPNP=
P2P_ENABLE_AUTONAT=
P2P_ENABLE_CIRCUIT_RELAY_SERVER=
P2P_ENABLE_CIRCUIT_RELAY_CLIENT=
P2P_BOOTSTRAP_NODES=
P2P_FILTER_ANNOUNCED_ADDRESSES=
EOF

echo ".env файл создан и заполнен."

# Запуск ноды
sudo docker run --env-file .env -e 'getP2pNetworkStats' -p 8000:8000 ocean-node:mybuild

echo "Пожалуйста, подождите 5-10 минут, пока нода запускается. Проверьте статус на панели управления Ocean Node."
