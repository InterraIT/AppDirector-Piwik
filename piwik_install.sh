#!/bin/bash

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e
export http_proxy=http://proxy.vmware.com:3128

# FUNTION TO CHECK ERROR
function check_error()
{
   if [ ! "$?" = "0" ]; then
      error_exit "$1";
   fi
}

# FUNCTION TO DISPLAY ERROR AND EXIT
function error_exit()
{
   echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
   exit 1
}

# FUNCTION TO VALIDATE NAME STRING
function valid_string()
{
    local  data=$1
    if [[ $data =~ ^[A-Za-z]{1,}[A-Za-z0-9_-]{1,}$ ]]; then
       return 0;
    else
       return 1;
    fi
}

# FUNCTION TO VALIDATE PASSWORD
function valid_password()
{
    local  data=$1
    length=${#data}
    if [ $length -le 6 ]; then
        check_error "PASSWORD MUST BE OF AT LEAST 6 CHARACTERS"
    else
        if [[ $data =~ ^[A-Za-z]{1,}[0-9_@$%^+=]{0,}[A-Za-z0-9]{0,}$ ]]; then
           return 0;
        else
           return 1;
        fi
    fi
}

# FUNCTION TO VALIDATE IP ADDRESS
function valid_ip()
{
    local  ip=$1
    local  stat=1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

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

# PARAMETER VALIDATION
echo "VALIDATING PARAMETERS..."
if [ "x${PIWIK_URL}" = "x" ]; then
    error_exit "PIWIK_URL NOT SET."
fi

if [ "x${PIWIK_USER_NAME}" = "x" ]; then
    error_exit "PIWIK_USER_NAME NOT SET."
else
   if ! valid_string ${PIWIK_USER_NAME}; then
      error_exit "INVALID PARAMETER PIWIK_USER_NAME=$PIWIK_USER_NAME.Must BE A STRING"
   fi
fi

if [ "x${PIWIK_PASSWORD}" = "x" ]; then
    error_exit "PIWIK_PASSWORD NOT SET."
else
   if ! valid_password ${PIWIK_PASSWORD}; then
      error_exit "INVALID PARAMETER PIWIK_PASSWORD=$PIWIK_PASSWORD."
   fi
fi

if [ "x${PIWIK_EMAIL}" = "x" ]; then
    error_exit "PIWIK_EMAIL NOT SET."
fi

if [ "x${PIWIK_HOST}" = "x" ]; then
    error_exit "PIWIK_HOST NOT SET."
fi

if [ "x${PIWIK_DATABASE}" = "x" ]; then
    error_exit "PIWIK_DATABASE NOT SET."
fi

if [ "x${TABLES_PREFIX}" = "x" ]; then
    error_exit "TABLES_PREFIX NOT SET."
fi

if [ "x${MYSQL_USERNAME}" = "x" ]; then
    error_exit "MYSQL_USERNAME NOT SET."
else
   if ! valid_string ${MYSQL_USERNAME}; then
      error_exit "INVALID PARAMETER MYSQL_USERNAME=$MYSQL_USERNAME.Must BE A STRING"
   fi
fi

if [ "x${MYSQL_PASSWORD}" = "x" ]; then
    error_exit "MYSQL_PASSWORD NOT SET."
else
   if ! valid_password ${MYSQL_PASSWORD}; then
      error_exit "INVALID PARAMETER MYSQL_PASSWORD=$MYSQL_PASSWORD."
   fi
fi

if [ "x${DOCUMENT_ROOT}" = "x" ]; then
    error_exit "DOCUMENT_ROOT NOT SET."
fi

if [ "x${PIWIK_IP}" = "x" ]; then
    error_exit "PIWIK_IP NOT SET."
else
   if ! valid_ip ${PIWIK_IP}; then
      error_exit "INVALID PARAMETER PIWIK_IP=$PIWIK_IP."
   fi
fi

if [ "x${SITE_NAME}" = "x" ]; then
    error_exit "SITE_NAME NOT SET."
fi

echo "PARAMTER VALIDATION -- DONE"

echo "INSTALLING PRE-REQUISTES"
if [ -f /etc/redhat-release ] ; then
   echo "RHEL / CENTOS OS"
   yum --nogpgcheck -y install unzip
elif [ -f /etc/debian_version ] ; then
   echo "Ubuntu OS"   
   apt-get -f -y install unzip --fix-missing
elif [ -f /etc/SuSE-release ] ; then
   echo "SUSE OS"
   zypper --non-interactive --no-gpg-checks install unzip
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