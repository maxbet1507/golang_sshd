FROM golang:stretch

ARG SSH_USER=user
ARG SSH_USER_GROUP=user
ARG SSH_USER_ID=1000
ARG SSH_USER_GROUP_ID=1000

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y --no-install-recommends openssh-server sudo vim git git-flow bash-completion && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    \
    sed 's/#PasswordAuthentication yes/PasswordAuthentication no/' -i /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    sed 's/^%sudo.*/%sudo\tALL=NOPASSWD: ALL/' -i /etc/sudoers && \
    { \
    echo "export VISIBLE=now"; \
    echo "export GOPATH=/go"; \
    echo "export PATH=/go/bin:/usr/local/go/bin:"\$"{PATH}"; \
    } | tee -a /etc/profile && \
    \
    groupadd -g ${SSH_USER_GROUP_ID} ${SSH_USER_GROUP} && \
    useradd -u ${SSH_USER_ID} -g ${SSH_USER_GROUP_ID} -G sudo -s /bin/bash -m ${SSH_USER} && \
    \
    sudo -u ${SSH_USER} /bin/bash -c 'mkdir '\$'{HOME}/.ssh' && \
    sudo -u ${SSH_USER} /bin/bash -c 'chmod 700 '\$'{HOME}/.ssh' && \
    sudo -u ${SSH_USER} /bin/bash -c 'touch '\$'{HOME}/.ssh/authorized_keys' && \
    sudo -u ${SSH_USER} /bin/bash -c 'chmod 600 '\$'{HOME}/.ssh/authorized_keys' && \
    sudo -u ${SSH_USER} /bin/bash -c 'mkdir '\$'{HOME}/.vscode-server'

ENV NOTVISIBLE "in users profile"
ENV EDITOR=vim
EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd", "-D"]

RUN go get -x -d github.com/stamblerre/gocode && \
    go build -o gocode-gomod github.com/stamblerre/gocode && \
    mv gocode-gomod ${GOPATH}/bin/ && \
    \
    go get -u -v \
    github.com/mdempsky/gocode \
    github.com/uudashr/gopkgs/cmd/gopkgs \
    github.com/ramya-rao-a/go-outline \
    github.com/acroca/go-symbols \
    github.com/godoctor/godoctor \
    golang.org/x/tools/cmd/guru \
    golang.org/x/tools/cmd/gorename \
    github.com/rogpeppe/godef \
    github.com/zmb3/gogetdoc \
    github.com/haya14busa/goplay/cmd/goplay \
    github.com/sqs/goreturns \
    github.com/josharian/impl \
    github.com/davidrjenni/reftools/cmd/fillstruct \
    github.com/fatih/gomodifytags \
    github.com/cweill/gotests/... \
    golang.org/x/tools/cmd/goimports \
    golang.org/x/lint/golint \
    golang.org/x/tools/cmd/gopls \
    github.com/alecthomas/gometalinter \
    honnef.co/go/tools/... \
    github.com/golangci/golangci-lint/cmd/golangci-lint \
    github.com/mgechev/revive \
    github.com/derekparker/delve/cmd/dlv && \
    \
    rm -rf ${GOPATH}/src/* ${GOPATH}/pkg/* && \
    rm -rf /root/.cache && \
    strip ${GOPATH}/bin/* 
