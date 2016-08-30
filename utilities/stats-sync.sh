#!/bin/bash

# This script will sync the logfiles from all of the backend servers into a central location on repo
#

# Set some common options
logslocation="/var/stats"


# Logs from API

# Logs from MD servers
rsync -at --exclude modsec* stats@md1:/var/log/httpd/* $logslocation/md/md1/
rsync -at --exclude modsec* stats@md2:/var/log/httpd/* $logslocation/md/md2/
rsync -at --exclude modsec* stats@md3:/var/log/httpd/* $logslocation/md/md3/

# Logs from CDS servers
rsync -at --exclude modsec* stats@shib-cds1:/var/log/httpd/* $logslocation/cds/shib-cds1/
rsync -at --exclude modsec* stats@shib-cds2:/var/log/httpd/* $logslocation/cds/shib-cds2/
rsync -at --exclude modsec* stats@shib-cds3:/var/log/httpd/* $logslocation/cds/shib-cds3/

# Logs from websites
rsync -at --exclude modsec* stats@web1:/var/log/httpd/* $logslocation/www/web1/
rsync -at --exclude modsec* stats@web2:/var/log/httpd/* $logslocation/www/web2/

# Logs from Wugen
rsync -at --exclude modsec* stats@wugen:/var/log/httpd/* $logslocation/wugen/
rsync -at stats@wugen:/opt/wugen/logs/urlgenerator-* $logslocation/wugen/

# Logs from Test IdP
rsync -at --exclude modsec* stats@test-idp:/var/log/httpd/* $logslocation/test-idp/
rsync -at stats@test-idp:/opt/shibboleth-idp/logs/idp-audit* $logslocation/test-idp/

# Logs from Test SP
rsync -at --exclude modsec* stats@test-sp:/var/log/httpd/* $logslocation/test-sp/
rsync -at stats@test-sp:/var/log/shibboleth/shibd* $logslocation/test-sp/

# Exit happily
exit 0