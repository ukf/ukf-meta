#!/bin/bash

# This script will output details about the current UKf publication and 
# the differences since the last.
#
# Expects the following to be provided as arguments:
# * Absolute path to shared workspace directory
# * Git project's group name
# * Git data repository's name
# * Git products repository's name
#
# Assumes the data repository's master branch is currently checked out.
#

# Fail if $1, $2, $3, and $4 aren't provided.
if [[ -z $1 && -z $2 && -z $3 && -z $4 ]]; then
    echo "usage: diff-between-publications.sh <path to shared workspace> <git group name> <git data repository name> <git products repository name>"
    exit 1
fi

# Get the input
sharedwsdir=$1
repogroup=$2
repodata=$3
repoproducts=$4

# =====
# = First of all, we need to calculate some stuff.
# =====

# Figure out name of the latest tag and the previous tag.
# These point to the latest, and previous, publication.
currenttag=$(git --work-tree=$sharedwsdir/$repoproducts --git-dir=$sharedwsdir/$repoproducts/.git tag | tail -n 1)
previoustag=$(git --work-tree=$sharedwsdir/$repoproducts --git-dir=$sharedwsdir/$repoproducts/.git tag | tail -n 2 | head -n 1)

# Calculate current member count (the final awk is for Mac compatibility, since wc on Mac outputs leading spaces)
membercount=$(grep 'Member ID' $sharedwsdir/$repodata/members/members.xml | wc -l | awk '{print $1}')

# Calculate current entities count (UK only)
entitycountuk=$(grep 'registrationAuthority="http://ukfederation.org.uk"' $sharedwsdir/$repoproducts/aggregates/ukfederation-metadata.xml | wc -l | awk '{print $1}')

# Calculate current entities count (total, including all imported entities)
entitycounttotal=$(grep '<EntityDescriptor' $sharedwsdir/$repoproducts/aggregates/ukfederation-metadata.xml | wc -l | awk '{print $1}')

# Calculate size of current aggregate, in bytes and MB
currentaggregatesize=$(cat $sharedwsdir/$repoproducts/aggregates/ukfederation-metadata.xml | wc -c)
currentaggregatesizemb=$(echo "scale=2;$currentaggregatesize/1024/1024" | bc )

# Calculate size of previous aggregate
previousaggregatesize=$(git --work-tree=$sharedwsdir/$repoproducts --git-dir=$sharedwsdir/$repoproducts/.git show $previoustag:aggregates/ukfederation-metadata.xml | wc -c)
previousaggregatesizemb=$(echo "scale=2;$previousaggregatesize/1024/1024" | bc )

# Calculate difference in size between current and previous in both absolute and percentage terms
aggregatesizediff=$((currentaggregatesize-previousaggregatesize))
aggregatesizediffpc=$(echo "scale=5;$aggregatesizediff/$previousaggregatesize" | bc | awk '{printf "%.5f\n", $0}')

# Calculate git log between the current and previous aggregation, by
# -> First, calculate date/time of latest publication (epoch) in products repo
# -> Next, calculate date/time of previous publication (epoch) in products repo
# -> Finally, get a git log between those two dates (epoch) in data repo
currenttagdate=$(git --work-tree=$sharedwsdir/$repoproducts --git-dir=$sharedwsdir/$repoproducts/.git log -1 $currenttag --format=%ct)
previoustagdate=$(git --work-tree=$sharedwsdir/$repoproducts --git-dir=$sharedwsdir/$repoproducts/.git log -1 $previoustag --format=%ct)
gitlog=$(git --work-tree=$sharedwsdir/$repodata --git-dir=$sharedwsdir/$repodata/.git log --format="<https://repo.infr.ukfederation.org.uk/$repogroup/$repodata/commit/%h|%h %an %s>" --after=$previoustagdate --before=$currenttagdate)
gitlognumentries=$(git --work-tree=$sharedwsdir/$repodata --git-dir=$sharedwsdir/$repodata/.git log --format="%h" --after=$previoustagdate --before=$currenttagdate | wc -l | awk '{print $1}')

# =====
# = Now we're ready to output the message
# =====

# First part of the message is just a canned success message with a timestamp 
msg="$(date) - Successfully published UKf metadata.\n"

# Second part is some stats about the UK fed
msg+="> The UK federation now has $membercount members and $entitycountuk entities.\n"

# Third part is stats about the aggregate, and some diff info
if [ $aggregatesizediff -lt 0 ]; then
    aggregatesizediffnegated=$(( $aggregatesizediff * -1 ))
    msg+="> The main aggregate contains $entitycounttotal entities and is $currentaggregatesizemb MB ($aggregatesizediffnegated bytes smaller than in the last publication, a $aggregatesizediffpc % difference).\n"
elif [ $aggregatesizediff -eq 0 ]; then
    msg+="> The main aggregate contains $entitycounttotal entities and is $currentaggregatesizemb MB (exactly the same size as in the last publication).\n"
else
    msg+="> The main aggregate contains $entitycounttotal entities and is $currentaggregatesizemb MB ($aggregatesizediff bytes bigger than in the last publication, a $aggregatesizediffpc % difference).\n"
fi

# Finally all commits
if [ $gitlognumentries -eq 0 ]; then
    msg+="There have been no commits since last publication; any changes are from imported entities only.\n"
elif [ $gitlognumentries -eq 1  ]; then
    msg+="There has been $gitlognumentries commit since last publication:\n"
    msg+="\`\`\`\n$gitlog\n\`\`\`"
else
    msg+="There have been $gitlognumentries commits since last publication:\n"
    msg+="\`\`\`\n$gitlog\n\`\`\`"
fi  

echo -e "$msg"
exit 0
