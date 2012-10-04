#!/bin/bash

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# INTERNAL PARAMETERS
PIWIK_URL="$piwik_url"
PIWIK_USER_NAME="$piwik_username"
PIWIK_PASSWORD="$piwik_password"
PIWIK_EMAIL="$email"
PIWIK_HOST="$piwik_host"
PIWIK_DATABASE="$piwik_database"
TABLES_PREFIX="$tables_prefix"
MYSQL_USERNAME="$MySQL_username"
MYSQL_PASSWORD="$MySQL_password"
DOCUMENT_ROOT="$document_root"
PIWIK_IP="$piwik_selfip"
SITE_NAME="$site_name"

echo "INSTALLING PRE-REQUISTES"
if [ -f /etc/redhat-release ] ; then
   echo "RHEL / CENTOS OS"
   yum --nogpgcheck -y install unzip
fi

cd $DOCUMENT_ROOT
echo "DOWNLOAD PIWIK "
wget $PIWIK_URL
check_error "ERROR WHILE DOWNLOADING PIWIK ZIP FILE"
echo "EXTARCT PIWIK"
unzip latest.zip
check_error "ERROR WHILE EXTRACTING PIWIK "

chmod -R 0777 $DOCUMENT_ROOT/piwik
chmod -R 0777 $DOCUMENT_ROOT/piwik/tmp