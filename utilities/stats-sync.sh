#!/bin/bash

# This script will sync the logfiles from all of the backend servers into a central location on repo
#

# Set some common options
logslocation="/var/stats"


# Logs from API

# Logs from MD servers
rsync -at --exclude modsec* stats@md-ne-01:/var/log/httpd/* $logslocation/md/md-ne-01/
rsync -at --exclude modsec* stats@md-ne-02:/var/log/httpd/* $logslocation/md/md-ne-02/
rsync -at --exclude modsec* stats@md-we-01:/var/log/httpd/* $logslocation/md/md-we-01/
rsync -at --exclude modsec* stats@md-we-02:/var/log/httpd/* $logslocation/md/md-we-02/

# Logs from CDS servers
rsync -at --exclude modsec* stats@shibcds-ne-01:/var/log/httpd/* $logslocation/cds/shibcds-ne-01/
rsync -at --exclude modsec* stats@shibcds-ne-02:/var/log/httpd/* $logslocation/cds/shibcds-ne-02/
rsync -at --exclude modsec* stats@shibcds-we-01:/var/log/httpd/* $logslocation/cds/shibcds-we-01/
rsync -at --exclude modsec* stats@shibcds-we-02:/var/log/httpd/* $logslocation/cds/shibcds-we-02/

# Logs from websites
rsync -at --exclude modsec* stats@www-ne-01:/var/log/httpd/* $logslocation/www/www-ne-01/
rsync -at --exclude modsec* stats@www-we-01:/var/log/httpd/* $logslocation/www/www-we-01/

# Logs from Wugen
rsync -at stats@dockerpub-ne-01:./wugen/wayfless-* $logslocation/wugen/

# Logs from Test IdP
rsync -at --exclude modsec* stats@test-idp:/var/log/httpd/* $logslocation/test-idp/
rsync -at stats@test-idp:/opt/shibboleth-idp/logs/idp-audit* $logslocation/test-idp/

# Logs from Test SP
#
# The Test SP has a cronjob to remove logs with PII > 30 days old, --delete keeps repo in sync
#
rsync --delete -at --exclude modsec* stats@test-sp:/var/log/httpd/* $logslocation/test-sp/
rsync --delete -at stats@test-sp:/var/log/shibboleth/shibd* $logslocation/test-sp/
rsync --delete -at stats@test-sp:/var/log/shibboleth/transaction* $logslocation/test-sp/

# Exit happily
exit 0
