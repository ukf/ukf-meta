<?xml version="1.0" encoding="UTF-8"?>
<!--

    statistics-charting.xsl

    XSL stylesheet taking a UK Federation metadata file and resulting in an HTML document
    giving statistics.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:init="urn:oasis:names:tc:SAML:profiles:SSO:request-init"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:members="http://ukfederation.org.uk/2007/01/members"
    xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
    xmlns:math="http://exslt.org/math"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:dyn="http://exslt.org/dynamic"
    xmlns:set="http://exslt.org/sets"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    exclude-result-prefixes="xsl alg ds init md mdattr mdui saml xsi members ukfedlabel math date dyn set idpdisc"
    version="1.0">

    <xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>

    <!--
        memberDocument

        The members.xml file, as a DOM document, is passed as a parameter.
    -->
    <xsl:param name="memberDocument"/>

    <xsl:template match="md:EntitiesDescriptor">

        <!--
            Break down the "members" document.
        -->
        <!-- federation members -->
        <xsl:variable name="members" select="$memberDocument//members:Member"/>
        <xsl:variable name="memberCount" select="count($members)"/>
        <xsl:variable name="memberNames" select="$members/members:Name"/>

        <xsl:variable name="entities" select="//md:EntityDescriptor"/>
        <xsl:variable name="entityCount" select="count($entities)"/>

        <xsl:variable name="idps" select="$entities[md:IDPSSODescriptor]"/>
        <xsl:variable name="idps.saml1"
            select="$idps[contains(md:IDPSSODescriptor/@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:1.1:protocol')]"/>

        <xsl:variable name="idpCount" select="count($idps)"/>
        <xsl:variable name="idps.saml1.count" select="count($idps.saml1)"/>

        <xsl:variable name="sps" select="$entities[md:SPSSODescriptor]"/>
        <xsl:variable name="sps.saml1"
            select="$sps[contains(md:SPSSODescriptor/@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:1.1:protocol')]"/>

        <xsl:variable name="spCount" select="count($sps)"/>
        <xsl:variable name="sps.saml1.count" select="count($sps.saml1)"/>

        <xsl:variable name="entities.saml1" select="set:distinct($idps.saml1 | $sps.saml1)"/>
        <xsl:variable name="entities.saml1.count" select="count($entities.saml1)"/>

        <xsl:variable name="dualEntities" select="$entities[md:IDPSSODescriptor][md:SPSSODescriptor]"/>
        <xsl:variable name="dualEntityCount" select="count($dualEntities)"/>

        <xsl:variable name="federationMemberEntityCount"
            select="count($entities[md:Extensions/ukfedlabel:UKFederationMember])"/>

        <xsl:variable name="memberEntities"
            select="dyn:closure($members/members:Name, '$entities[md:Organization/md:OrganizationName = current()]')"/>
        <xsl:variable name="memberEntityCount"
            select="dyn:sum($memberNames, 'count($entities[md:Organization/md:OrganizationName = current()])')"/>

        <xsl:variable name="idps.artifact"
            select="$idps[md:IDPSSODescriptor[md:ArtifactResolutionService]]"/>
        <xsl:variable name="idps.artifact.count" select="count($idps.artifact)"/>
        <xsl:variable name="idps.artifact.saml1"
            select="$idps[md:IDPSSODescriptor
            [contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:1.1:protocol')]
            [md:ArtifactResolutionService]]"/>
        <xsl:variable name="idps.artifact.saml1.count" select="count($idps.artifact.saml1)"/>
        <xsl:variable name="sps.artifact.saml1"
            select="$sps[md:SPSSODescriptor/md:AssertionConsumerService/@Binding='urn:oasis:names:tc:SAML:1.0:profiles:artifact-01']"/>
        <xsl:variable name="sps.artifact.saml1.count" select="count($sps.artifact.saml1)"/>
        <xsl:variable name="entities.artifact.saml1" select="set:distinct($idps.artifact.saml1 | $sps.artifact.saml1)"/>
        <xsl:variable name="entities.artifact.saml1.count" select="count($entities.artifact.saml1)"/>

        <pre>

            <!--
                ***************************
                ***                     ***
                ***   C H A R T I N G   ***
                ***                     ***
                ***************************
            -->
            <xsl:text>&#10;</xsl:text>

            <xsl:text>Members: </xsl:text>
            <xsl:value-of select="$memberCount"/>
            <xsl:text>&#10;</xsl:text>

            <xsl:text>Entities: </xsl:text>
            <xsl:value-of select="$entityCount"/>
            <xsl:text>&#10;</xsl:text>

            <xsl:text>   IdPs: </xsl:text>
            <xsl:value-of select="$idpCount"/>
            <xsl:text>&#10;</xsl:text>

            <xsl:text>   SPs: </xsl:text>
            <xsl:value-of select="$spCount"/>
            <xsl:text>&#10;</xsl:text>

            <xsl:text>Entities per member: </xsl:text>
            <xsl:value-of select="format-number($entityCount div $memberCount, '0.000000')"/>
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="charting.entities.algsupport" select="$entities[descendant::alg:* or descendant::md:EncryptionMethod]"/>
            <xsl:variable name="charting.entities.algsupport.count" select="count($charting.entities.algsupport)"/>
            <xsl:text>Algorithm support: </xsl:text>
            <xsl:value-of select="format-number($charting.entities.algsupport.count div $entityCount, '0.00%')"/>
            <xsl:text> of all entities</xsl:text>
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="charting.entities.algsupport.gcm"
                select="$charting.entities.algsupport[
                descendant::md:EncryptionMethod/@Algorithm='http://www.w3.org/2009/xmlenc11#aes128-gcm' or
                descendant::md:EncryptionMethod/@Algorithm='http://www.w3.org/2009/xmlenc11#aes192-gcm' or
                descendant::md:EncryptionMethod/@Algorithm='http://www.w3.org/2009/xmlenc11#aes256-gcm']"/>
            <xsl:variable name="charting.entities.algsupport.gcm.count" select="count($charting.entities.algsupport.gcm)"/>
            <xsl:text>GCM support: </xsl:text>
            <xsl:value-of select="format-number($charting.entities.algsupport.gcm.count div $entityCount, '0.00%')"/>
            <xsl:text> of all entities</xsl:text>
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="charting.sps.algsupport" select="$sps[descendant::alg:* or descendant::md:EncryptionMethod]"/>
            <xsl:variable name="charting.sps.algsupport.count" select="count($charting.sps.algsupport)"/>
            <xsl:text>Algorithm support: </xsl:text>
            <xsl:value-of select="format-number($charting.sps.algsupport.count div $spCount, '0.00%')"/>
            <xsl:text> of SP entities</xsl:text>
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="charting.sps.algsupport.gcm"
                select="$charting.sps.algsupport[
                descendant::md:EncryptionMethod/@Algorithm='http://www.w3.org/2009/xmlenc11#aes128-gcm' or
                descendant::md:EncryptionMethod/@Algorithm='http://www.w3.org/2009/xmlenc11#aes192-gcm' or
                descendant::md:EncryptionMethod/@Algorithm='http://www.w3.org/2009/xmlenc11#aes256-gcm']"/>
            <xsl:variable name="charting.sps.algsupport.gcm.count" select="count($charting.sps.algsupport.gcm)"/>
            <xsl:text>GCM support: </xsl:text>
            <xsl:value-of select="format-number($charting.sps.algsupport.gcm.count div $spCount, '0.00%')"/>
            <xsl:text> of SP entities</xsl:text>
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="charting.idp4" select="$idps[
                md:Extensions/ukfedlabel:Software[@name='Shibboleth'][@version = '4']
                ]"/>
            <xsl:variable name="charting.idp4.count" select="count($charting.idp4)"/>
            <xsl:text>Shibboleth IdP v4: </xsl:text>
            <xsl:value-of select="$charting.idp4.count"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="format-number($charting.idp4.count div $idpCount, '0.0%')"/>
            <xsl:text> of IdPs)</xsl:text>
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="charting.idp3" select="$idps[
                md:Extensions/ukfedlabel:Software[@name='Shibboleth'][@version = '3']
                ]"/>
            <xsl:variable name="charting.idp3.count" select="count($charting.idp3)"/>
            <xsl:text>Shibboleth IdP v3: </xsl:text>
            <xsl:value-of select="$charting.idp3.count"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="format-number($charting.idp3.count div $idpCount, '0.0%')"/>
            <xsl:text> of IdPs)</xsl:text>
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="nosaml2.sps" select="$sps[md:SPSSODescriptor[not(contains(@protocolSupportEnumeration,
                'urn:oasis:names:tc:SAML:2.0:protocol'))]]"/>
            <xsl:variable name="nosaml2.sps.count" select="count($nosaml2.sps)"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>SPs without SAML 2.0 support: </xsl:text>
            <xsl:value-of select="$nosaml2.sps.count"/>
            <xsl:text>&#10;</xsl:text>

            <xsl:for-each select="$nosaml2.sps">
                <xsl:sort select="descendant::md:OrganizationName"/>
                <xsl:text>   </xsl:text>
                <xsl:value-of select="@ID"/>
                <xsl:text>: </xsl:text>
                <xsl:value-of select="descendant::md:OrganizationName"/>
                <xsl:text>: </xsl:text>
                <xsl:choose>
                    <xsl:when test="descendant::mdui:DisplayName">
                        <xsl:value-of select="descendant::mdui:DisplayName"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>(</xsl:text>
                        <xsl:value-of select="descendant::md:OrganizationDisplayName"/>
                        <xsl:text>)</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="md:Extensions/ukfedlabel:Software" mode="short"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>

            <xsl:call-template name="entity.breakdown.by.software">
                <xsl:with-param name="entities" select="$sps[md:SPSSODescriptor[not(contains(@protocolSupportEnumeration,
                    'urn:oasis:names:tc:SAML:2.0:protocol'))]]"/>
            </xsl:call-template>

            <xsl:variable name="nosaml2.idps" select="$idps[md:IDPSSODescriptor[not(contains(@protocolSupportEnumeration,
                'urn:oasis:names:tc:SAML:2.0:protocol'))]]"/>
            <xsl:variable name="nosaml2.idps.count" select="count($nosaml2.idps)"/>

            <xsl:text>&#10;</xsl:text>
            <xsl:text>IdPs without SAML 2.0 support: </xsl:text>
            <xsl:value-of select="$nosaml2.idps.count"/>
            <xsl:text>&#10;</xsl:text>

            <xsl:call-template name="entity.breakdown.by.software">
                <xsl:with-param name="entities" select="$nosaml2.idps"/>
            </xsl:call-template>

            <!-- MDUI statistics -->
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="entities.mdui" select="$entities[descendant::mdui:UIInfo]"/>
            <xsl:variable name="entities.mdui.count" select="count($entities.mdui)"/>
            <xsl:text>Entities with mdui:UIInfo: </xsl:text>
            <xsl:value-of select="$entities.mdui.count"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="format-number($entities.mdui.count div $entityCount, '0.0%')"/>
            <xsl:text>)</xsl:text>
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="idps.mdui" select="$idps[descendant::mdui:UIInfo]"/>
            <xsl:variable name="idps.mdui.count" select="count($idps.mdui)"/>
            <xsl:text>IdPs with mdui:UIInfo: </xsl:text>
            <xsl:value-of select="$idps.mdui.count"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="format-number($idps.mdui.count div $idpCount, '0.0%')"/>
            <xsl:text>)</xsl:text>
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="sps.mdui" select="$sps[descendant::mdui:UIInfo]"/>
            <xsl:variable name="sps.mdui.count" select="count($sps.mdui)"/>
            <xsl:text>SPs with mdui:UIInfo: </xsl:text>
            <xsl:value-of select="$sps.mdui.count"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="format-number($sps.mdui.count div $spCount, '0.0%')"/>
            <xsl:text>)</xsl:text>
            <xsl:text>&#10;</xsl:text>

            <xsl:text>&#10;</xsl:text>
        </pre>
    </xsl:template>


    <!--
        Break down a set of entities by the software used.
    -->
    <xsl:template name="entity.breakdown.by.software">
        <xsl:param name="entities"/>
        <xsl:variable name="entityCount" select="count($entities)"/>
        <xsl:text>Breakdown by software used:</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <!--
            *********************************************************************
            ***                                                               ***
            ***   C L A S S I F Y   E N T I T I E S   B Y   S O F T W A R E   ***
            ***                                                               ***
            *********************************************************************

            The classification algorithms used here are chained together so that
            each classification step works only on those entities not already
            classified.  This means that entities won't be counted twice, but
            means that the order of classification blocks is important and
            shouldn't be changed without careful thought.  In general, more
            specific algorithms should appear before more general ones.
        -->

        <!--
            Classify miscellaneous entities.

            Here we pull off a list of entities labelled with explicit
            Software labels that aren't for the software we address
            in more detail below.  The result is, as it were, a list of
            "known unknowns" that we can re-integrate later with those
            entities we fail to classify altogether.
        -->
        <xsl:variable name="entities.misc.in" select="$entities"/>
        <xsl:variable name="entities.misc"
            select="$entities.misc.in[
                md:Extensions/ukfedlabel:Software
                    [@name != 'Shibboleth']
                    [@name != 'EZproxy']
                    [@name != 'OpenAthens']
                    [@name != 'Guanxi']
                    [@name != 'simpleSAMLphp']
                    [@name != 'Atypon SAML SP 1.1/2.0']
                    [@name != 'AthensIM']
                    [@name != 'Eduserv Gateway']
            ]"/>
        <xsl:variable name="entities.misc.out"
            select="set:difference($entities.misc.in, $entities.misc)"/>

        <!--
            Classify EZproxy SPs
        -->
        <xsl:variable name="entities.ezproxy.in" select="$entities.misc.out"/>
        <xsl:variable name="entities.ezproxy"
            select="$entities.ezproxy.in[md:Extensions/ukfedlabel:Software/@name='EZproxy']"/>
        <xsl:variable name="entities.ezproxy.out"
            select="set:difference($entities.ezproxy.in, $entities.ezproxy)"/>

        <!--
            Classify simpleSAMLphp entities.
        -->
        <xsl:variable name="entities.simplesamlphp.in" select="$entities.ezproxy.out"/>
        <xsl:variable name="entities.simplesamlphp"
            select="$entities.simplesamlphp.in[md:Extensions/ukfedlabel:Software/@name='simpleSAMLphp']"/>
        <xsl:variable name="entities.simplesamlphp.out"
            select="set:difference($entities.simplesamlphp.in, $entities.simplesamlphp)"/>

        <!--
            Classify Atypon SAML SP entities.
        -->
        <xsl:variable name="entities.atyponsamlsp.in" select="$entities.simplesamlphp.out"/>
        <xsl:variable name="entities.atyponsamlsp"
            select="$entities.atyponsamlsp.in[md:Extensions/ukfedlabel:Software/@name='Atypon SAML SP 1.1/2.0']"/>
        <xsl:variable name="entities.atyponsamlsp.out"
            select="set:difference($entities.atyponsamlsp.in, $entities.atyponsamlsp)"/>

        <!--
            Classify OpenAthens entities.
        -->
        <xsl:variable name="entities.openathens.in" select="$entities.atyponsamlsp.out"/>
        <xsl:variable name="entities.openathens"
            select="$entities.openathens.in[md:Extensions/ukfedlabel:Software/@name='OpenAthens']"/>
        <xsl:variable name="entities.openathens.out"
            select="set:difference($entities.openathens.in, $entities.openathens)"/>

        <!--
            Classify Shibboleth 4 entities.
        -->
        <xsl:variable name="entities.shib.4.in" select="$entities.openathens.out"/>
        <xsl:variable name="entities.shib.4"
            select="$entities.shib.4.in[
            md:Extensions/ukfedlabel:Software[@name='Shibboleth'][@version = '4']
            ]"/>
        <xsl:variable name="entities.shib.4.out"
            select="set:difference($entities.shib.4.in, $entities.shib.4)"/>

        <!--
            Classify Shibboleth 3 entities.
        -->
        <xsl:variable name="entities.shib.3.in" select="$entities.shib.4.out"/>
        <xsl:variable name="entities.shib.3"
            select="$entities.shib.3.in[
            md:Extensions/ukfedlabel:Software[@name='Shibboleth'][@version = '3']
            ]"/>
        <xsl:variable name="entities.shib.3.out"
            select="set:difference($entities.shib.3.in, $entities.shib.3)"/>

        <!--
            Classify Shibboleth 2.0 IdPs and SPs.
        -->
        <xsl:variable name="entities.shib.2.in" select="$entities.shib.3.out"/>
        <xsl:variable name="entities.shib.2"
            select="$entities.shib.2.in[
                md:IDPSSODescriptor/md:SingleSignOnService[contains(@Location, '/profile/Shibboleth/SSO')] |
                md:SPSSODescriptor/md:AssertionConsumerService[contains(@Location, '/Shibboleth.sso/SAML2/POST')] |
                md:Extensions/ukfedlabel:Software[@name='Shibboleth'][@version = '2']
            ]"/>
        <xsl:variable name="entities.shib.2.out"
            select="set:difference($entities.shib.2.in, $entities.shib.2)"/>

        <!--
            Classify Athens Gateway entities
        -->
        <xsl:variable name="entities.gateways.in" select="$entities.shib.2.out"/>
        <xsl:variable name="entities.gateways"
            select="$entities.gateways.in[md:Extensions/ukfedlabel:Software/@name='Eduserv Gateway']"/>
        <xsl:variable name="entities.gateways.out"
            select="set:difference($entities.gateways.in, $entities.gateways)"/>

        <!--
            Classify OpenAthens virtual IdPs.
        -->
        <xsl:variable name="entities.openathens.virtual.in" select="$entities.gateways.out"/>
        <xsl:variable name="entities.openathens.virtual"
            select="$entities.openathens.virtual.in[
                descendant::md:AttributeService/@Location=
                    'https://gateway.athensams.net:5057/services/SAML11AttributeAuthority' or
                descendant::md:SingleSignOnService[starts-with(@Location,
                    'https://login.openathens.net/saml/')]
                ]"/>
        <xsl:variable name="entities.openathens.virtual.out"
            select="set:difference($entities.openathens.virtual.in, $entities.openathens.virtual)"/>

        <!--
            Classify Guanxi entities.
        -->
        <xsl:variable name="entities.guanxi.in" select="$entities.openathens.virtual.out"/>
        <xsl:variable name="entities.guanxi"
            select="$entities.guanxi.in[md:Extensions/ukfedlabel:Software/@name='Guanxi']"/>
        <xsl:variable name="entities.guanxi.out"
            select="set:difference($entities.guanxi.in, $entities.guanxi)"/>

        <!--
            Classify AthensIM entities.
        -->
        <xsl:variable name="entities.athensim.in" select="$entities.guanxi.out"/>
        <xsl:variable name="entities.athensim"
            select="$entities.athensim.in[md:Extensions/ukfedlabel:Software/@name='AthensIM']"/>
        <xsl:variable name="entities.athensim.out"
            select="set:difference($entities.athensim.in, $entities.athensim)"/>

        <!--
            Remaining entities are unknown.
        -->
        <xsl:variable name="entities.unclassified" select="$entities.athensim.out"/>
        <xsl:variable name="unknownSoftwareEntities"
            select="$entities.unclassified | $entities.misc"/>

        <!--
            ***************************************************************
            ***                                                         ***
            ***   R E P O R T   C L A S S I F I E D   E N T I T I E S   ***
            ***                                                         ***
            ***************************************************************
        -->

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.shib.4"/>
            <xsl:with-param name="name">Shibboleth 4.x</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.shib.3"/>
            <xsl:with-param name="name">Shibboleth 3.x</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.shib.2"/>
            <xsl:with-param name="name">Shibboleth 2.x</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:variable name="entities.shib" select="$entities.shib.2 | $entities.shib.3"/>
        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.shib"/>
            <xsl:with-param name="name">Shibboleth combined</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:variable name="entities.not.shib" select="set:difference($entities, $entities.shib)"/>
        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.not.shib"/>
            <xsl:with-param name="name">Other than Shibboleth</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.ezproxy"/>
            <xsl:with-param name="name">EZproxy</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.simplesamlphp"/>
            <xsl:with-param name="name">simpleSAMLphp</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.atyponsamlsp"/>
            <xsl:with-param name="name">Atypon SAML SP</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.athensim"/>
            <xsl:with-param name="name">AthensIM</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.guanxi"/>
            <xsl:with-param name="name">Guanxi</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.gateways"/>
            <xsl:with-param name="name">Athens/Shibboleth gateway</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.openathens.virtual"/>
            <xsl:with-param name="name">OpenAthens Virtual IdP</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$entities.openathens"/>
            <xsl:with-param name="name">OpenAthens</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
        </xsl:call-template>

        <xsl:call-template name="entity.breakdown.by.software.line">
            <xsl:with-param name="entities" select="$unknownSoftwareEntities"/>
            <xsl:with-param name="name">Unknown or other</xsl:with-param>
            <xsl:with-param name="total" select="$entityCount"/>
            <xsl:with-param name="show" select="1"/>
            <xsl:with-param name="show.software" select="1"/>
        </xsl:call-template>

    </xsl:template>

    <xsl:template name="entity.breakdown.by.software.line">
        <xsl:param name="entities"/>
        <xsl:param name="name"/>
        <xsl:param name="total"/>
        <xsl:param name="show">0</xsl:param>
        <xsl:param name="show.software">0</xsl:param>
        <xsl:param name="show.max">8</xsl:param>
        <xsl:variable name="n" select="count($entities)"/>
        <xsl:if test="$n != 0">
            <xsl:text>   </xsl:text>
            <xsl:value-of select="$name"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$n"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="format-number($n div $total, '0.0%')"/>
            <xsl:text>)</xsl:text>
            <xsl:text>&#10;</xsl:text>
             <xsl:if test="($show != 0) or ($n &lt;= $show.max)">
                <xsl:for-each select="$entities">
                    <xsl:sort select="@ID"/>
                    <xsl:text>      </xsl:text>
                    <xsl:value-of select="@ID"/>
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="@entityID"/>
                    <xsl:if test="$show.software != 0">
                        <xsl:choose>
                            <xsl:when test="md:Extensions/ukfedlabel:Software">
                                (<xsl:value-of select="md:Extensions/ukfedlabel:Software/@name"/>)
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:text>&#10;</xsl:text>
                </xsl:for-each>
            </xsl:if>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
