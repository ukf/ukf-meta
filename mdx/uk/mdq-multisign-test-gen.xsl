<?xml version="1.0" encoding="UTF-8"?>
<!--
    mdq-multisign-test-gen.xsl

    XSL stylesheet to produce the test data for the mdq-multisign pipeline, which
    generates signed per-entity metadata.

    This works by filtering the unsigned production aggregate (which is used as
    input to the per-entity signing process in production) and removing all
    but a curated selection of entities, chosen to be representative.

    Note that the resulting test file will contain large numbers of blank lines,
    because the newline _after_ each entity in the input aggregate is not
    part of the element being stripped out. This is fine.
-->
<xsl:stylesheet version="1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"

    xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xsi xsl">

    <!--Force UTF-8 encoding for the output.-->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        Filter out entities we don't want.

        Use De Morgan here:

            (NOT entity-a) AND (NOT entity-b)

        is the same as

            NOT (entity-a OR entity-b)

        We negate this again by filtering out _matching_
        entities, so we are left with:

            entity-a OR entity-b

        The selection process won't notice if you mistype an
        entityID, or if the entity in question is removed from
        the UK federation aggregate; it will simply no longer
        appear in the test data.
    -->
    <xsl:template match="//md:EntityDescriptor
            [@entityID!='https://idp2.iay.org.uk/idp/shibboleth']
            [@entityID!='https://test.ukfederation.org.uk/entity']
            [@entityID!='https://test-idp.ukfederation.org.uk/idp/shibboleth']
            [@entityID!='https://terena.org/sp']
        ">
        <!-- do nothing, we're filtering these out -->
    </xsl:template>

    <!--
        *********************************************
        ***                                       ***
        ***   D E F A U L T   T E M P L A T E S   ***
        ***                                       ***
        *********************************************
    -->

    <!--By default, copy text blocks, comments and attributes unchanged.-->
    <xsl:template match="text()|comment()|@*">
        <xsl:copy/>
    </xsl:template>

    <!--By default, copy all elements from the input to the output, along with their attributes and contents.-->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
