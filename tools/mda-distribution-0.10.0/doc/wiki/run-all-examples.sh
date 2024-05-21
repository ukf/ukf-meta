#!/usr/bin/sh

set -e

./make-keys.sh

rm -rf softhsm/*
source ./setup-softhsm.sh

echo Aggregate and Sign...
mda.sh aggregate-and-sign.xml main
echo Filter Aggregate...
mda.sh filter-aggregate.xml main
echo Aggregate and Republish...
mda.sh aggregate-and-republish.xml main
echo Sign Using Token...
mda.sh sign-using-token.xml main
echo Per-entity metadata...
mda.sh per-entity.xml main
echo Discovery feed...
mda.sh discofeed.xml main
