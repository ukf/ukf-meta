#!/bin/bash
#
# Compares members.xml and sf-contacts.csv and flags differences
#
# Needs some work on "The" and "&" probably flagging too many mismatches
#
# This takes sometime to process >1hr.
#
# Author: Jon Agland, jon.agland@jisc.ac.uk
# Date: 25/02/2019
# Version: 0.3
# Usage:
# * There is an ant build called 'compare.members' please use this to call the script.
# * If calling directly, you should provide a parameter for the $1 for the input file
#   which is the output of members-to-csv.xsl

if [ -z "$1" ]; then
     echo "ERROR: No file name supplied.  Did you mean to call the script directly? Try 'ant compare.members' "
     exit 1
fi

MEMBERSXML="../ukf-data/members/members.xml"
SFCONTACTS="../ukf-data/contacts/sf-contacts.csv"

# temporary files
TMPFILE=`mktemp`
MEMBERSCSV=`mktemp`
SFMEMBERSCSV=`mktemp`

# output
NOTMATCH=`mktemp`
NOTINMEMBERS=`mktemp`
MISMATCH=`mktemp`
NOTINSF=`mktemp`

# set these variables as lowercase, for doing comparisons
typeset -l jnamelower
typeset -l ukfnamelower
# we call our xsl script convert some of the contents of members.xml to a csv file.
sed -e 's/"ukforg/"/g' $1 | sort -u > $MEMBERSCSV

# in the sf-contacts.csv (sfmembers) we read only the lines with an email address
while IFS="," read -r email jod role jname
do
    if [[ $email =~ .*@.* ]];
    then
        echo "$jod,$jname" >> $TMPFILE
fi
done < $SFCONTACTS
# sort the file for unique organisations, as there will be duplicate lines based on contacts
sort -u $TMPFILE > $SFMEMBERSCSV

# read each of our csv files into an array
readarray sfmembers < $SFMEMBERSCSV
readarray ukfmembers < $MEMBERSCSV

# reset our counter
count=0

# we do a cross reference between $MISMATCH and $NOTINSF, so that we don't flag twice
mismatchcrossref=()
# find out the length of our two arrays
LENGTHSF=${#sfmembers[@]}
LENGTHUKF=${#ukfmembers[@]}

# This it the first/main loop, it checks through sfmembers and compares against ukfmembers.
# Output into the files $NOTMATCH, $NOINMEMBERS and $MISMATCH, and also populates the array mismatchcrossref()

# Based on the length of the sfmembers array
for (( j=0; j<${LENGTHSF}; j++ )); do
    # reset our match state
    match=0
    # the array items are stored with name and number, so we split
    jod=$(echo ${sfmembers[$j]} | cut -f1 -d, )
    jname=$(echo ${sfmembers[$j]} | cut -f2- -d, )
# Using the length of the ukfmembers array
    for (( k=0; k<${LENGTHUKF}; k++ )); do
        # the array items are stored with name and number, so we split
        ukforg=$(echo ${ukfmembers[$k]} | cut -f1 -d, )
        ukfname=$(echo ${ukfmembers[$k]} | cut -f2- -d, )
        # remove punctunation from names
        jnamelower=$(echo $jname | tr -d [:punct:])
        ukfnamelower=$(echo $ukfname | tr -d [:punct:])
        # compare the id numbers
        if [ "$jod" == "$ukforg" ]; then
            # compare the names
            if [ "$jnamelower" != "$ukfnamelower" ]; then
            # lets see if any of the names have ltd or limited, as we treat these the same
                if [[ $jnamelower =~ .*ltd$ ]] | [[ $jnamelower =~ .*limited$ ]] || [[ $ukfnamelower =~ .*ltd$ ]] || [[ $ukfnamelower =~ .*limited$ ]]; then
                    # try to strip off limited or ltd from the names to compare
                    jnameltd=${jnamelower%limited}
                    ukfnameltd=${ukfnamelower%ltd}
                    jnamelimited=${jnamelower%ltd}
                    ukfnamelimited=${ukfnamelower%limited}
                    # compare the names
                    if [[ "$jnameltd" == "$ukfnameltd" ]] || [[ "$jnamelimited" == "$ukfnamelimited" ]] ; then
                        # if we get match, we set our state and break from the loop
                        match=1
                        break
                    else
                        # if we don't get a match then we log it in $NOTMATCH
                        echo $jod and $ukforg match, but $jname and $ukfname do not. >>$NOTMATCH
                        # this is still a match
                        match=1
                        break
                    fi
                fi
            else
                # names and numbers all match, so match and break
                match=1
                break
            fi
        fi
        # compare the names, see if we have mismatched ids, and if so log it in $mismatch
        # add the ukforg number to mismatchcrossref array for later.
         if [ "$jnamelower" == "$ukfnamelower" ]; then
            echo $jname,$jod found in UKf members as $ukforg >>$MISMATCH
            mismatchcrossref+=($ukforg)
            match=1
         fi
    # let's increment our counter
        count=$[$count+1]
    done
    # if we didn't find a match, then they are not in UKf members, so log in $NOTINMEMBERS
    if [ $match -eq 0 ]; then
       echo $jod, $jname not in UKf members >> $NOTINMEMBERS
    fi
done

# reset our second counter
counta=0
# find out the length of mismatchcrossref
LENGTHMISMATCHCROSSREF=${#mismatchcrossref[@]}

# this is the second loop, comparing sf against ukf members
for (( k=0; k<${LENGTHSF}; k++ )); do
    # we need to log two states, a match and also where there is a mismatch
    # reset them to 0
    match=0
    mismatch=0
    # same array as earlier, so we need to pull out number and name to seperate field
    ukforg=$(echo ${ukfmembers[$k]} | cut -f1 -d, )
    ukfname=$(echo ${ukfmembers[$k]} | cut -f2- -d, )

for (( j=0; j<${LENGTHUKF}; j++ )); do
    # we are only doing number comparisons, so we just pull out the number for sfmembers
    jod=$(echo ${sfmembers[$j]} | cut -f1 -d, )
    # if the numbers match we break
    if [ "$jod" == "$ukforg" ]; then
            match=1
            break
    fi
done
    # increment our second counter
    counta=$[$counta+1]
    # if the counter equals our array length, then we can break
    if [ $counta -eq ${#ukfmembers[@]} ] && [ $counta -eq ${#sfmembers[@]} ] ; then
        match=1
        break
    fi
    # if there is no match we check the mismatchcrossref
    if [ $match -eq 0 ]; then
        # loop through the array mismatchcrossref
        for (( l=0; l<${LENGTHMISMATCHCROSSREF}; l++ )); do
            mismatchid=$(echo ${mismatchcrossref[$l]})
            # if the ID is in the mismatchcrossref array, then it appears in $MISMATCH and doesn't need to appear here
            if [ "$ukforg" == "$mismatchid" ]; then
                     mismatch=1
                     break
            fi
        done
        # if we didn't find it in mismatch, then we have no contacts log in $NOTINSF
        if [ $mismatch -eq 0 ]; then
            echo $ukforg, $ukfname no SF contacts >> $NOTINSF
        fi
    fi
done

# lets count up how many comparisons we made.
count=$[$count+$counta]


# output
echo --- Compare Members ---
echo Comparisons made $count
echo $(date)
echo --- Organisations that do not match in Salesforce vs UKf members ---
cat $NOTMATCH

echo --- Organisations that are in Salesforce but not in UKf members ---
cat $NOTINMEMBERS

echo --- Organisations that are in Salesforce but under a different ukforg in UKf members ---
cat $MISMATCH

echo --- Organisations that are in UKf members, but have no Salesforce contacts ---
sort -u $NOTINSF

# remove the temporary files
rm $NOTMATCH $NOTINMEMBERS $SFMEMBERSCSV $MEMBERSCSV $MISMATCH $TMPFILE $NOTINSF
exit
