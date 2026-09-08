#!/usr/bin/sh

set -e

./make-keys.sh

rm -rf softhsm/*
source ./setup-softhsm.sh

echo Aggregate and Sign...
mda.sh aggregate-and-sign.xml main
xmlsectool.sh --verifySignature \
    --inFile path/to/output/aggregate-signed.xml \
    --certificate path/to/secrets/self-signed.pem

echo Filter Aggregate...
mda.sh filter-aggregate.xml main

echo Aggregate and Republish...
mda.sh aggregate-and-republish.xml main
xmlsectool.sh --verifySignature \
    --inFile path/to/output/all-metadata.xml \
    --certificate path/to/secrets/self-signed.pem
xmlsectool.sh --verifySignature \
    --inFile path/to/output/idp-metadata.xml \
    --certificate path/to/secrets/self-signed.pem
xmlsectool.sh --verifySignature \
    --inFile path/to/output/sp-metadata.xml \
    --certificate path/to/secrets/self-signed.pem

echo Sign Using Token...
mda.sh sign-using-token.xml main
xmlsectool.sh --verifySignature \
    --inFile path/to/output/signed-with-token.xml \
    --certificate path/to/secrets/self-signed.pem

echo Per-entity metadata...
mda.sh per-entity.xml main
for file in path/to/output/_*.xml; do
    xmlsectool.sh --verifySignature \
        --inFile $file \
        --certificate path/to/secrets/self-signed.pem
done

echo Discovery feed...
mda.sh discofeed.xml main
