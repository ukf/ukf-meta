#!/bin/bash

# This script will output details about the current UKf publication and 
# the differences since the last.
#
# Expects the following to be provided as arguments:
# * Absolute path to data repository
# * Absolute path to products repository
#
# Assumes the data repository's master branch is currently checked out.
#

# Fail if $1 and $2 aren't provided.
if [[ -z $1 && -z $2 ]]; then
    echo "usage: diff-between-publications.sh <path to data repository> <path to products repository>"
    exit 1
fi

# Get the input
repodata=$1
repoproducts=$2

# =====
# = First of all, we need to calculate some stuff.
# =====

# Figure out name of the latest tag and the previous tag.
# These point to the latest, and previous, publication.
currenttag=$(git --work-tree=$repoproducts --git-dir=$repoproducts/.git tag | tail -n 1)
previoustag=$(git --work-tree=$repoproducts --git-dir=$repoproducts/.git tag | tail -n 2 | head -n 1)

# Calculate current member count (the final awk is for Mac compatibility, since wc on Mac outputs leading spaces)
membercount=$(grep 'Member ID' $repodata/members/members.xml | wc -l | awk '{print $1}')

# Calculate current entities count (UK only)
entitycountuk=$(grep 'registrationAuthority="http://ukfederation.org.uk"' $repoproducts/aggregates/ukfederation-metadata.xml | wc -l | awk '{print $1}')

# Calculate current entities count (total, including all imported entities)
entitycounttotal=$(grep '<EntityDescriptor' $repoproducts/aggregates/ukfederation-metadata.xml | wc -l | awk '{print $1}')

# Calculate size of current aggregate, in bytes and MB
currentaggregatesize=$(cat $repoproducts/aggregates/ukfederation-metadata.xml | wc -c)
currentaggregatesizemb=$(echo "scale=2;$currentaggregatesize/1024/1024" | bc )

# Calculate size of previous aggregate
previousaggregatesize=$(git --work-tree=$repoproducts --git-dir=$repoproducts/.git show $previoustag:aggregates/ukfederation-metadata.xml | wc -c)
previousaggregatesizemb=$(echo "scale=2;$previousaggregatesize/1024/1024" | bc )

# Calculate difference in size between current and previous in both absolute and percentage terms
aggregatesizediff=$((currentaggregatesize-previousaggregatesize))
aggregatesizediffpc=$(echo "scale=5;$aggregatesizediff/$previousaggregatesize" | bc | awk '{printf "%.5f\n", $0}')

# Calculate git log between the current and previous aggregation, by
# -> First, calculate date/time of latest publication (epoch) in products repo
# -> Next, calculate date/time of previous publication (epoch) in products repo
# -> Finally, get a git log between those two dates (epoch) in data repo
currenttagdate=$(git --work-tree=$repoproducts --git-dir=$repoproducts/.git log -1 $currenttag --format=%ct)
previoustagdate=$(git --work-tree=$repoproducts --git-dir=$repoproducts/.git log -1 $previoustag --format=%ct)
gitlog=$(git --work-tree=$repodata --git-dir=$repodata/.git log --format="%h %an %s" --after=$previoustagdate --before=$currenttagdate)
gitlognumentries=$(git --work-tree=$repodata --git-dir=$repodata/.git log --format="%h %an %s" --after=$previoustagdate --before=$currenttagdate | wc -l | awk '{print $1}')

# =====
# = Now we're ready to output the message
# =====

# First part of the message is just a canned success message with a timestamp 
msg="$(date) - Successfully published new UKf metadata.\n"

# Second part is some stats about the UK fed
msg+="-> The UK federation now has $membercount members and $entitycountuk entities.\n"

# Third part is stats about the aggregate, and some diff info
if [ $aggregatesizediff -lt 0 ]; then
    aggregatesizediffnegated=$(( $aggregatesizediff * -1 ))
    msg+="-> The main aggregate contains $entitycounttotal entities and is $currentaggregatesizemb MB ($aggregatesizediffnegated bytes smaller than the last publication, a $aggregatesizediffpc % difference).\n"
elif [ $aggregatesizediff -eq 0 ]; then
    msg+="-> The main aggregate contains $entitycounttotal entities and is $currentaggregatesizemb MB (exactly the same size as the last publication).\n"
else
    msg+="-> The main aggregate contains $entitycounttotal entities and is $currentaggregatesizemb MB ($aggregatesizediff bytes bigger than the last publication, a $aggregatesizediffpc % difference).\n"
fi

# Finally all commits
if [ $gitlognumentries -eq 0 ]; then
    msg+="There have been no commits since last publication; all changes are from imported entities only.\n"
elif [ $gitlognumentries -eq 1  ]; then
    msg+="There has been $gitlognumentries commit since the last publication:\n"
    msg+="\`\`\`$gitlog\`\`\`"
else
    msg+="There have been $gitlognumentries commits since the last publication:\n"
    msg+="\`\`\`$gitlog\`\`\`"
fi  

echo -e "$msg"
exit 0
