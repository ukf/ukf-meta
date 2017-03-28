#!/bin/bash

# This script will calculate stats 
#
# Expects the following to be provided as arguments:
# * Time period - day/month/year
# * Time - YYYY-MM-DD/YYYY-MM/YYYY

# Assumes you've just run stats-sync.sh to make sure the source
# log files are up to date




# =====
# = Some common functions
# =====

bytestohr()
{
    value=$1
    valueint=$1
    i=0
    suffix=" KMGTPEZY"
    while [ $valueint -gt 1024 ]; do
        i=$((i+1))
        valueint=$((valueint/1024))
        value=$(echo "scale=1;$value/1024" | bc)
    done
    echo $value ${suffix:$i:1}B
}




# =====
# = Set some common options
# =====

logslocation="/var/stats"
usageerrormsg="usage: generate-stats.sh <time period to run stats on (day/month/year)> [<date (YYYY-MM-DD/YYYY-MM/YYYY)>]"




# =====
# = Preamble
# =====

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


# =====
# MD stats
# =====

# Get the filesize of the latest uncompressed main aggregate.
# Since this is just used for estimation, we'll just take the biggest
# unique filesize for the relevant periods
aggrfilesizebytes=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-metadata.xml" | grep "\" 200" | grep "GET" | grep -v "GZIP" | cut -f 10 -d " " | sort -r | uniq | head -1)

#
# Download counts
#

# Aggregate requests. Everything for .xml (HEAD/GET, 200 and 304)
mdaggrcount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | wc -l)
mdaggrcountfriendly=$(echo $mdaggrcount | awk '{ printf ("%'"'"'d\n", $0) }')

# Main Aggregate requests. Everything for ukfederation-metadata.xml (HEAD/GET, 200 and 304)
mdaggrmaincount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-metadata.xml" | wc -l)
mdaggrmaincountfriendly=$(echo $mdaggrmaincount | awk '{ printf ("%'"'"'d\n", $0) }')
if [[ "$mdaggrmaincount" -ne "0" ]]; then
    mdaggrmainpc=$(echo "scale=4;($mdaggrmaincount/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
else
    mdaggrmainpc="0.0"
fi

# Other aggregate requests (don't calculate these if doing daily stats)
if [[ "$timeperiod" != "day" ]]; then
    mdaggrbackcount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-back.xml" | wc -l)
    mdaggrbackcountfriendly=$(echo $mdaggrbackcount | awk '{ printf ("%'"'"'d\n", $0) }')
    if [[ "$mdaggrbackcount" -ne "0" ]]; then
        mdaggrbackpc=$(echo "scale=4;($mdaggrbackcount/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    else
        mdaggrbackpc="0.0"
    fi
    mdaggrcdsallcount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-cdsall.xml" | wc -l)
    mdaggrcdsallcountfriendly=$(echo $mdaggrcdsallcount | awk '{ printf ("%'"'"'d\n", $0) }')
    if [[ "$mdaggrcdsallcount" -ne "0" ]]; then
        mdaggrcdsallpc=$(echo "scale=4;($mdaggrcdsallcount/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    else
        mdaggrcdsallpc="0.0"
    fi
    mdaggrexportpreviewcount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-export-preview.xml" | wc -l)
    mdaggrexportpreviewcountfriendly=$(echo $mdaggrexportpreviewcount | awk '{ printf ("%'"'"'d\n", $0) }')
    if [[ "$mdaggrexportpreviewkcount" -ne "0" ]]; then
        mdaggrexportpreviewpc=$(echo "scale=4;($mdaggrexportpreviewcount/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    else
        mdaggrexportpreviewpc="0.0"
    fi
    mdaggrexportcount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-export.xml" | wc -l)
    mdaggrexportcountfriendly=$(echo $mdaggrexportcount | awk '{ printf ("%'"'"'d\n", $0) }')
    if [[ "$mdaggrexportcount" -ne "0" ]]; then
        mdaggrexportpc=$(echo "scale=4;($mdaggrexportcount/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    else
        mdaggrexportpc="0.0"
    fi
    mdaggrtestcount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-test.xml" | wc -l)
    mdaggrtestcountfriendly=$(echo $mdaggrtestcount | awk '{ printf ("%'"'"'d\n", $0) }')
    if [[ "$mdaggrtestcount" -ne "0" ]]; then
        mdaggrtestpc=$(echo "scale=4;($mdaggrtestcount/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    else
        mdaggrtestpc="0.0"
    fi
    mdaggrwayfcount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-wayf.xml" | wc -l)
    mdaggrwayfcountfriendly=$(echo $mdaggrwayfcount | awk '{ printf ("%'"'"'d\n", $0) }')
    if [[ "$mdaggrwayfcount" -ne "0" ]]; then
        mdaggrwayfpc=$(echo "scale=4;($mdaggrwayfcount/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    else
        mdaggrwayfpc="0.0"
    fi
fi

# Aggregate downloads (i.e. GETs with HTTP 200 responses only)
mdaggrcountfull=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404| grep "\" 200" | grep "GET" | wc -l)
mdaggrcountfullfriendly=$(echo $mdaggrcountfull | awk '{ printf ("%'"'"'d\n", $0) }')

# Main Aggregate downloads (i.e. GETs with HTTP 200 responses only)
mdaggrmaincountfull=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-metadata.xml" | grep "\" 200" | grep "GET" | wc -l)
mdaggrmaincountfullfriendly=$(echo $mdaggrmaincountfull | awk '{ printf ("%'"'"'d\n", $0) }')

# Percentage of GETs with HTTP 200 responses compared to total requests
if [[ "$mdaggrcount" -ne "0" ]]; then
    mdaggrfullpc=$(echo "scale=2;($mdaggrcountfull/$mdaggrcount)*100" | bc | awk '{printf "%.0f\n", $0}')
else
    mdaggrfullpc="N/A"
fi

# Compressed downloads for all
mdaggrcountfullcompr=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | grep "\" 200" | grep "GET" | grep "\"GZIP\"" | wc -l)
mdaggrcountfullcomprfriendly=$(echo $mdaggrcountfullcompr | awk '{ printf ("%'"'"'d\n", $0) }')

# Compressed downloads for main aggregate
mdaggrmaincountfullcompr=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-metadata.xml" | grep "\" 200" | grep "GET" | grep "\"GZIP\"" | wc -l)

# Percentage of GZIPPED HTTP 200 responses compared to total full downloads
if [[ "$mdaggrcountfull" -ne "0" ]]; then
    mdaggrfullcomprpc=$(echo "scale=2;($mdaggrcountfullcompr/$mdaggrcountfull)*100" | bc | awk '{printf "%.0f\n", $0}')
else
    mdaggrfullcomprpc="N/A"
fi

# Unique IP addresses requesting aggregates
mdaggruniqueip=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq | wc -l)
mdaggruniqueipfriendly=$(echo $mdaggruniqueip | awk '{ printf ("%'"'"'d\n", $0) }')

# Unique IP addresses requesting aggregates, full D/Ls only
mdaggruniqueipfull=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | grep "\" 200" | grep "GET" | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq | wc -l)

#
# Data shipped
#

# Total data shipped, all .xml files
mdaggrtotalbytes=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | grep "\" 200" | grep "GET" | cut -f 10 -d " " | awk '{sum+=$1} END {print sum}')
if [[ "$mdaggrtotalbytes" -gt "0" ]]; then
    mdaggrtotalhr=$(bytestohr $mdaggrtotalbytes)
else
    mdaggrtotalhr="0 B"
fi

# Total data shipped, ukfederation-metadata.xml file
mdaggrmaintotalbytes=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "ukfederation-metadata.xml" | grep "\" 200" | grep "GET" | cut -f 10 -d " " | awk '{sum+=$1} END {print sum}')
if [[ "$mdaggrtotalbytes" -gt "0" ]]; then
    mdaggrmaintotalhr=$(bytestohr $mdaggrmaintotalbytes)
else
    mdaggrmaintotalhr="0 B"
fi

# Estimate total data shipped without compression
mdaggrmaintotalestnocompressbytes=$(( mdaggrmaincountfull * aggrfilesizebytes ))
if [[ "$mdaggrmaintotalestnocompressbytes" -gt "0" ]]; then
    mdaggrmaintotalestnocompresshr=$(bytestohr $mdaggrmaintotalestnocompressbytes)
else
    mdaggrmaintotalestnocompresshr="0 B"
fi

# Estimate total data shipped without compression & conditional get
mdaggrmaintotalestnocompressnocgetbytes=$(( mdaggrmaincount * aggrfilesizebytes ))
 if [[ "$mdaggrmaintotalestnocompressnocgetbytes" -gt "0" ]]; then
    mdaggrmaintotalestnocompressnocgethr=$(bytestohr $mdaggrmaintotalestnocompressnocgetbytes)
else
    mdaggrmaintotalestnocompressnocgethr="0 B"
fi

#
# Other things 
#

# IPv4 vs IPv6 traffic (don't calculate these if doing daily stats)
# Some v6 traffic has traditionally passed through v6v4proxy1/2, so to count v4 we're counting all accesses, minus those from the v4 proxy IP addresses, minus actual v6 addresses
if [[ "$timeperiod" != "day" ]]; then
    mdaggrv4count=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 1 -d " " | cut -f 2-9 -d ":" | grep -v 193.63.72.83 | grep -v 194.83.7.211 | grep -v ":" | wc -l)
    mdaggrv4pc=$(echo "scale=4;($mdaggrv4count/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    mdaggrv6count=$(( mdaggrcount - mdaggrv4count ))
    mdaggrv6pc=$(echo "scale=4;($mdaggrv6count/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')

    # Per-server request count
    mdaggrmd1count=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 5 -d "/" | wc -l)
    mdaggrmd1pc=$(echo "scale=4;($mdaggrmd1count/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    mdaggrmd2count=$(grep $apachesearchterm $logslocation/md/md2/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 5 -d "/" | wc -l)
    mdaggrmd2pc=$(echo "scale=4;($mdaggrmd2count/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    mdaggrmd3count=$(grep $apachesearchterm $logslocation/md/md3/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 5 -d "/" | wc -l)
    mdaggrmd3pc=$(echo "scale=4;($mdaggrmd3count/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    mdaggrmdne01count=$(grep $apachesearchterm $logslocation/md/md-ne-01/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 5 -d "/" | wc -l)
    mdaggrmdne01pc=$(echo "scale=4;($mdaggrmdne01count/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    mdaggrmdne02count=$(grep $apachesearchterm $logslocation/md/md-ne-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 5 -d "/" | wc -l)
    mdaggrmdne02pc=$(echo "scale=4;($mdaggrmdne02count/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    mdaggrmdwe01count=$(grep $apachesearchterm $logslocation/md/md-we-01/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 5 -d "/" | wc -l)
    mdaggrmdwe01pc=$(echo "scale=4;($mdaggrmdwe01count/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    mdaggrmdwe02count=$(grep $apachesearchterm $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 5 -d "/" | wc -l)
    mdaggrmdwe02pc=$(echo "scale=4;($mdaggrmdwe02count/$mdaggrcount)*100" | bc | awk '{printf "%.1f\n", $0}')
fi


# Min queries per IP
if [[ $mdaggrcount -gt "0" ]]; then
    mdaggrminqueriesperip=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq -c | sort -nr | tail -1 | awk '{print $1}' | awk '{ printf ("%'"'"'d\n", $0) }')
else
    mdaggrinqueriesperip="0"
fi

# Avg queries per IP
if [[ "$mdaggruniqueip" -ne "0" ]]; then
    mdaggravgqueriesperip=$(echo "scale=2;($mdaggrcount/$mdaggruniqueip)" | bc | awk '{printf "%.0f\n", $0}')
else
    mdaggravgqueriesperip="0"
fi

# Max queries per IP
if [[ $mdaggrcount -gt "0" ]]; then
    mdaggrmaxqueriesperip=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq -c | sort -nr | head -1 | awk '{print $1}' | awk '{ printf ("%'"'"'d\n", $0) }')
else
    mdaggrmaxqueriesperip="0"
fi

# Min queries per IP, full D/L only
if [[ $mdaggrcountfull -gt "0" ]]; then
    mdaggrminqueriesperipfull=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | grep "\" 200" | grep "GET" | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq -c | sort -nr | tail -1 | awk '{print $1}' | awk '{ printf ("%'"'"'d\n", $0) }')
else
    mdaggrinqueriesperipfull="0"
fi

# Avg queries per IP, full D/L only
if [[ "$mdaggruniqueipfull" -ne "0" ]]; then
    mdaggravgqueriesperipfull=$(echo "scale=2;($mdaggrcountfull/$mdaggruniqueipfull)" | bc | awk '{printf "%.0f\n", $0}')
else
    mdaggravgqueriesperipfull="0"
fi

# Max queries per IP, full D/L only
if [[ $mdaggrcountfull -gt "0" ]]; then
    mdaggrmaxqueriesperipfull=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | grep "\" 200" | grep "GET" | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq -c | sort -nr | head -1 | awk '{print $1}' | awk '{ printf ("%'"'"'d\n", $0) }')
else
    mdaggrmaxqueriesperipfull="0"
fi

# Don't count these when doing daily stats
if [[ "$timeperiod" != "day" ]]; then

    # Top 10 downloaders and how many downloads / total data shipped (full downloads only)
    if [[ "$timeperiod" != "day" ]]; then
        mdaggrtoptenipsbycount=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | grep "\" 200" | grep "GET" | grep -v 193.63.72.83 | grep -v 194.83.7.211 | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq -c | sort -nr | head -10)
    fi

    #
    # Manipute results of the top 10
    #
    
    # Blank the output we're going to set
    mdaggrtoptenipsbycountdetailed=""
    
    i=1
    IFS=$'\n'
    for line in $mdaggrtoptenipsbycount
    do
        # Parse the line
        count=$(echo $line | awk '{print $1}')
        ipaddr=$(echo $line | awk '{print $2'})
    
        # Make count friendly
        countfriendly=$(echo $count | awk '{ printf ("%'"'"'d\n", $0) }')
    
        # Figure out total traffic shipped to this IP
        totaldataforthisip=$(grep $apachesearchterm $logslocation/md/md1/metadata.uou-access_log* $logslocation/md/md2/metadata.uou-access_log* $logslocation/md/md3/metadata.uou-access_log* $logslocation/md/md-ne-01/metadata.uou-access_log* $logslocation/md/md-ne-02/metadata.uou-access_log* $logslocation/md/md-we-01/metadata.uou-access_log* $logslocation/md/md-we-02/metadata.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep ".xml" | grep -v 404 | grep "\" 200" | grep "GET" | grep $ipaddr | cut -f 10 -d " " | grep -v - | awk '{sum+=$1} END {print sum}')
        if [[ "$totaldataforthisip" -gt "0" ]]; then
            totaldataforthisiphr=$(bytestohr $totaldataforthisip)
        else
            totaldataforthisiphr="0 B"
        fi
    
        # Get Reverse DNS for this IP address
        rdnsforthisip=$(dig +noall +answer -x $ipaddr | awk '{print $5}')
        if [[ -z $rdnsforthisip ]]; then
            rdnsforthisip="No RDNS available"
        fi
    
        # Add to the output
        mdaggrtoptenipsbycountdetailed+="$i: $countfriendly D/Ls ($totaldataforthisiphr) from $ipaddr ($rdnsforthisip)\n"
        
        # Increment the count, and blank the rdns response
        i=$((i+1))
        rdnsforthisip=""
    done
fi


# =====
# MDQ stats
# =====

# MDQ requests
mdqcount=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep -v 404 | grep "/entities" | grep -v "/entities " | grep -v "/entities/ " | wc -l)
mdqcountfriendly=$(echo $mdqcount | awk '{ printf ("%'"'"'d\n", $0) }')

# MDQ downloads (i.e. HTTP 200 responses only)
mdqcountfull=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities" | grep -v "/entities " | grep -v "/entities/ " | grep -v 404 | grep "\" 200" | grep "GET" | wc -l)
mdqcountfullfriendly=$(echo $mdqcountfull | awk '{ printf ("%'"'"'d\n", $0) }')

# Percentage of HTTP 200 responses compared to total requests
if [[ "$mdqcount" -ne "0" ]]; then
    mdqfullpc=$(echo "scale=2;($mdqcountfull/$mdqcount)*100" | bc | awk '{printf "%.0f\n", $0}')
else
    mdqfullpc="N/A"
fi

# Compressed downloads
mdqfullcomprcount=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities" | grep -v "/entities " | grep -v "/entities/ " | grep -v 404 | grep "\" 200" | grep "GET" | grep "\"GZIP\"" | wc -l)
mdqfullcomprcountfriendly=$(echo $mdqfullcomprcount | awk '{ printf ("%'"'"'d\n", $0) }')

# Percentage of GZIPPED HTTP 200 responses compared to total full downloads
if [[ "$mdqcountfull" -ne "0" ]]; then
    mdqfullcomprpc=$(echo "scale=2;($mdqfullcomprcount/$mdqcountfull)*100" | bc | awk '{printf "%.0f\n", $0}')
else
    mdqfullcomprpc="N/A"
fi


# IPv4 vs IPv6 traffic (don't calculate this for daily stats)

if [[ "$timeperiod" != "day" ]]; then
    # Some v6 traffic has traditionally passed through v6v4proxy1/2, so to count v4 we're counting all accesses, minus those from the v4 proxy IP addresses, minus actual v6 addresses
    if [[ "$mdqcount" -ne "0" ]]; then
        mdqv4count=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities" | grep -v "/entities " | grep -v "/entities/ " | grep -v 404 | cut -f 1 -d " " | cut -f 2-9 -d ":" | grep -v 193.63.72.83 | grep -v 194.83.7.211 | grep -v ":" | wc -l)
        mdqv4pc=$(echo "scale=4;($mdqv4count/$mdqcount)*100" | bc | awk '{printf "%.1f\n", $0}')
        mdqv6count=$(( mdqcount - mdqv4count ))
        mdqv6pc=$(echo "scale=4;($mdqv6count/$mdqcount)*100" | bc | awk '{printf "%.1f\n", $0}')
    else
        mdqv4pc="N/A"
        mdqv6pc="N/A"
    fi
fi

# MDQ requests for entityId based names
mdqcountentityidhttp=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities" | grep -v "/entities " | grep -v "/entities/ " | grep -v 404 | grep "/entities/http" | wc -l)
mdqcountentityidurn=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities" | grep -v "/entities " | grep -v "/entities/ " | grep -v 404 | grep "/entities/urn" | wc -l)
mdqcountentityid=$((mdqcountentityidhttp+mdqcountentityidurn))
if [[ "$mdqcount" -ne "0" ]]; then
    mdqcountentityidpc=$(echo "scale=3;($mdqcountentityid/$mdqcount)*100" | bc | awk '{printf "%.1f\n", $0}')
else
    mdqcountentityidpc="N/A"
fi
mdqcountentityidfriendly=$(echo $mdqcountentityid | awk '{ printf ("%'"'"'d\n", $0) }')

# MDQ requests for hash based names
mdqcountsha1=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities" | grep -v "/entities " | grep -v "/entities/ " | grep -v 404 | grep sha1 | wc -l)
if [[ "$mdqcount" -ne "0" ]]; then
    mdqcountsha1pc=$(echo "scale=3;($mdqcountsha1/$mdqcount)*100" | bc | awk '{printf "%.1f\n", $0}')
else
    mdqcountsha1pc="N/A"
fi
mdqcountsha1friendly=$(echo $mdqcountsha1 | awk '{ printf ("%'"'"'d\n", $0) }')


# MDQ requests for all entities
mdqcountallentities=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities " | grep -v 404 | wc -l)

# Unique IP addresses requesting MDQ
mdquniqueip=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities/" | grep -v "/entities/ " | grep -v 404 | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq | wc -l)
mdquniqueipfriendly=$(echo $mdquniqueip | awk '{ printf ("%'"'"'d\n", $0) }')

# Total data shipped
mdqtotalbytes=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities/" | grep -v "/entities/ " | grep -v 404 | grep "\" 200" | cut -f 10 -d " " | grep -v - | awk '{sum+=$1} END {print sum}')
if [[ "$mdqtotalbytes" -gt "0" ]]; then
    mdqtotalhr=$(bytestohr $mdqtotalbytes)
else
    mdqtotalhr="0 B"
fi

# Min queries per IP
if [[ $mdqcount -gt "0" ]]; then
    mdqminqueriesperip=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities" | grep -v 404 | grep -v "/entities/ " | grep -v "/entities/ " | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq -c | sort -nr | tail -1 | awk '{print $1}' | awk '{ printf ("%'"'"'d\n", $0) }')
else
    mdqminqueriesperip="0"
fi

# Avg queries per IP
if [[ "$mdquniqueip" -ne "0" ]]; then
    mdqavgqueriesperip=$(echo "scale=2;($mdqcount/$mdquniqueip)" | bc | awk '{printf "%.0f\n", $0}')
else
    mdqavgqueriesperip="0"
fi

# Max queries per IP
if [[ $mdqcount -gt "0" ]]; then
    mdqmaxqueriesperip=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities" | grep -v 404 | grep -v "/entities/ " | grep -v "/entities/ " | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq -c | sort -nr | head -1 | awk '{print $1}' | awk '{ printf ("%'"'"'d\n", $0) }')
else
    mdqmaxqueriesperip="0"
fi

if [[ "$timeperiod" != "day" ]]; then
    # Top 10 downloaders and how many downloads / total data shipped
    mdqtoptenipsbycount=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep -v 193.63.72.83 | grep -v 194.83.7.211 | grep "/entities" | grep -v "/entities/ " | grep -v 404 | grep -v "/entities/ " | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq -c | sort -nr | head -10)
    
    #
    # Manipute results of the top 10
    #
    
    # Blank the output we're going to set
    mdqtoptenipsbycountdetailed=""
    
    i=1
    IFS=$'\n'
    for line in $mdqtoptenipsbycount
    do
        # Parse the line
        count=$(echo $line | awk '{print $1}')
        ipaddr=$(echo $line | awk '{print $2'})
    
        # Make count friendly
        countfriendly=$(echo $count | awk '{ printf ("%'"'"'d\n", $0) }')
    
        # Figure out total traffic shipped to this IP
        totaldataforthisip=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep "/entities/" | grep -v "/entities/ " | grep -v 404 | grep "\" 200" | grep $ipaddr | cut -f 10 -d " " | grep -v - | awk '{sum+=$1} END {print sum}')
        if [[ "$totaldataforthisip" -gt "0" ]]; then
            totaldataforthisiphr=$(bytestohr $totaldataforthisip)
        else
            totaldataforthisiphr="0 B"
        fi
    
        # Get Reverse DNS for this IP address
        rdnsforthisip=$(dig +noall +answer -x $ipaddr | awk '{print $5}')
        if [[ -z $rdnsforthisip ]]; then
            rdnsforthisip="No RDNS available"
        fi
    
        # Add to the output
        mdqtoptenipsbycountdetailed+="$i: $countfriendly D/Ls ($totaldataforthisiphr) from $ipaddr ($rdnsforthisip)\n"
        
        # Increment the count, and blank the rdns response
        i=$((i+1))
        rdnsforthisip=""
    done
    
    
    # Top 10 queries and how many downloads / total data shipped
    mdqtoptenqueriesbycount=$(grep $apachesearchterm $logslocation/md/md1/mdq.uou-access_log* $logslocation/md/md2/mdq.uou-access_log* $logslocation/md/md3/mdq.uou-access_log* $logslocation/md/md-ne-01/mdq.uou-access_log* $logslocation/md/md-ne-02/mdq.uou-access_log* $logslocation/md/md-we-01/mdq.uou-access_log* $logslocation/md/md-we-02/mdq.uou-access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep /entities/ | grep -v 404 | grep -v "/entities/ " | grep -v "/entities/ " | awk '{print $7}' | cut -f 3 -d "/" | sed "s@+@ @g;s@%@\\\\x@g" | sort | uniq -c | xargs -0 printf "%b" | sort -nr | head -10)
fi

# =====
# CDS stats
# =====

# How many accesses to .ds.
cdscount=$(grep $apachesearchterm $logslocation/cds/shib-cds1/ssl_access_log* $logslocation/cds/shib-cds2/ssl_access_log* $logslocation/cds/shib-cds3/ssl_access_log* $logslocation/cds/shibcds-ne-01/ssl_access_log* $logslocation/cds/shibcds-ne-02/ssl_access_log* $logslocation/cds/shibcds-we-01/ssl_access_log* $logslocation/cds/shibcds-we-02/ssl_access_log* | grep .ds? | wc -l)
cdscountfriendly=$(echo $cdscount | awk '{ printf ("%'"'"'d\n", $0) }')

# IPv4 vs IPv6 traffic (don't count these for daily stats)
if [[ "$timeperiod" != "day" ]]; then
    # Some v6 traffic has traditionally passed through v6v4proxy1/2, so to count v4 we're counting all accesses, minus those from the v4 proxy IP addresses, minus actual v6 addresses
    cdsv4count=$(grep $apachesearchterm $logslocation/cds/shib-cds1/ssl_access_log* $logslocation/cds/shib-cds2/ssl_access_log* $logslocation/cds/shib-cds3/ssl_access_log* $logslocation/cds/shibcds-ne-01/ssl_access_log* $logslocation/cds/shibcds-ne-02/ssl_access_log* $logslocation/cds/shibcds-we-01/ssl_access_log* $logslocation/cds/shibcds-we-02/ssl_access_log* | grep .ds? | cut -f 1 -d " " | cut -f 2-9 -d ":" | grep -v 193.63.72.83 | grep -v 194.83.7.211 | grep -v ":" | wc -l)
    cdsv4pc=$(echo "scale=4;($cdsv4count/$cdscount)*100" | bc | awk '{printf "%.1f\n", $0}')
    cdsv6count=$(( cdscount - cdsv4count ))
    cdsv6pc=$(echo "scale=4;($cdsv6count/$cdscount)*100" | bc | awk '{printf "%.1f\n", $0}')

    # Per-server request count
    cds1count=$(grep $apachesearchterm $logslocation/cds/shib-cds1/ssl_access_log* | grep .ds? | wc -l)
    cds1pc=$(echo "scale=4;($cds1count/$cdscount)*100" | bc | awk '{printf "%.1f\n", $0}')
    cds2count=$(grep $apachesearchterm $logslocation/cds/shib-cds2/ssl_access_log* | grep .ds? | wc -l)
    cds2pc=$(echo "scale=4;($cds2count/$cdscount)*100" | bc | awk '{printf "%.1f\n", $0}')
    cds3count=$(grep $apachesearchterm $logslocation/cds/shib-cds3/ssl_access_log* | grep .ds? | wc -l)
    cds3pc=$(echo "scale=4;($cds3count/$cdscount)*100" | bc | awk '{printf "%.1f\n", $0}')
    cdsne01count=$(grep $apachesearchterm $logslocation/cds/shibcds-ne-01/ssl_access_log* | grep .ds? | wc -l)
    cdsne01pc=$(echo "scale=4;($cdsne01count/$cdscount)*100" | bc | awk '{printf "%.1f\n", $0}')
    cdsne02count=$(grep $apachesearchterm $logslocation/cds/shibcds-ne-02/ssl_access_log* | grep .ds? | wc -l)
    cdsne02pc=$(echo "scale=4;($cdsne02count/$cdscount)*100" | bc | awk '{printf "%.1f\n", $0}')
    cdswe01count=$(grep $apachesearchterm $logslocation/cds/shibcds-we-01/ssl_access_log* | grep .ds? | wc -l)
    cdswe01pc=$(echo "scale=4;($cdswe01count/$cdscount)*100" | bc | awk '{printf "%.1f\n", $0}')
    cdswe02count=$(grep $apachesearchterm $logslocation/cds/shibcds-we-02/ssl_access_log* | grep .ds? | wc -l)
    cdswe02pc=$(echo "scale=4;($cdswe02count/$cdscount)*100" | bc | awk '{printf "%.1f\n", $0}')
fi

# How many of these were to the DS (has entityId in the parameters)
cdsdscount=$(grep $apachesearchterm $logslocation/cds/shib-cds1/ssl_access_log* $logslocation/cds/shib-cds2/ssl_access_log* $logslocation/cds/shib-cds3/ssl_access_log* $logslocation/cds/shibcds-ne-01/ssl_access_log* $logslocation/cds/shibcds-ne-02/ssl_access_log* $logslocation/cds/shibcds-we-01/ssl_access_log* $logslocation/cds/shibcds-we-02/ssl_access_log* | grep .ds? | grep entityID | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# How many of these were to the WAYF (has shire in the parameters)
cdswayfcount=$(grep $apachesearchterm $logslocation/cds/shib-cds1/ssl_access_log* $logslocation/cds/shib-cds2/ssl_access_log* $logslocation/cds/shib-cds3/ssl_access_log* $logslocation/cds/shibcds-ne-01/ssl_access_log* $logslocation/cds/shibcds-ne-02/ssl_access_log* $logslocation/cds/shibcds-we-01/ssl_access_log* $logslocation/cds/shibcds-we-02/ssl_access_log* | grep .ds? | grep shire | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')


# =====
# Wugen stats
# =====

# Total WAYFless URLs generated
wugencount=$(grep $date $logslocation/wugen/urlgenerator-audit.* | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# New subscribers to WAYFless URLs
wugennewsubs=$(grep $date $logslocation/wugen/urlgenerator-process.* | grep "Subscribing user and service provider" | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')


# =====
# Test IdP stats
# =====

# How many logins did the IdP process?
testidplogincount=$(zgrep "^$javasearchterm" $logslocation/test-idp/idp-audit* | grep "sso/browser" | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# And to how many unique SPs?
testidpspcount=$(zgrep "^$javasearchterm" $logslocation/test-idp/idp-audit* | grep "sso/browser" | cut -f 4 -d "|" | sort | uniq | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# Don't count these for daily stats
if [[ "$timeperiod" != "day" ]]; then
    # Top 10 SPs the IdP has logged into
    testidptoptenspsbycount=$(zgrep "^$javasearchterm" $logslocation/test-idp/idp-audit* | grep "sso/browser" | cut -d "|" -f 4 | sort | uniq -c | sort -nr | head -10)
    
    # Which Test IdPs accounts are being used, and how much?
    testidplogincountbyuser=$(zgrep "^$javasearchterm" $logslocation/test-idp/idp-audit* | grep "sso/browser" | cut -d "|" -f 9 | sort | uniq -ic)
fi


# =====
# Test SP stats
# =====

# How many logins were there to the SP?
testsplogincount=$(grep $date $logslocation/test-sp/shibd.log* | grep "new session created" | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# And from how many unique IdPs?
testspidpcount=$(grep $date $logslocation/test-sp/shibd.log* | grep "new session created" | cut -f 12 -d " " | sort | uniq | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# Don't count these for daily stats
if [[ "$timeperiod" != "day" ]]; then
    # Top 10 IdPs used to log into the Test SP
    testsptoptenidpsbycount=$(grep $date $logslocation/test-sp/shibd.log* | grep "new session created" | awk '{print $12}' | cut -d "(" -f 2 | cut -d ")" -f 1 | sort | uniq -c | sort -nr | head -10)
fi


# =====
# Website stats
# =====

# How many requests were there for the main content files?
wwwaccesscount=$(grep $apachesearchterm $logslocation/www/web1/ssl_access_log* $logslocation/www/web2/ssl_access_log* $logslocation/www/www-ne-01/ssl_access_log* $logslocation/www/www-we-01/ssl_access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep 200 | grep "/content/" | wc -l)
wwwaccesscountfriendly=$(echo $wwwaccesscount | awk '{ printf ("%'"'"'d\n", $0) }')

# And from how many unique IdPs?
wwwaccessipcount=$(grep $apachesearchterm $logslocation/www/web1/ssl_access_log* $logslocation/www/web2/ssl_access_log* $logslocation/www/www-ne-01/ssl_access_log* $logslocation/www/www-we-01/ssl_access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep 200 | grep "/content/" | cut -f 1 -d " " | cut -f 2-9 -d ":" | sort | uniq | wc -l | awk '{ printf ("%'"'"'d\n", $0) }')

# Don't count these when doing daily stats
if [[ "$timeperiod" != "day" ]]; then

    # Per-server request count
    wwwaccessweb1count=$(grep $apachesearchterm $logslocation/www/web1/ssl_access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep 200 | grep "/content/" | wc -l)
    wwwaccessweb1pc=$(echo "scale=4;($wwwaccessweb1count/$wwwaccesscount)*100" | bc | awk '{printf "%.1f\n", $0}')
    wwwaccessweb2count=$(grep $apachesearchterm $logslocation/www/web2/ssl_access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep 200 | grep "/content/" | wc -l)
    wwwaccessweb2pc=$(echo "scale=4;($wwwaccessweb2count/$wwwaccesscount)*100" | bc | awk '{printf "%.1f\n", $0}')
    wwwaccessne01count=$(grep $apachesearchterm $logslocation/www/www-ne-01/ssl_access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep 200 | grep "/content/" | wc -l)
    wwwaccessne01pc=$(echo "scale=4;($wwwaccessne01count/$wwwaccesscount)*100" | bc | awk '{printf "%.1f\n", $0}')
    wwwaccesswe01count=$(grep $apachesearchterm $logslocation/www/www-we-01/ssl_access_log* | grep -Ev "(Sensu-HTTP-Check|dummy|check_http|Balancer)" | grep 200 | grep "/content/" | wc -l)
    wwwaccesswe01pc=$(echo "scale=4;($wwwaccesswe01count/$wwwaccesscount)*100" | bc | awk '{printf "%.1f\n", $0}')
fi


# =====
# = Now we're ready to build the message. Different message for daily vs month/year
# =====

if [[ "$timeperiod" == "day" ]]; then
    #
    # Daily message, usually output via slack
    #
    msg="Daily stats for $(date -d $date '+%a %d %b %Y'):\n"
    msg+=">*MD dist:* $mdaggrcountfriendly requests* from $mdaggruniqueipfriendly IPs, $mdaggrtotalhr shipped.\n"
    msg+=">-> * $mdaggrcountfullfriendly ($mdaggrfullpc%) were full D/Ls, of which $mdaggrcountfullcomprfriendly ($mdaggrfullcomprpc%) were compressed.\n"
    msg+=">-> ukf-md.xml: $mdaggrmaintotalhr actual; est. $mdaggrmaintotalestnocompresshr w/no compr, $mdaggrmaintotalestnocompressnocgethr also w/no c/get.\n"
    msg+=">-> $mdaggrminqueriesperip/$mdaggravgqueriesperip/$mdaggrmaxqueriesperip min/avg/max queries per querying IP (all reqs)\n"
    msg+=">-> $mdaggrminqueriesperipfull/$mdaggravgqueriesperipfull/$mdaggrmaxqueriesperipfull min/avg/max queries per querying IP (full D/Ls only)\n"
    msg+=">*MDQ:* $mdqcountfriendly requests* from $mdquniqueipfriendly IPs, $mdqtotalhr shipped.\n"
    msg+=">-> * $mdqcountfullfriendly ($mdqfullpc%) were full D/Ls, of which $mdqfullcomprcountfriendly ($mdqfullcomprpc%) were compressed.\n"
    msg+=">-> $mdqcountentityidfriendly ($mdqcountentityidpc%) entityId vs $mdqcountsha1friendly ($mdqcountsha1pc%) sha1 based queries\n"
    msg+=">-> $mdqminqueriesperip/$mdqavgqueriesperip/$mdqmaxqueriesperip min/avg/max queries per querying IP\n"
    msg+=">-> $mdqcountallentities queries for collection of all entities\n"
    msg+=">*CDS:* $cdscountfriendly requests serviced (DS: $cdsdscount / WAYF: $cdswayfcount).\n"
    msg+=">*Wugen:* $wugencount WAYFless URLs generated, $wugennewsubs new subscriptions.\n"
    msg+=">*Test IdP:* $testidplogincount logins to $testidpspcount SPs.\n"
    msg+=">*Test SP:* $testsplogincount logins from $testspidpcount IdPs.\n"
    msg+=">*Website:* $wwwaccesscountfriendly hits from $wwwaccessipcount unique IPs."
    
    
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
    msg+="-> $mdaggrcountfriendly requests* from $mdaggruniqueipfriendly clients, $mdaggrtotalhr shipped.\n"
    msg+="--> * $mdaggrcountfullfriendly ($mdaggrfullpc%) were full downloads, of which $mdaggrcountfullcomprfriendly ($mdaggrfullcomprpc%) were compressed.\n"
    msg+="--> ukfederation-metadata.xml: $mdaggrmaintotalhr of data actually shipped; would have been an estimated $mdaggrmaintotalestnocompresshr without compression, and $mdaggrmaintotalestnocompressnocgethr without compression or conditional gets.\n"
    msg+="-> IPv4: $mdaggrv4pc% vs IPv6: $mdaggrv6pc%\n"
    msg+="-> Server distribution: md-ne-01: $mdaggrmdne01pc% md-ne-02: $mdaggrmdne02pc% md-we-01: $mdaggrmdwe01pc% md-we-02: $mdaggrmdwe02pc% / md1: $mdaggrmd1pc% md2: $mdaggrmd2pc% md3: $mdaggrmd3pc%\n"
    msg+="-> $mdaggrminqueriesperip/$mdaggravgqueriesperip/$mdaggrmaxqueriesperip min/avg/max queries per querying IP (all reqs)\n"
    msg+="-> $mdaggrminqueriesperipfull/$mdaggravgqueriesperipfull/$mdaggrmaxqueriesperipfull min/avg/max queries per querying IP (full D/Ls only)\n"
    msg+="\nRequests per published aggregate\n"
    msg+="-> * ukfederation-metadata.xml = $mdaggrmaincountfriendly requests ($mdaggrmainpc% of total)\n"
    msg+="-> * ukfederation-back.xml     = $mdaggrbackcountfriendly requests ($mdaggrbackpc% of total)\n"
    msg+="-> * ukfederation-test.xml     = $mdaggrtestcountfriendly requests ($mdaggrtestpc% of total)\n"
    msg+="-> * ukfederation-export.xml   = $mdaggrexportcountfriendly requests ($mdaggrexportpc% of total)\n"
    msg+="-> * ukfed'-export-preview.xml = $mdaggrexportpreviewcountfriendly requests ($mdaggrexportpreviewpc% of total)\n"
    msg+="-> * ukfederation-cdsall.xml   = $mdaggrcdsallcountfriendly requests ($mdaggrcdsallpc% of total)\n"
    msg+="-> * ukfederation-wayf.xml     = $mdaggrwayfcountfriendly requests ($mdaggrwayfpc% of total)\n"
    msg+="\nTop 10 downloaders (full downloads only):\n"
    msg+="$mdaggrtoptenipsbycountdetailed\n"
    msg+="\n-----\n"
    msg+="MDQ:\n"
    msg+="-> $mdqcountfriendly requests* from $mdquniqueipfriendly clients, $mdqtotalhr shipped.\n"
    msg+="--> * $mdqcountfullfriendly ($mdqfullpc%) were full downloads, of which $mdqfullcomprcountfriendly ($mdqfullcomprpc%) were compressed.\n"
    msg+="-> $mdqcountentityidfriendly ($mdqcountentityidpc%) entityId vs $mdqcountsha1friendly ($mdqcountsha1pc%) sha1 based queries\n"
    msg+="-> IPv4: $mdqv4pc% vs IPv6: $mdqv6pc%\n"
    msg+="-> $mdqminqueriesperip min/$mdqavgqueriesperip avg/$mdqmaxqueriesperip max queries per querying IP\n"
    msg+="-> $mdqcountallentities queries for collection of all entities\n"
    msg+="\nTop 10 queryers:\n"
    msg+="$mdqtoptenipsbycountdetailed\n"
    msg+="\nTop 10 entities queried for:\n"
    msg+="$mdqtoptenqueriesbycount\n"
    msg+="\n-----\n"
    msg+="Central Discovery Service:\n"
    msg+="-> $cdscountfriendly total requests serviced\n"
    msg+="-> IPv4: $cdsv4pc% vs IPv6: $cdsv6pc%\n"
    msg+="-> Server distribution: shibcds-ne-01: $cdsne01pc% shibcds-ne-02: $cdsne02pc% shibcds-we-01: $cdswe01pc% shibcds-we-02: $cdswe02pc% / shib-cds1: $cds1pc% shib-cds2: $cds2pc% shib-cds3: $cds3pc%\n"
    msg+="-> DS: $cdsdscount / WAYF: $cdswayfcount\n"
    msg+="\n-----\n"
    msg+="Wugen:\n"
    msg+="-> $wugencount WAYFless URLs generated\n"
    msg+="-> $wugennewsubs new subscriptions.\n"
    msg+="\n-----\n"
    msg+="Test IdP usage:\n"
    msg+="-> $testidplogincount logins to $testidpspcount SPs.\n"
    msg+="\n-> Logins per test user:\n"
    msg+="$testidplogincountbyuser\n"
    msg+="\n-> Top 10 SPs logged into:\n"
    msg+="$testidptoptenspsbycount\n"
    msg+="\n-----\n"
    msg+="Test SP usage:\n"
    msg+="-> $testsplogincount logins from $testspidpcount IdPs.\n"    
    msg+="\n-> Top 10 IdPs logged in from:\n"
    msg+="$testsptoptenidpsbycount\n"
    msg+="\n-----\n"
    msg+="Website usage:\n"
    msg+="-> $wwwaccesscountfriendly hits from $wwwaccessipcount unique IPs.\n"
    msg+="-> Server distribution: www-ne-01: $wwwaccessne01pc% www-we-01: $wwwaccesswe01pc% / web1: $wwwaccessweb1pc% web2: $wwwaccessweb2pc% \n"
    msg+="\n-----"
fi




# =====
# = Output the message.
# =====


echo -e "$msg"
exit 0