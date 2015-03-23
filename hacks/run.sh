#!/bin/bash

export BASEDIR="/opt/dolly"
export USER_GROUP="dolly:dolly"

: ${REGISTRY_URL:=https://index.docker.io/v1/}

make_bare_repo()
{
    APP=$1

    if [ ! -d "${BASEDIR}/remotes/${APP}" ]; then
        cd ${BASEDIR}/remotes
        mkdir ${APP}.git && cd $APP.git && git init --bare && cd ..

        cp /scripts/post-receive ${APP}.git/hooks/post-receive
        chmod +x ${APP}.git/hooks/post-receive
    fi
}

set_authorized_keys()
{
    echo ${SSH_KEY} >> ${BASEDIR}/.ssh/authorized_keys
    chmod 600 ${BASEDIR}/.ssh/authorized_keys
}

login_dolly_user()
{
    if [[ ! -z ${REGISTRY_USER} ]] && [[ ! -z ${REGISTRY_PASSWORD} ]] && [[ ! -z ${EMAIL} ]]; then
        su dolly -c "docker login -u ${REGISTRY_USER} -p ${REGISTRY_PASSWORD} -e ${EMAIL} ${REGISTRY_URL}"
    else
        echo "No Credentials supplied. Can not push containers to remote"
    fi
}


while (( "$#" )); do 
    make_bare_repo $1
    shift 1
done

set_authorized_keys
chown -R ${USER_GROUP} ${BASEDIR}

rm /etc/ssh/ssh_host_*
/usr/sbin/dpkg-reconfigure openssh-server

wrapdocker
login_dolly_user

# For now....
/usr/sbin/sshd -D
