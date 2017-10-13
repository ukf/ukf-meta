#!/bin/bash
# This script processes a Salesforce report "UKfed-contacts-export" which lists all contacts with
# UK Federation Contact Roles and their corresponding Jisc Organisation ID (ukforg) and Organisation Name
#
# The current report can be found here https://eu3.salesforce.com/00Ow0000007MXhK, it needs to be exported as a CSV file
# which ends up as 'reportnnnnnnnnnnnnn.csv'
#
# The input to the script is the above CSV file.
#
# The output of the script is as follows;
#
# * A copy of the Salesforce report in $CSVDEST
# * A list of Management Contact email addresses in $MGMTDEST
# * A list of all contact email addresses in $CONTACTDEST
#
# To use this script please follow the process here;
#
# https://repo.infr.ukfederation.org.uk/ukf/ukf-systems/wikis/HOW-to-process-UKfed-contacts-export-report
#
# Author: Jon Agland <jon.agland@jisc.ac.uk>
#

SFREPORTNAME="UKfed-contacts-export"
CSVDEST=../../ukf-data/contacts/sf-contacts.csv
CONTACTDEST=../../ukf-data/contacts/sf-contacts.txt
MGMTDEST=../../ukf-data/contacts/sf-contacts-mc.txt

if [ -z "$1" ]; then
     echo "ERROR: No file name supplied"
     exit 1
fi

if [ ! -f "$1" ]; then
     echo "ERROR: file $1 does not exist"
     exit 1
fi

if ! grep -q \"$SFREPORTNAME\" $1; then
     echo "ERROR: this doesn't appear to be the output of $SFREPORTNAME"
     exit 2
fi

cat $1 | awk -F\, '{ print $1 }' | grep @ | sed -e 's/\"//g' | sort -u  > $CONTACTDEST
grep "\,\"UK Federation Management Contact\"" $1 | awk -F\, '{ print $1 }' | grep @ | sed -e 's/\"//g' | sort -u  > $MGMTDEST

cp $1 $CSVDEST

