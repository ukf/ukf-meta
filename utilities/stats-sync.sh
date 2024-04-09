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

# Logs from websites
rsync -at --exclude modsec* stats@www-ne-01:/var/log/httpd/* $logslocation/www/www-ne-01/
rsync -at --exclude modsec* stats@www-we-01:/var/log/httpd/* $logslocation/www/www-we-01/

# Logs from Test IdP
rsync -at --exclude modsec* stats@test-idp:/var/log/httpd/* $logslocation/test-idp/
rsync -at stats@test-idp:/opt/shibboleth-idp/logs/idp-audit* $logslocation/test-idp/

# Logs from Test SP inaccessible once the Test SP migrated to 2024 infrastructure
#
# The Test SP has a cronjob to remove logs with PII > 30 days old, we replicate that in this script
find $logslocation/test-sp/ -type f -mtime +90 -delete

# Exit happily
exit 0
