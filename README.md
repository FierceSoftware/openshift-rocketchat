# RocketChat on OpenShift

This repository contains templates and tooling for taking Rocket Chat to Production on OpenShift Container Platform.

## Prerequisites

Mongo is deployed as a StatefulSet and requires access to at least 3 PersistentVolumes for its backing storage.

##  Deployment - Automatic

There's a simple deployment script that can either prompt a user for variables or take them set in the Bash script.  As long as you have an OpenShift Cluster and Red Hat RHN then you can simply run:

```
$ ./deployer.sh
```

And answer the prompts to deploy the full Rocket.Chat on OCP stack.

##  Deployment - Manual

Create a new project

```
oc new-project rocketchat
```

Deploy the MongoDB StatefulSet using the included template

```
oc process -f mongodb-statefulset-replication.yaml | oc apply -f-
```

The RocketChat image is stored in the [Red Hat Container Catalog](https://registry.access.redhat.com) (RHCC). A valid Red Hat subscription is required in order to retrieve the image.

Create a new secret called _rhcc_ containing your credentials to the Red Hat Customer Portal - you must do this even if you have a subscribed OCP cluster that can already pull from the Red Hat Container Registry...

```
oc create secret docker-registry rhcc \
    --docker-username=<username> \
    --docker-password=<password> \
    --docker-email=<email> \
    --docker-server=registry.connect.redhat.com
```

Add the secret to the default service account

```
oc secrets add serviceaccount/default secrets/rhcc --for=pull
```

Deploy the RocketChat template. Be sure to include the hostname of the application as a template parameter. 

```
oc process -f rocketchat.yaml -p HOSTNAME_HTTP=chat-dev.apps.example.com -p ACCOUNT_DNS_DOMAIN_CHECK=false | oc apply -f-
```

Once deployed, the application will be available at the provided hostname.


## Deploying Rocket.Chat for ChatOps

Run the initial Rocket.Chat setup & admin account creation, then create a room for your #workshops-team (or whatever).  Configure LDAP with the following (if using RH IDM/FreeIPA):

- LDAP General - Enable: True
- LDAP General - Login Fallback: True
- LDAP General - Find user after login: True
- LDAP General - Host: idm.example.com
- LDAP General - Port: 636
- LDAP General - Reconnect: True
- LDAP General - Encryption: SSL/LDAPS
- LDAP General - Regect Unauthorized: False
- LDAP General - Base DN: cn=accounts,dc=example,dc=com
- LDAP Authentication - Enable: True
- LDAP Authentication - User DN: cn=Directory Manager
- LDAP Authentication - Password: duh_fill_this_one_out_yourself
- LDAP Sync/Import - Username Field: uid
- LDAP Sync/Import - Unique Identifier Field: uid
- LDAP User Search - Filter: (objectclass=*)
- LDAP User Search - Scope: sub
- LDAP User Search - Search Field: uid

You'll also probably want to create a user (in LDAP) for Jenkins to interact with Rocketchat, if using this as part of a ChatOps implementation with a build pipeline.  Something like "rc-jenkins" maybe, I dunno, call it whatever you'd like.
