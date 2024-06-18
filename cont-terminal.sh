#!/usr/bin/env bash
FOUND=$(docker exec -ti www grep $UID /etc/passwd)
if [ -z "$FOUND" ]
then
  docker exec -it www groupadd -g $UID $USER
  docker exec -it www useradd -u $UID -g $UID -d $HOME -s /bin/bash $USER
fi
exec docker exec -ti www su -l $USER
