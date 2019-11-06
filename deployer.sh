#!/bin/bash

## Default variables to use
export INTERACTIVE=${INTERACTIVE:="true"}
export OCP_HOST=${OCP_HOST:=""}
## userpass or token
export OCP_AUTH_TYPE=${OCP_AUTH_TYPE:="userpass"}
export OCP_AUTH=${OCP_AUTH:=""}
export OCP_USERNAME=${OCP_USERNAME:=""}
export OCP_PASSWORD=${OCP_PASSWORD:=""}
export OCP_TOKEN=${OCP_TOKEN:=""}
export ROCKET_CHAT_ROUTE=${ROCKET_CHAT_ROUTE:="rocketchat.example.com"}
export OCP_CREATE_PROJECT=${OCP_CREATE_PROJECT:="true"}
export OCP_PROJECT_NAME=${OCP_PROJECT_NAME:="chatops-rocketchat"}
export RH_RHN=${RH_RHN:=""}
export RH_EMAIL=${RH_EMAIL:=""}
export RH_PASSWORD=${RH_PASSWORD:=""}
export ADMIN_USERNAME=${ADMIN_USERNAME:="rcadmin"}
export ADMIN_PASS=${ADMIN_PASS:="sup3rs3cr3t"}
export ADMIN_EMAIL=${ADMIN_EMAIL:="you@example.com"}

## Make the script interactive to set the variables
if [ "$INTERACTIVE" = "true" ]; then
	read -rp "OpenShift Cluster Host http(s)://ocp.example.com: ($OCP_HOST): " choice;
	if [ "$choice" != "" ] ; then
		export OCP_HOST="$choice";
	fi

	read -rp "OpenShift Auth Type [userpass or token]: ($OCP_AUTH_TYPE): " choice;
	if [ "$choice" != "" ] ; then
		export OCP_AUTH_TYPE="$choice";
	fi

    if [ $OCP_AUTH_TYPE == "userpass" ]; true

        read -rp "OpenShift Username: ($OCP_USERNAME): " choice;
        if [ "$choice" != "" ] ; then
            export OCP_USERNAME="$choice";
        fi

        read -rsp "OpenShift Password: " choice;
        if [ "$choice" != "" ] ; then
            export OCP_PASSWORD="$choice";
        fi
        echo -e ""

        OCP_AUTH="-u $OCP_USERNAME -p $OCP_PASSWORD"

    fi

    if [ $OCP_AUTH_TYPE == "token" ]; true

        read -rp "OpenShift Token: ($OCP_TOKEN): " choice;
        if [ "$choice" != "" ] ; then
            export OCP_TOKEN="$choice";
        fi

        OCP_AUTH="--token=$OCP_TOKEN"

    fi

	read -rp "Rocket.Chat Route: ($ROCKET_CHAT_ROUTE): " choice;
	if [ "$choice" != "" ] ; then
		export ROCKET_CHAT_ROUTE="$choice";
	fi

	read -rp "Rocket.Chat Admin Username: ($ADMIN_USERNAME): " choice;
	if [ "$choice" != "" ] ; then
		export ADMIN_USERNAME="$choice";
	fi

	read -rsp "Rocket.Chat Admin Password: ($ADMIN_PASS): " choice;
	if [ "$choice" != "" ] ; then
		export ADMIN_PASS="$choice";
	fi
	echo -e ""

	read -rp "Rocket.Chat Admin Email: ($ADMIN_EMAIL): " choice;
	if [ "$choice" != "" ] ; then
		export ADMIN_EMAIL="$choice";
	fi

	read -rp "Create OpenShift Project? (true/false) ($OCP_CREATE_PROJECT): " choice;
	if [ "$choice" != "" ] ; then
		export OCP_CREATE_PROJECT="$choice";
	fi

	read -rp "OpenShift Project Name ($OCP_PROJECT_NAME): " choice;
	if [ "$choice" != "" ] ; then
		export OCP_PROJECT_NAME="$choice";
	fi

	read -rp "Red Hat RHN ($RH_RHN): " choice;
	if [ "$choice" != "" ] ; then
		export RH_RHN="$choice";
	fi

	read -rp "Red Hat RHN Email ($RH_EMAIL): " choice;
	if [ "$choice" != "" ] ; then
		export RH_EMAIL="$choice";
	fi

	read -rsp "Red Hat RHN Password ($RH_PASSWORD): " choice;
	if [ "$choice" != "" ] ; then
		export RH_PASSWORD="$choice";
	fi
	echo -e ""
fi

## Log in
echo "Log in to OpenShift..."
oc login $OCP_HOST $OCP_AUTH

## Create/Use Project
echo "Create/Set Project..."
if [ "$OCP_CREATE_PROJECT" = "true" ]; then
    oc new-project $OCP_PROJECT_NAME --description="ChatOps with Rocket.Chat" --display-name="ChatOps - Rocket.Chat"
fi
if [ "$OCP_CREATE_PROJECT" = "false" ]; then
    oc project $OCP_PROJECT_NAME
fi

## Deploy MongoDB
echo "Deploy MongoDB..."
oc process -f mongodb-statefulset-replication.yaml | oc apply -f-
echo "Sleep for 10 seconds..."
sleep 10

## Create Image Pull Secret
echo "Create Image Pull Secret..."
oc create secret docker-registry rhcc --docker-username=$RH_RHN --docker-password=$RH_PASSWORD --docker-email=$RH_EMAIL --docker-server=registry.connect.redhat.com

## Add secret to default SA
echo "Add Secret to Service Account..."
oc secrets add serviceaccount/default secrets/rhcc --for=pull

## Deploy Rocket.Chat
oc process -f rocketchat.yaml -p HOSTNAME_HTTP="$ROCKET_CHAT_ROUTE" -p ACCOUNT_DNS_DOMAIN_CHECK=false -p ADMIN_USERNAME="$ADMIN_USERNAME" -p ADMIN_PASS="$ADMIN_PASS" -p ADMIN_EMAIL="$ADMIN_EMAIL" | oc apply -f-