#!/bin/bash

# This script will calculate stats 
#
# Expects the following to be provided as arguments:
# * Time period - day/month/year
# * Time - YYYY-MM-DD/YYYY-MM/YYYY

# Assumes you've just run stats-sync.sh to make sure the source
# log files are up to date




# =====
# = Preamble
# =====


#
# Set some common options
#
logslocation="/var/stats"
usageerrormsg="usage: generate-stats.sh <time period to run stats on (day/month/year)> [<date (YYYY-MM-DD/YYYY-MM/YYYY)>]"


#
# Fail if required input isn't provided.
#
if [[ -z $1 ]]; then
    echo $usageerrormsg
    exit 1
fi


#
# Get the input
#
timeperiod=$1
date=$2


#
# Fail if time period provided isn't day/month/year
#
if ! { [[ "$timeperiod" == "day" ]] || [[ "$timeperiod" == "month" ]] || [[ "$timeperiod" == "year" ]]; }; then
    echo $usageerrormsg
    exit 1
fi

#
# If no date provided, the use the following:
# * Day - Previous day
# * Month - Previous month
# * Year - Previous year
#
if [[ -z $2 ]]; then
    if [[ "$timeperiod" == "day" ]]; then
        date=$(date -d "yesterday 12:00" '+%Y-%m-%d')
    elif [[ "$timeperiod" == "month" ]]; then
        date=$(date -d "last month"  '+%Y-%m')
    else
        date=$(date -d "last year"  '+%Y')
    fi
fi

#
# Fail if date format provided doesn't match time period
#
if [[ "$timeperiod" == "day" ]]; then
    if [[ ! $date =~ ^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}$ ]]; then
        echo "Wrong type of input date for $1, must be YYYY-MM-DD"
        exit 1
    fi
elif [[ "$timeperiod" == "month" ]]; then
    if [[ ! $date =~ ^[[:digit:]]{4}-[[:digit:]]{2}$ ]]; then
        echo "Wrong type of input date for $1, must be YYYY-MM"
        exit 1
    fi
elif [[ "$timeperiod" == "year" ]]; then
    if [[ ! $date =~ ^[[:digit:]]{4}$ ]]; then
        echo "Wrong type of input date for $1, must be YYYY"
        exit 1
    fi
else
    echo $usageerrormsg
    exit 1
fi

#
# Fail if date provided isn't valid for time period
#
if [[ "$timeperiod" == "day" ]]; then
    if [[ ! $(date -d ${date} 2> /dev/null) ]]; then
        echo "YYYY-MM-DD provided, but not a valid date."
        exit 1
    fi
elif [[ "$timeperiod" == "month" ]]; then
    if [[ ! $(date -d ${date}-01 2> /dev/null) ]]; then
        echo "YYYY-MM provided, but not a valid date."
        exit 1
    fi
elif [[ "$timeperiod" == "year" ]]; then
    if [[ ! $(date -d ${date}-01-01 2> /dev/null) ]]; then
        echo "YYYY provided, but not a valid date."
        exit 1
    fi
else
    echo $usageerrormsg
    exit 1
fi




# =====
# = Calculate the correct date things to search for in the log files
# =====


if [[ "$timeperiod" == "day" ]]; then
    #
    # Daily stuff
    #
    apachesearchterm="$(date -d $date '+%d')/$(date -d $date '+%b')/$(date -d $date '+%Y'):"
    javasearchterm="$(date -d $date '+%Y%m%d')T"

elif [[ "$timeperiod" == "month" ]]; then
    #
    # Monthly stuff
    #
    apachesearchterm="/$(date -d $date-01 '+%b')/$(date -d $date-01 '+%Y'):"
    javasearchterm="$(date -d $date-01 '+%Y%m')"

else
    #
    # Yearly stuff
    #
    apachesearchterm="/$(date -d $date-01-01 '+%Y'):"
    javasearchterm="$(date -d $date-01-01 '+%Y')"

fi




# =====
# = Generate stats sets
# =====

#
# First, set some stuff to ignore in log files
#
apacheignore="grep -Ev \"(Sensu-HTTP-Check|dummy|check_http|Balancer)\"" 


#
# MD stats
#

# Aggregate requests
mdaggrcount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* | $apacheignore | grep ".xml" | wc -l)
mdaggrcountfriendly=$(echo $mdaggrcount | awk '{ printf ("%'"'"'d\n", $0) }')

# Aggregate downloads (i.e. HTTP 200 responses only)
mdaggrcountfull=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* | $apacheignore | grep ".xml" | grep "\" 200" | wc -l)

# Percentage of HTTP 200 responses compared to total requests
mdaggrfullpc=$(echo "scale=2;($mdaggrcountfull/$mdaggrcount)*100" | bc | awk '{printf "%.0f\n", $0}')

# Unique IP addresses requesting aggregtes
mdaggruniqueip=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* | $apacheignore | grep ".xml" | cut -f 2 -d ":" | cut -f 1 -d " " | sort | uniq | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# Total data shipped
mdaggrtotalbytes=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* | $apacheignore | grep ".xml" | grep "\" 200" | cut -f 10 -d " " | grep -v - | awk '{sum+=$1} END {print sum}')
mdaggrtotalgb=$(echo "scale=5;$mdaggrtotalbytes/1024/1024/1024" | bc | awk '{printf "%.2f\n", $0}')
mdaggrtotaltb=$(echo "scale=5;$mdaggrtotalbytes/1024/1024/1024/1024" | bc | awk '{printf "%.2f\n", $0}')

# Top 10 downloaders and how many downloads / total data shipped
mdaggrtoptenbycount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* | $apacheignore | grep ".xml" | cut -f 2 -d ":" | cut -f 1 -d " " | sort | uniq -c | sort -nr | head -10)


#
# CDS stats
#

# How many accesses to .ds.
cdscount=$(grep $apachesearchterm $logslocation/cds/shib-cds1/ssl_access_log* $logslocation/cds/shib-cds2/access_log* $logslocation/cds/shib-cds3/ssl_access_log* | grep .ds? | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# How many of these were to the DS (has entityId in the parameters)
cdsdscount=$(grep $apachesearchterm $logslocation/cds/shib-cds1/ssl_access_log* $logslocation/cds/shib-cds2/access_log* $logslocation/cds/shib-cds3/ssl_access_log* | grep .ds? | grep entityID | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# How many of these were to the WAYF (has shire in the parameters)
cdswayfcount=$(grep $apachesearchterm $logslocation/cds/shib-cds1/ssl_access_log* $logslocation/cds/shib-cds2/access_log* $logslocation/cds/shib-cds3/ssl_access_log* | grep .ds? | grep shire | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')


#
# Wugen stats
#

# Total WAYFless URLs generated
wugencount=$(grep $date $logslocation/wugen/urlgenerator-audit.* | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# New subscribers to WAYFless URLs
wugennewsubs=$(grep $date $logslocation/wugen/urlgenerator-process.* | grep "Subscribing user and service provider" | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')


#
# Test IdP stats
#

# How many logins did the IdP process?
testidplogincount=$(zgrep "^$javasearchterm" $logslocation/test-idp/idp-audit* | grep "sso/browser" | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# And to how many unique SPs?
testidpspcount=$(zgrep "^$javasearchterm" $logslocation/test-idp/idp-audit* | grep "sso/browser" | cut -f 4 -d "|" | sort | uniq | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

#
# Test SP stats
#

# How many logins were there to the SP?
testsplogincount=$(grep $date $logslocation/test-sp/shibd.log* | grep "new session created" | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# And from how many unique IdPs?
testspidpcount=$(grep $date $logslocation/test-sp/shibd.log* | grep "new session created" | cut -f 12 -d " " | sort | uniq | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# =====
# = Now we're ready to build the message. Different message for daily vs month/year
# =====

if [[ "$timeperiod" == "day" ]]; then
    #
    # Daily message, usually output via slack
    #
    msg="Daily stats for $(date -d $date '+%a %d %b %Y'):\n"
    msg+=">*MD dist:* $mdaggrcountfriendly requests ($mdaggrfullpc% full D/Ls) from $mdaggruniqueip IPs; $mdaggrtotalgb GB shipped.\n"
    msg+=">*CDS:* $cdscount requests serviced (DS: $cdsdscount / WAYF: $cdswayfcount).\n"
    msg+=">*Wugen:* $wugencount WAYFless URLs generated, $wugennewsubs new subscriptions.\n"
    msg+=">*Test IdP:* $testidplogincount logins to $testidpspcount SPs.\n"
    msg+=">*Test SP:* $testsplogincount logins from $testspidpcount IdPs."    
    
else
    #
    # Monthly/yearly message, usually output via email
    #
    msg="==========\n"
    if [[ "$timeperiod" == "month" ]]; then
        msg+="= Monthly UKf systems stats for $(date -d $date-01 '+%b %Y')\n"
    else
        msg+="= Yearly UKf systems stats for $date\n"
    fi
    msg+="==========\n"
    msg+="\n-----\n"
    msg+="Metadata aggregate distribution:\n"
    msg+="-> $mdaggrcountfriendly requests ($mdaggrfullpc% full downloads) from $mdaggruniqueip clients\n"
    msg+="-> $mdaggrtotaltb TB of data shipped.\n"
    msg+="\nTop 10 downloaders:\n"
    msg+="$mdaggrtoptenbycount\n"
    msg+="\n-----\n"
    msg+="Central Discovery Service:\n"
    msg+="-> $cdscount total requests serviced\n"
    msg+="-> DS: $cdsdscount / WAYF: $cdswayfcount\n"
    msg+="\n-----\n"
    msg+="Wugen:\n"
    msg+="-> $wugencount WAYFless URLs generated\n"
    msg+="-> $wugennewsubs new subscriptions.\n"
    msg+="\n-----\n"
    msg+="Test IdP usage:\n"
    msg+="-> $testidplogincount logins to $testidpspcount SPs.\n"
    msg+="\n-----\n"
    msg+="Test SP usage:\n"
    msg+="-> $testsplogincount logins from $testspidpcount IdPs.\n"    
    msg+="\n-----"
fi




# =====
# = Output the message.
# =====


echo -e "$msg"
exit 0