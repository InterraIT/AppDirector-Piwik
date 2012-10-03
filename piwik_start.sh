#!/bin/bash

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e

if [ -f /etc/redhat-release ] ; then
	/etc/init.d/httpd restart
	
elif [ -f /etc/debian_version ] ; then
	/etc/init.d/apache2 restart

elif [ -f /etc/SuSE-release ] ; then
	/etc/init.d/apache2 restart
fi