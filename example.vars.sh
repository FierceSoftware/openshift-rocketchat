#!/usr/bin/env bash

OCP_HOST=""

OCP_AUTH_TYPE="userpass"

OCP_USERNAME=""
OCP_PASSWORD=""
OCP_TOKEN=""
ROCKET_CHAT_ROUTE=""
OCP_CREATE_PROJECT="true"
OCP_PROJECT_NAME="chatops-rocketchat"
RH_RHN=""
RH_EMAIL=""
RH_PASSWORD=""
ADMIN_USERNAME="rcadmin"
ADMIN_PASS="sup3rs3cr3t"
ADMIN_EMAIL="you@example.com"

INTERACTIVE="false"

if [ $OCP_AUTH_TYPE == "userpass" ]; then
    OCP_AUTH="-u $OCP_USERNAME -p $OCP_PASSWORD"
fi
if [ $OCP_AUTH_TYPE == "token" ]; then
    OCP_AUTH="--token=$OCP_TOKEN"
fi