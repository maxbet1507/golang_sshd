FROM golang:stretch

ARG SSH_USER=user
ARG SSH_USER_GROUP=user
ARG SSH_USER_ID=1000
ARG SSH_USER_GROUP_ID=1000

RUN apt-get update && apt-get install -y openssh-server sudo vim git bash-completion && \
    mkdir -p /var/run/sshd

RUN sed 's/#PasswordAuthentication yes/PasswordAuthentication no/' -i /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    sed 's/^%sudo.*/%sudo\tALL=NOPASSWD: ALL/' -i /etc/sudoers

ENV NOTVISIBLE "in users profile"
RUN { \
    echo "export VISIBLE=now"; \
    echo "export GOPATH=/go"; \
    echo "export PATH=/go/bin:/usr/local/go/bin:"\$"{PATH}"; \
    } | tee -a /etc/profile

RUN groupadd -g ${SSH_USER_GROUP_ID} ${SSH_USER_GROUP} && \
    useradd -u ${SSH_USER_ID} -g ${SSH_USER_GROUP_ID} -G sudo -s /bin/bash -m ${SSH_USER}

ENV EDITOR=vim
EXPOSE 22
ENTRYPOINT ["sudo", "/usr/sbin/sshd", "-D"]

USER ${SSH_USER}
RUN mkdir ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && \
    touch ${HOME}/.ssh/authorized_keys && chmod 600 ${HOME}/.ssh/authorized_keys
