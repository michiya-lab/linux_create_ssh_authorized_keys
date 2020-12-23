#!/bin/bash

function load_userlist()
{
userlist=()
while read line
do
    userlist+=($line)
done < $1
}

function create_authorized_key()
{
load_userlist "userlist.txt"
for user in ${userlist[@]};
do
    uname=$(cut -d: -f 1 <<<${user})
    pass=$(cut -d: -f 2 <<<${user})
    if ! getent passwd $uname > /dev/null 2>&1;
    then
        echo "*** FATAL ERROR"
        echo " ${uname} is not exist"
        exit 1
    fi
    userinfo=`getent passwd $uname`
    userhome=$(cut -d: -f 6 <<< ${userinfo})
    dir=authorized_keys/${uname}
    mkdir -p $dir
    fname=${uname} 
    if [ ! -f ${dir}/${uname} ];
    then
        ssh-keygen -t ed25519 -N ${pass} -f ${dir}/${fname} -C ""
        cat ${dir}/${fname}.pub > ${dir}/authorized_keys
    else
        echo "authorized_keys for ${uname} is alreade created : skipped"
    fi
done
}

function distribute_keys()
{
load_userlist "userlist.txt"
for user in ${userlist[@]};
do
    uname=$(cut -d: -f 1 <<<${user})
    pass=$(cut -d: -f 2 <<<${user})
    if ! getent passwd $uname > /dev/null 2>&1;
    then
        echo "*** FATAL ERROR"
        echo " ${uname} is not exist"
        exit 1
    fi
    userinfo=`getent passwd $uname`
    usergroup=$(cut -d: -f 4 <<< ${userinfo})
    userhome=$(cut -d: -f 6 <<< ${userinfo})
    dir=authorized_keys/${uname}
    if [ ! -f ${dir}/authorized_keys ];
    then
        echo "*** FATAL ERROR"
        echo " ${dir}/authorized_keys is not found"
        exit 1
    fi
    mkdir -p ${userhome}/.ssh
    cp ${dir}/authorized_keys ${userhome}/.ssh/authorized_keys
    chown ${uname}:${usergroup} ${userhome}/.ssh/authorized_keys
done
}

function clean_keys()
{
rm -rf authorized_keys/*
}
