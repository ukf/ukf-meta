<?xml version="1.0" encoding="UTF-8"?>
<!--
    
    statistics.xsl
    
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

    <xsl:output method="html" omit-xml-declaration="yes"/>
    
    <!--
        memberDocument
        
        The members.xml file, as a DOM document, is passed as a parameter.
    -->
    <xsl:param name="memberDocument"/>
    
    <xsl:template match="md:EntitiesDescriptor">
        
        <xsl:variable name="now" select="date:date-time()"/>

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
        
        <html>
            <head>
                <title>UK Federation metadata statistics</title>
            </head>
            <body>
                <h1>UK Federation metadata statistics</h1>
                <p>
                    This document contains up-to-date information on the metadata for the entities
                    (identity providers and service providers) registered by the UK Access Management
                    Federation for Education and Research. Note that the UK federation also
                    republishes metadata from other registrars and acquired through the eduGAIN
                    system; such "imported" metadata is not taken into account here.
                </p>
                <p>
                    The document is regenerated each time the UK Federation metadata is built;
                    this version was created at <xsl:value-of select="$now"/>.
                </p>
                <p>This document is produced as a working document of the UK federation core team. 
                   Some of the statistics may be approximations, and the report may be used to track
                   details of current team interest. 
                   For this reason it may be liable to misinterpetation, and should not be considered
                   complete or authoritative.
                </p>
                <p>Contents:</p>
                <ul>
                    <li><p><a href="#members">Member Statistics</a></p></li>
                    <li><p><a href="#entities">Entity Statistics</a></p></li>
                    <li><p><a href="#byOwner">Entities by Owner</a></p></li>
                    <li><p><a href="#accountableIdPs">Identity Provider Accountability</a></p></li>
                    <li><p><a href="#membersByScope">Members by Primary Scope</a></p></li>
                    <li><p><a href="#undeployedMembers">Members Lacking Deployment</a></p></li>
                    <li><p><a href="#shib13">Shibboleth 1.3 Remnants</a></p></li>
                    <li><p><a href="#exportOptOut">Export Aggregate: Entities Opted Out</a></p></li>
                    <li><p><a href="#exportOptIn">Export Aggregate: Entities Explicitly Opted In</a></p></li>
                    <li><p><a href="#nosaml2">Entities Without SAML 2.0 Support</a></p></li>
                </ul>
                

                
                <h2><a name="members">Member Statistics</a></h2>
                <p>Number of members: <xsl:value-of select="$memberCount"/></p>
                <p>The following table shows the canonical name of each member organisation and 
                   the number of entities belonging to that member.
                   The canonical name for a member is derived from the member's legal name. 
                   Ownership  of an entity is established by the OrganizationName field of an entity exactly 
                   matching the canonical name of the member organisation. 
                </p>
                <p>
                   Many organisations have no entities in the federation. 
                   This may be because they have not yet registered any; perhaps because they have only recently joined. 
                   Alternatively, they may have outsourced their identity provision.
                   Outsourcing of IdP provision is indicated by an asterisk in the OSrc column in the table.
                   This indicates either outsourcing to an Eduserv virtual IdP or a member who "pushes" scopes
                   to an aggregate IdP.
                   Other IdP outsourcing, and any SP outsourcing, is not recorded in the table.
                </p>
                <p>
                    The final column in the table, Primary Scope, records a scope (or security domain)
                    owned by the member and designated as its main (or only) scope. 
                    ('Primary Scope' is a useful concept, but is not precisely defined. 
                    It is only recorded if the member in question owns an IdP or outsources its IdP provision - 
                    and perhaps not even then, as it it sometimes unclear which of the scopes 
                    it owns should be designated as 'primary'.) 
                </p>
                <table border="1" cellspacing="2" cellpadding="4">
                    <tr>
                        <th align="left">Member</th>
                        <th>Entities</th>
                        <th>IdPs</th>
                        <th>SPs</th>
                        <th>OSrc</th>
                        <th align="left">Primary Scope</th>
                    </tr>
                    <xsl:apply-templates select="$members" mode="count">
                        <xsl:with-param name="entities" select="$entities"/>
                    </xsl:apply-templates>
                </table>

                <!--
                    Break down members by whether or not they have entities registered
                -->
                <xsl:variable name="membersWithIdPs"
                    select="$members[members:Name = $idps//md:OrganizationName]"/>
                <xsl:variable name="membersWithSps"
                    select="$members[members:Name = $sps//md:OrganizationName]"/>
                <xsl:variable name="membersWithBoth"
                    select="set:intersection($membersWithIdPs, $membersWithSps)"/>
                <xsl:variable name="membersWithEither"
                    select="set:distinct($membersWithIdPs | $membersWithSps)"/>
                <xsl:variable name="membersWithJustIdPs"
                    select="set:difference($membersWithIdPs, $membersWithSps)"/>
                <xsl:variable name="membersWithJustSPs"
                    select="set:difference($membersWithSps, $membersWithIdPs)"/>
                <xsl:variable name="membersWithNone"
                    select="set:difference($members, $membersWithEither)"/>
                <xsl:variable name="membersWithAthensIdP"
                    select="$members[@usesAthensIdP = 'true']"/>
                <xsl:variable name="membersWithJustAthensIdP"
                    select="set:difference($membersWithAthensIdP, $membersWithEither)"/>
                <xsl:variable name="membersWithNoneNoAthens"
                    select="set:difference($membersWithNone, $membersWithAthensIdP)"/>
                <xsl:variable name="membersWithIdPsCount" select="count($membersWithIdPs)"/>
                <xsl:variable name="membersWithSpsCount" select="count($membersWithSps)"/>
                <xsl:variable name="membersWithBothCount" select="count($membersWithBoth)"/>
                <xsl:variable name="membersWithEitherCount" select="count($membersWithEither)"/>
                <xsl:variable name="membersWithJustIdPsCount" select="count($membersWithJustIdPs)"/>
                <xsl:variable name="membersWithJustSPsCount" select="count($membersWithJustSPs)"/>
                <xsl:variable name="membersWithNoneCount" select="count($membersWithNone)"/>
                <xsl:variable name="membersWithJustAthensIdPCount" select="count($membersWithJustAthensIdP)"/>
                <xsl:variable name="membersWithNoneNoAthensCount" select="count($membersWithNoneNoAthens)"/>
                <p>Breakdown of members by entity registration status:</p>
                <ul>
                    <li>
                        <p>
                            At least one IdP: <xsl:value-of select="$membersWithIdPsCount"/>
                            (<xsl:value-of select="format-number($membersWithIdPsCount div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            At least one SP: <xsl:value-of select="$membersWithSpsCount"/>
                            (<xsl:value-of select="format-number($membersWithSpsCount div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            At least one of either: <xsl:value-of select="$membersWithEitherCount"/>
                            (<xsl:value-of select="format-number($membersWithEitherCount div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            At least one of each: <xsl:value-of select="$membersWithBothCount"/>
                            (<xsl:value-of select="format-number($membersWithBothCount div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            At least one IdP, but no SPs: <xsl:value-of select="$membersWithJustIdPsCount"/>
                            (<xsl:value-of select="format-number($membersWithJustIdPsCount div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            At least one SP, but no IdPs: <xsl:value-of select="$membersWithJustSPsCount"/>
                            (<xsl:value-of select="format-number($membersWithJustSPsCount div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Without entities: <xsl:value-of select="$membersWithNoneCount"/>
                            (<xsl:value-of select="format-number($membersWithNoneCount div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Without entities, but with Athens IdP access: <xsl:value-of select="$membersWithJustAthensIdPCount"/>
                            (<xsl:value-of select="format-number($membersWithJustAthensIdPCount div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Without entities, and with no Athens IdP access: <xsl:value-of select="$membersWithNoneNoAthensCount"/>
                            (<xsl:value-of select="format-number($membersWithNoneNoAthensCount div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Chart:
                            <xsl:value-of select="$membersWithJustIdPsCount"/>,
                            <xsl:value-of select="$membersWithJustSPsCount"/>,
                            <xsl:value-of select="$membersWithBothCount"/>,
                            <xsl:value-of select="$membersWithJustAthensIdPCount"/>,
                            <xsl:value-of select="$membersWithNoneNoAthensCount"/>.                            
                        </p>
                    </li>
                </ul>
                
                <!--
                    *********************************
                    ***                           ***
                    ***   O U T S O U R C I N G   ***
                    ***                           ***
                    *********************************
                -->
                
                <!--
                    Members who are Eduserv.
                    
                    This is computed because Eduserv are an exception to the normal
                    rules about outsourcing because they do not outsource even though
                    they do use an Athens IdP.
                -->
                <xsl:variable name="members.eduserv"
                    select="$members[members:Name = 'Eduserv']"/>
                <xsl:variable name="members.eduserv.count" select="count($members.eduserv)"/>
                
                <!--
                    Members who are deduced as outsourcing as a result of their use
                    of an Athens IdP.
                -->
                <xsl:variable name="members.osrc.athens"
                    select="$members[@usesAthensIdP = 'true']"/>
                <xsl:variable name="members.osrc.athens.count" select="count($members.osrc.athens)"/>
                
                <!--
                    Members who are deduced as outsourcing as a result of their use
                    of an Athens IdP.  This count excludes Eduserv, as clearly they
                    can not outsource to themselves.
                -->
                <xsl:variable name="members.osrc.athens.true"
                    select="$members[@usesAthensIdP = 'true'][members:Name != 'Eduserv']"/>
                <xsl:variable name="members.osrc.athens.true.count" select="count($members.osrc.athens.true)"/>
                
                <!--
                    Members who are deduced as outsourcing as a result of their use
                    of the mechanism for describing scopes "pushed" to a specific entity.
                -->
                <xsl:variable name="members.osrc.scopes.push"
                    select="$members[members:Scopes/members:Entity]"/>
                <xsl:variable name="members.osrc.scopes.push.count" select="count($members.osrc.scopes.push)"/>
                
                <!--
                    Members who are deduced as outsourcing.
                -->
                <xsl:variable name="members.osrc"
                    select="set:distinct($members.osrc.athens.true | $members.osrc.scopes.push)"/>
                <xsl:variable name="members.osrc.count" select="count($members.osrc)"/>
                
                <!--
                    Members whose only representation in the federation is through outsourcing.
                -->
                <xsl:variable name="members.osrc.only"
                    select="set:difference($members.osrc, $membersWithEither)"/>
                <xsl:variable name="members.osrc.only.count" select="count($members.osrc.only)"/>
                
                <!--
                    Members with no representation, even through outsourcing.
                -->
                <xsl:variable name="members.osrc.none"
                    select="set:difference($membersWithNone, $members.osrc)"/>
                <xsl:variable name="members.osrc.none.count" select="count($members.osrc.none)"/>
                
                <p>Outsourcing worksheet:</p>
                <ul>
                    <li>
                        <p>
                            Members who are Eduserv: <xsl:value-of select="$members.eduserv.count"/>
                            (<xsl:value-of select="format-number($members.eduserv.count div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Members using an Athens IdP: <xsl:value-of select="$members.osrc.athens.count"/>
                            (<xsl:value-of select="format-number($members.osrc.athens.count div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Members (other than Eduserv) using an Athens IdP: <xsl:value-of select="$members.osrc.athens.true.count"/>
                            (<xsl:value-of select="format-number($members.osrc.athens.true.count div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Members pushing scopes: <xsl:value-of select="$members.osrc.scopes.push.count"/>
                            (<xsl:value-of select="format-number($members.osrc.scopes.push.count div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Members outsourcing: <xsl:value-of select="$members.osrc.count"/>
                            (<xsl:value-of select="format-number($members.osrc.count div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Members only outsourcing: <xsl:value-of select="$members.osrc.only.count"/>
                            (<xsl:value-of select="format-number($members.osrc.only.count div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Members neither deployed nor outsourcing: <xsl:value-of select="$members.osrc.none.count"/>
                            (<xsl:value-of select="format-number($members.osrc.none.count div $memberCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Chart:
                            <xsl:value-of select="$membersWithJustIdPsCount"/>,
                            <xsl:value-of select="$membersWithJustSPsCount"/>,
                            <xsl:value-of select="$membersWithBothCount"/>,
                            <xsl:value-of select="$members.osrc.only.count"/>,
                            <xsl:value-of select="$members.osrc.none.count"/>.                            
                        </p>
                    </li>
                </ul>


                <!--
                    *********************************************
                    ***                                       ***
                    ***   E N T I T Y   S T A T I S T I C S   ***
                    ***                                       ***
                    *********************************************
                -->
                

                <h2><a name="entities">Entity Statistics</a></h2>
                <p>
                    This section provides a useful bottom-up summary of the federation, 
                    by categorisation of entities, both total numbers and percentages. 
                    There are three subsections, presenting statistics applying to all entities, 
                    to Identity Providers and to Service Providers. 
                    In each subsection there is a 'breakdown by software used'. 
                    This lists the entities using each type of software recorded if 
                    there are fewer than 10 such entities in the category; 
                    otherwise only the overall numbers and percentages are given. 
                    (The software used is requested by the UK federation as part of the entity registration procedure,
                    and this information is recorded in the Software element of our records but not included
                    in published metadata.  Heuristics are used to guess the software in use
                    if there is no Software element in the metadata.) 
                </p>
                <p>Total entities: <xsl:value-of select="$entityCount"/>.  This breaks down into:</p>
                <ul>
                    <li>
                        <p>Identity providers: <xsl:value-of select="$idpCount"/></p>
                     </li>
                    <li>
                        <p>Service providers: <xsl:value-of select="$spCount"/></p>
                    </li>
                    <li>
                        <p>(including dual nature: <xsl:value-of select="$dualEntityCount"/>)</p>
                    </li>
                </ul>
                
                <p>Of the <xsl:value-of select="$entityCount"/> entities:</p>
                <ul>
                    <li>
                        <p>
                            <xsl:value-of select="$federationMemberEntityCount"/>
                            (<xsl:value-of select="format-number($federationMemberEntityCount div $entityCount, '0.0%')"/>)
                            are labelled as being owned by full
                            federation members.
                        </p>
                    </li>
                    <li>
                        <p>
                            <xsl:value-of select="$entities.artifact.saml1.count"/>
                            (<xsl:value-of select="format-number($entities.artifact.saml1.count div $entityCount, '0.0%')"/>
                            of all entities,
                            <xsl:value-of select="format-number($entities.artifact.saml1.count div $entities.saml1.count, '0.0%')"/>
                            of SAML 1.1 entities)
                            support the SAML 1.1 Browser/Artifact profile.
                        </p>
                    </li>

                    <xsl:variable name="httpEntities" select="$entities[starts-with(@entityID, 'http://')]"/>
                    <xsl:variable name="httpEntityCount" select="count($httpEntities)"/>
                    <xsl:if test="$httpEntityCount != 0">
                        <li>
                            <p>
                                <xsl:value-of select="$httpEntityCount"/>
                                (<xsl:value-of select="format-number($httpEntityCount div $entityCount, '0.0%')"/>)
                                <xsl:choose>
                                    <xsl:when test="$httpEntityCount = 1">
                                        has
                                    </xsl:when>
                                    <xsl:otherwise>
                                        have
                                    </xsl:otherwise>
                                </xsl:choose>
                                http:-style entity IDs.
                            </p>
                        </li>
                    </xsl:if>
                    
                    <xsl:variable name="urnEntities" select="$entities[starts-with(@entityID, 'urn:')]"/>
                    <xsl:variable name="urnEntityCount" select="count($urnEntities)"/>
                    <xsl:if test="$urnEntityCount != 0">
                        <li>
                            <p>
                                <xsl:value-of select="$urnEntityCount"/>
                                (<xsl:value-of select="format-number($urnEntityCount div $entityCount, '0.0%')"/>)
                                <xsl:choose>
                                    <xsl:when test="$urnEntityCount = 1">
                                        has
                                    </xsl:when>
                                    <xsl:otherwise>
                                        have
                                    </xsl:otherwise>
                                </xsl:choose>
                                urn:-style entity IDs.
                            </p>
                        </li>
                    </xsl:if>
                    
                    <xsl:variable name="httpsEntities" select="$entities[starts-with(@entityID, 'https://')]"/>
                    <xsl:variable name="httpsEntityCount" select="count($httpsEntities)"/>
                    <xsl:if test="$httpsEntityCount != 0">
                        <li>
                            <p>
                                <xsl:value-of select="$httpsEntityCount"/>
                                (<xsl:value-of select="format-number($httpsEntityCount div $entityCount, '0.0%')"/>)
                                <xsl:choose>
                                    <xsl:when test="$httpsEntityCount = 1">
                                        has
                                    </xsl:when>
                                    <xsl:otherwise>
                                        have
                                    </xsl:otherwise>
                                </xsl:choose>
                                https:-style entity IDs.
                            </p>
                        </li>
                    </xsl:if>
                    
                    <xsl:call-template name="ofthese.entity.extras">
                        <xsl:with-param name="entities" select="$entities"/>
                    </xsl:call-template>
                    
                </ul>

                <xsl:call-template name="entity.breakdown.by.software">
                    <xsl:with-param name="entities" select="$entities"/>
                </xsl:call-template>

                <xsl:call-template name="keydescriptor.breakdown">
                    <xsl:with-param name="entities" select="$entities"/>
                </xsl:call-template>



                <!--
                    ***********************************************
                    ***                                         ***
                    ***   I D E N T I T Y   P R O V I D E R S   ***
                    ***                                         ***
                    ***********************************************
                -->
                
                
                <h3>Identity Providers</h3>
                <p>There are <xsl:value-of select="$idpCount"/> identity providers,
                including <xsl:value-of select="$dualEntityCount"/>
                dual-nature entities (both identity and service providers in one).</p>
                <p>Of these:</p>
                <ul>
                    <li>
                        <xsl:variable name="concealedCount"
                            select="count($idps[md:Extensions/mdattr:EntityAttributes/saml:Attribute
                                [@Name = 'http://macedir.org/entity-category']
                                [@NameFormat = 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
                                [saml:AttributeValue[.='http://refeds.org/category/hide-from-discovery']]
                            ])"/>
                        <p>Hidden from main CDS: <xsl:value-of select="$concealedCount"/>
                        (<xsl:value-of select="format-number($concealedCount div $idpCount, '0.0%')"/>).</p>
                    </li>
                    <li>
                        <xsl:variable name="accountableCount"
                            select="count($idps[md:Extensions/ukfedlabel:AccountableUsers])"/>
                        <p>Asserting user accountability: <xsl:value-of select="$accountableCount"/>
                        (<xsl:value-of select="format-number($accountableCount div $idpCount, '0.0%')"/>).</p>
                    </li>
                    <li>
                        <p>
                            Support artifact resolution: <xsl:value-of select="$idps.artifact.count"/>
                            (<xsl:value-of select="format-number($idps.artifact.count div $idpCount, '0.0%')"/>).
                        </p>
                    </li>
                    <li>
                        <p>
                            Support SAML 1.1 artifact resolution: <xsl:value-of select="$idps.artifact.saml1.count"/>
                            (<xsl:value-of select="format-number($idps.artifact.saml1.count div $idpCount, '0.0%')"/>
                            of all IdPs, 
                            <xsl:value-of select="format-number($idps.artifact.saml1.count div $idps.saml1.count, '0.0%')"/>
                            of SAML 1.1 IdPs).
                        </p>
                    </li>
                    
                    <xsl:variable name="idp.noaa" select="$idps[not(md:AttributeAuthorityDescriptor)]"/>
                    <xsl:variable name="idp.noaa.count" select="count($idp.noaa)"/>
                    <xsl:if test="$idp.noaa.count != 0">
                        <li>
                            <p>
                                Without attribute authority role: <xsl:value-of select="$idp.noaa.count"/>
                                (<xsl:value-of select="format-number($idp.noaa.count div $idpCount, '0.0%')"/>).
                            </p>
                        </li>
                    </xsl:if>

                    <xsl:call-template name="ofthese.entity.extras">
                        <xsl:with-param name="entities" select="$idps"/>
                    </xsl:call-template>

                </ul>
                
                <p>SSO protocol support:</p>
                <ul>
                    <xsl:variable name="idp.sso.shibboleth"
                        select="$idps[contains(md:IDPSSODescriptor/@protocolSupportEnumeration,
                        'urn:mace:shibboleth:1.0')]"/>
                    <xsl:variable name="idp.sso.shibboleth.count" select="count($idp.sso.shibboleth)"/>
                    <li>
                        <p>
                            Shibboleth 1.0 SSO: <xsl:value-of select="$idp.sso.shibboleth.count"/>
                            (<xsl:value-of select="format-number($idp.sso.shibboleth.count div $idpCount, '0.0%')"/>)
                        </p>
                        <ul>
                            <xsl:variable name="idp.sso.shibboleth.auth"
                            select="$idp.sso.shibboleth[md:IDPSSODescriptor/md:SingleSignOnService/@Binding='urn:mace:shibboleth:1.0:profiles:AuthnRequest']"/>
                            <xsl:variable name="idp.sso.shibboleth.auth.count" select="count($idp.sso.shibboleth.auth)"/>
                            <li>
                                <p>
                                    Shibboleth 1.0 authentication request: <xsl:value-of select="$idp.sso.shibboleth.auth.count"/>
                                    (<xsl:value-of select="format-number($idp.sso.shibboleth.auth.count div $idpCount, '0.0%')"/>)
                                </p>
                                <p>Exceptions:</p>
                                <ul>
                                    <xsl:variable name="idp.sso.noshib" select="set:difference($idps, $idp.sso.shibboleth.auth)"/>
                                    <xsl:for-each select="$idp.sso.noshib">
                                        <li>
                                            <xsl:value-of select="@ID"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:if test="md:Extensions/mdattr:EntityAttributes/saml:Attribute
                                                [@Name = 'http://macedir.org/entity-category']
                                                [@NameFormat = 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
                                                [saml:AttributeValue[.='http://refeds.org/category/hide-from-discovery']]"> [H]</xsl:if>
                                            <xsl:value-of select="@entityID"/>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </li>
                        </ul>
                    </li>
                    
                    <xsl:variable name="idp.sso.saml.1.1"
                        select="$idps[contains(md:IDPSSODescriptor/@protocolSupportEnumeration,
                        'urn:oasis:names:tc:SAML:1.1:protocol')]"/>
                    <xsl:variable name="idp.sso.saml.1.1.count" select="count($idp.sso.saml.1.1)"/>
                    <li>
                        <p>
                            SAML 1.1 SSO: <xsl:value-of select="$idp.sso.saml.1.1.count"/>
                            (<xsl:value-of select="format-number($idp.sso.saml.1.1.count div $idpCount, '0.0%')"/>)
                        </p>
                    </li>
                    
                    <li>
                        <p>
                            Not supporting SAML 1.1 SSO:
                            <xsl:variable name="not.saml.1.1" select="$idpCount - $idp.sso.saml.1.1.count"/>
                            <xsl:value-of select="$not.saml.1.1"/>
                            (<xsl:value-of select="format-number($not.saml.1.1 div $idpCount, '0.0%')"/>)
                        </p>
                    </li>
                    
                    <xsl:variable name="idp.sso.saml.2.0"
                        select="$idps[contains(md:IDPSSODescriptor/@protocolSupportEnumeration,
                        'urn:oasis:names:tc:SAML:2.0:protocol')]"/>
                    <xsl:variable name="idp.sso.saml.2.0.count" select="count($idp.sso.saml.2.0)"/>
                    <li>
                        <p>
                            SAML 2.0 SSO: <xsl:value-of select="$idp.sso.saml.2.0.count"/>
                            (<xsl:value-of select="format-number($idp.sso.saml.2.0.count div $idpCount, '0.0%')"/>)
                        </p>
                        
                        <ul>
                            <xsl:variable name="idp.sso.saml.2.0.soap"
                                select="$idp.sso.saml.2.0[descendant::md:SingleSignOnService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:SOAP']]"/>
                            <xsl:variable name="idp.sso.saml.2.0.soap.count" select="count($idp.sso.saml.2.0.soap)"/>
                            <li>
                                SOAP binding: <xsl:value-of select="$idp.sso.saml.2.0.soap.count"/>
                                (<xsl:value-of select="format-number($idp.sso.saml.2.0.soap.count div $idp.sso.saml.2.0.count, '0.0%')"/> of SAML 2.0 IdPs,
                                <xsl:value-of select="format-number($idp.sso.saml.2.0.soap.count div $idpCount, '0.0%')"/> of all IdPs)
                            </li>
                            
                            <xsl:variable name="idp.sso.saml.2.0.artifact"
                                select="$idp.sso.saml.2.0[descendant::md:ArtifactResolutionService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:SOAP']]"/>
                            <xsl:variable name="idp.sso.saml.2.0.artifact.count" select="count($idp.sso.saml.2.0.artifact)"/>
                            <li>
                                Artifact: <xsl:value-of select="$idp.sso.saml.2.0.artifact.count"/>
                                (<xsl:value-of select="format-number($idp.sso.saml.2.0.artifact.count div $idp.sso.saml.2.0.count, '0.0%')"/> of SAML 2.0 IdPs,
                                <xsl:value-of select="format-number($idp.sso.saml.2.0.artifact.count div $idpCount, '0.0%')"/> of all IdPs)
                            </li>

                        </ul>
                    </li>
                    
                    <li>
                        <p>
                            Not supporting SAML 2.0 SSO:
                            <xsl:variable name="not.saml.2" select="$idpCount - $idp.sso.saml.2.0.count"/>
                            <xsl:value-of select="$not.saml.2"/>
                            (<xsl:value-of select="format-number($not.saml.2 div $idpCount, '0.0%')"/>)
                        </p>
                    </li>
                    
                </ul>

                <xsl:call-template name="entity.breakdown.by.software">
                    <xsl:with-param name="entities" select="$idps"/>
                </xsl:call-template>

                <xsl:call-template name="keydescriptor.breakdown">
                    <xsl:with-param name="entities" select="$idps"/>
                </xsl:call-template>
                
                

                <!--
                    *********************************************
                    ***                                       ***
                    ***   S E R V I C E   P R O V I D E R S   ***
                    ***                                       ***
                    *********************************************
                -->
                
                
                <h3>Service Providers</h3>
                <p>There are <xsl:value-of select="$spCount"/> service providers,
                    including <xsl:value-of select="$dualEntityCount"/>
                    dual-nature entities (both identity and service providers in one).</p>
                <p>Of these:</p>
                <ul>
                    <xsl:variable name="sp.slo" select="$sps[md:SPSSODescriptor/md:SingleLogoutService]"/>
                    <xsl:variable name="sp.slo.count" select="count($sp.slo)"/>
                    <li>
                        <p>
                            Support Single Logout: <xsl:value-of select="$sp.slo.count"/>
                            (<xsl:value-of select="format-number($sp.slo.count div $spCount, '0.0%')"/>).
                        </p>
                    </li>
                    
                    <xsl:variable name="sp.nim" select="$sps[md:SPSSODescriptor/md:ManageNameIDService]"/>
                    <xsl:variable name="sp.nim.count" select="count($sp.nim)"/>
                    <li>
                        <p>
                            Support NameID Management: <xsl:value-of select="$sp.nim.count"/>
                            (<xsl:value-of select="format-number($sp.nim.count div $spCount, '0.0%')"/>).
                        </p>
                    </li>
                    
                    <xsl:variable name="sp.idpdisc"
                        select="$sps[md:SPSSODescriptor/md:Extensions/idpdisc:DiscoveryResponse/@Binding=
                        'urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol']"/>
                    <xsl:variable name="sp.idpdisc.count" select="count($sp.idpdisc)"/>
                    <li>
                        <p>
                            Support SAML IdP Discovery Service Profile: <xsl:value-of select="$sp.idpdisc.count"/>
                            (<xsl:value-of select="format-number($sp.idpdisc.count div $spCount, '0.0%')"/>).
                        </p>
                    </li>
                    
                    <xsl:variable name="sp.init" select="$sps[md:SPSSODescriptor/md:Extensions/init:RequestInitiator]"/>
                    <xsl:variable name="sp.init.count" select="count($sp.init)"/>
                    <li>
                        <p>
                            Support SAML SP Request Initiation Protocol and Profile: <xsl:value-of select="$sp.init.count"/>
                            (<xsl:value-of select="format-number($sp.init.count div $spCount, '0.0%')"/>).
                        </p>
                    </li>
                    
                    <xsl:variable name="sp.rqa" select="$sps[descendant::md:RequestedAttribute]"/>
                    <xsl:variable name="sp.rqa.count" select="count($sp.rqa)"/>
                    <xsl:if test="$sp.rqa.count != 0">
                        <li>
                            <p>
                                Includes <code>RequestedAttribute</code> elements: <xsl:value-of select="$sp.rqa.count"/>
                                (<xsl:value-of select="format-number($sp.rqa.count div $spCount ,'0.0%')"/>).
                            </p>
                        </li>
                    </xsl:if>

                    <xsl:call-template name="ofthese.entity.extras">
                        <xsl:with-param name="entities" select="$sps"/>
                    </xsl:call-template>
                    
                </ul>
                
                <p>SSO protocol support:</p>
                <ul>
                    <xsl:variable name="sp.sso.saml.1.0"
                        select="$sps[contains(md:SPSSODescriptor/@protocolSupportEnumeration,
                        'urn:oasis:names:tc:SAML:1.0:protocol')]"/>
                    <xsl:variable name="sp.sso.saml.1.0.count" select="count($sp.sso.saml.1.0)"/>
                    <li>
                        <p>
                            SAML 1.0 SSO: <xsl:value-of select="$sp.sso.saml.1.0.count"/>
                            (<xsl:value-of select="format-number($sp.sso.saml.1.0.count div $spCount, '0.0%')"/>)
                        </p>
                        <ul>
                            <xsl:variable name="sp.saml.1.0.acs.saml.1.0.post"
                                select="$sp.sso.saml.1.0[md:SPSSODescriptor/md:AssertionConsumerService/@Binding='urn:oasis:names:tc:SAML:1.0:profiles:browser-post']"/>
                            <xsl:variable name="sp.saml.1.0.acs.saml.1.0.post.count" select="count($sp.saml.1.0.acs.saml.1.0.post)"/>
                            <li>
                                <p>
                                    Browser/POST: <xsl:value-of select="$sp.saml.1.0.acs.saml.1.0.post.count"/>
                                    (<xsl:value-of select="format-number($sp.saml.1.0.acs.saml.1.0.post.count div $sp.sso.saml.1.0.count, '0.0%')"/>)
                                </p>
                            </li>
                            
                            <xsl:variable name="sp.saml.1.0.acs.saml.1.0.artifact"
                                select="$sp.sso.saml.1.0[md:SPSSODescriptor/md:AssertionConsumerService/@Binding='urn:oasis:names:tc:SAML:1.0:profiles:artifact-01']"/>
                            <xsl:variable name="sp.saml.1.0.acs.saml.1.0.artifact.count" select="count($sp.saml.1.0.acs.saml.1.0.artifact)"/>
                            <li>
                                <p>
                                    Browser/Artifact: <xsl:value-of select="$sp.saml.1.0.acs.saml.1.0.artifact.count"/>
                                    (<xsl:value-of select="format-number($sp.saml.1.0.acs.saml.1.0.artifact.count div $sp.sso.saml.1.0.count, '0.0%')"/>)
                                </p>
                            </li>
                        </ul>
                    </li>
                    
                    <xsl:variable name="sp.sso.saml.1.1"
                        select="$sps[contains(md:SPSSODescriptor/@protocolSupportEnumeration,
                        'urn:oasis:names:tc:SAML:1.1:protocol')]"/>
                    <xsl:variable name="sp.sso.saml.1.1.count" select="count($sp.sso.saml.1.1)"/>
                    <li>
                        <p>
                            SAML 1.1 SSO: <xsl:value-of select="$sp.sso.saml.1.1.count"/>
                            (<xsl:value-of select="format-number($sp.sso.saml.1.1.count div $spCount, '0.0%')"/>)
                        </p>
                        <ul>
                            <xsl:variable name="sp.saml.1.1.acs.saml.1.0.post"
                                select="$sp.sso.saml.1.1[md:SPSSODescriptor/md:AssertionConsumerService/@Binding='urn:oasis:names:tc:SAML:1.0:profiles:browser-post']"/>
                            <xsl:variable name="sp.saml.1.1.acs.saml.1.0.post.count" select="count($sp.saml.1.1.acs.saml.1.0.post)"/>
                            <li>
                                <p>
                                    Browser/POST: <xsl:value-of select="$sp.saml.1.1.acs.saml.1.0.post.count"/>
                                    (<xsl:value-of select="format-number($sp.saml.1.1.acs.saml.1.0.post.count div $sp.sso.saml.1.1.count, '0.0%')"/>)
                                </p>
                            </li>
                            
                            <xsl:variable name="sp.saml.1.1.acs.saml.1.0.artifact"
                                select="$sp.sso.saml.1.1[md:SPSSODescriptor/md:AssertionConsumerService/@Binding='urn:oasis:names:tc:SAML:1.0:profiles:artifact-01']"/>
                            <xsl:variable name="sp.saml.1.1.acs.saml.1.0.artifact.count" select="count($sp.saml.1.1.acs.saml.1.0.artifact)"/>
                            <li>
                                <p>
                                    Browser/Artifact: <xsl:value-of select="$sp.saml.1.1.acs.saml.1.0.artifact.count"/>
                                    (<xsl:value-of select="format-number($sp.saml.1.1.acs.saml.1.0.artifact.count div $sp.sso.saml.1.1.count, '0.0%')"/>)
                                </p>
                            </li>

                        </ul>
                    </li>
                    
                    <li>
                        <p>
                            Not supporting SAML 1.1 SSO:
                            <xsl:variable name="not.saml.1.1" select="$spCount - $sp.sso.saml.1.1.count"/>
                            <xsl:value-of select="$not.saml.1.1"/>
                            (<xsl:value-of select="format-number($not.saml.1.1 div $spCount, '0.0%')"/>)
                        </p>
                    </li>
                    
                    <xsl:variable name="sp.sso.saml.2.0"
                        select="$sps[contains(md:SPSSODescriptor/@protocolSupportEnumeration,
                        'urn:oasis:names:tc:SAML:2.0:protocol')]"/>
                    <xsl:variable name="sp.sso.saml.2.0.count" select="count($sp.sso.saml.2.0)"/>
                    <li>
                        <p>
                            SAML 2.0 SSO: <xsl:value-of select="$sp.sso.saml.2.0.count"/>
                            (<xsl:value-of select="format-number($sp.sso.saml.2.0.count div $spCount, '0.0%')"/>)
                        </p>
                        <ul>
                            <xsl:variable name="sp.saml.2.0.acs.saml.2.0.post"
                                select="$sp.sso.saml.2.0[md:SPSSODescriptor/md:AssertionConsumerService/@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']"/>
                            <xsl:variable name="sp.saml.2.0.acs.saml.2.0.post.count" select="count($sp.saml.2.0.acs.saml.2.0.post)"/>
                            <li>
                                <p>
                                    Browser/POST: <xsl:value-of select="$sp.saml.2.0.acs.saml.2.0.post.count"/>
                                    (<xsl:value-of select="format-number($sp.saml.2.0.acs.saml.2.0.post.count div $sp.sso.saml.2.0.count, '0.0%')"/>)
                                </p>
                            </li>
                            
                            <xsl:variable name="sp.saml.2.0.acs.saml.2.0.post.ss"
                                select="$sp.sso.saml.2.0[md:SPSSODescriptor/md:AssertionConsumerService/@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign']"/>
                            <xsl:variable name="sp.saml.2.0.acs.saml.2.0.post.ss.count" select="count($sp.saml.2.0.acs.saml.2.0.post.ss)"/>
                            <li>
                                <p>
                                    Browser/POST-SimpleSign: <xsl:value-of select="$sp.saml.2.0.acs.saml.2.0.post.ss.count"/>
                                    (<xsl:value-of select="format-number($sp.saml.2.0.acs.saml.2.0.post.ss.count div $sp.sso.saml.2.0.count, '0.0%')"/>)
                                </p>
                            </li>

                            <xsl:variable name="sp.saml.2.0.acs.saml.2.0.artifact"
                                select="$sp.sso.saml.2.0[md:SPSSODescriptor/md:AssertionConsumerService/@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact']"/>
                            <xsl:variable name="sp.saml.2.0.acs.saml.2.0.artifact.count" select="count($sp.saml.2.0.acs.saml.2.0.artifact)"/>
                            <li>
                                <p>
                                    Browser/Artifact: <xsl:value-of select="$sp.saml.2.0.acs.saml.2.0.artifact.count"/>
                                    (<xsl:value-of select="format-number($sp.saml.2.0.acs.saml.2.0.artifact.count div $sp.sso.saml.2.0.count, '0.0%')"/>)
                                </p>
                            </li>

                            <xsl:variable name="sp.saml.2.0.acs.saml.2.0.paos"
                                select="$sp.sso.saml.2.0[md:SPSSODescriptor/md:AssertionConsumerService/@Binding='urn:oasis:names:tc:SAML:2.0:bindings:PAOS']"/>
                            <xsl:variable name="sp.saml.2.0.acs.saml.2.0.paos.count" select="count($sp.saml.2.0.acs.saml.2.0.paos)"/>
                            <li>
                                <p>
                                    PAOS: <xsl:value-of select="$sp.saml.2.0.acs.saml.2.0.paos.count"/>
                                    (<xsl:value-of select="format-number($sp.saml.2.0.acs.saml.2.0.paos.count div $sp.sso.saml.2.0.count, '0.0%')"/>)
                                </p>
                            </li>                            
                            
                        </ul>
                    </li>
                    
                    <li>
                        <p>
                            Not supporting SAML 2.0 SSO:
                            <xsl:variable name="not.saml.2" select="$spCount - $sp.sso.saml.2.0.count"/>
                            <xsl:value-of select="$not.saml.2"/>
                            (<xsl:value-of select="format-number($not.saml.2 div $spCount, '0.0%')"/>)
                        </p>
                    </li>

                </ul>
                
                <xsl:call-template name="entity.breakdown.by.software">
                    <xsl:with-param name="entities" select="$sps"/>
                </xsl:call-template>

                <xsl:call-template name="keydescriptor.breakdown">
                    <xsl:with-param name="entities" select="$sps"/>
                </xsl:call-template>
                
                
                
                <!--
                    *********************************************
                    ***                                       ***
                    ***   E N T I T I E S   B Y   O W N E R   ***
                    ***                                       ***
                    *********************************************
                -->
                <h2><a name="byOwner">Entities by Owner</a></h2>
                <p>
                    This section is intended to be largely self-explanatory. 
                    Any items in [...] brackets give additional information about the entity: 
                    its type, the software used, etc. 
                 </p>
                <ul>
                    <xsl:apply-templates select="$memberNames" mode="enumerate">
                        <xsl:with-param name="entities" select="$entities"/>
                    </xsl:apply-templates>
                </ul>

                
                
                <!--
                    ***********************************************
                    ***                                         ***
                    ***   I D P   A C C O U N T A B I L I T Y   ***
                    ***                                         ***
                    ***********************************************
                -->
                <h2><a name="accountableIdPs">Identity Provider Accountability</a></h2>
                
                <p>
                    The following entities are visible in the main federation discovery service
                    but do not assert user accountability:
                </p>
                <ul>
                    <xsl:for-each select="$idps[not(md:Extensions/ukfedlabel:AccountableUsers)]
                        [not(md:Extensions/mdattr:EntityAttributes/saml:Attribute
                            [@Name = 'http://macedir.org/entity-category']
                            [@NameFormat = 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
                            [saml:AttributeValue[.='http://refeds.org/category/hide-from-discovery']])]">
                        <xsl:sort select="md:Organization/md:OrganizationDisplayName"/>
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>
                        </li>
                    </xsl:for-each>
                </ul>

                <!--
                    ***********************************************************
                    ***                                                     ***
                    ***   M E M B E R S   B Y   P R I M A R Y   S C O P E   ***
                    ***                                                     ***
                    ***********************************************************
                -->
                <h2><a name="membersByScope">Members by Primary Scope</a></h2>
                <p>Primary Scope is a useful concept, but is not precisely defined. 
                   It is only recorded if the member in question owns an IdP or outsources its IdP provision - 
                   and perhaps not even then, as it it sometimes unclear which of the scopes 
                   it owns should be designated as 'primary'.</p>
                <table border="1" cellspacing="2" cellpadding="4">
                    <tr>
                        <th align="left">Primary Scope</th>
                        <th align="left">Member</th>
                    </tr>
                    <xsl:variable name="membersWithScopes" select="$members[members:PrimaryScope]"/>
                    <xsl:for-each select="$membersWithScopes">
                        <xsl:sort select="members:PrimaryScope"/>
                        <tr>
                            <td><code><xsl:value-of select="members:PrimaryScope"/></code></td>
                            <td><xsl:value-of select="members:Name"/></td>
                        </tr>
                    </xsl:for-each>
                </table>
                
                <!--
                    ***************************************************************
                    ***                                                         ***
                    ***   M E M B E R S   L A C K I N G   D E P L O Y M E N T   ***
                    ***                                                         ***
                    ***************************************************************
                -->
                <h2><a name="undeployedMembers">Members Lacking Deployment</a></h2>
                <!-- start with members with no entities and no OpenAthens -->
                <xsl:variable name="nodeploy.0" select="$membersWithNoneNoAthens"/>
                <!-- remove members who have scopes sent to some entity -->
                <xsl:variable name="nodeploy.1"
                    select="$nodeploy.0[not(members:Scopes/members:Entity)]"
                />
                <xsl:variable name="nodeploy.out" select="$nodeploy.1"/>
                <p>
                    The following <xsl:value-of select="count($nodeploy.out)"/>
                    members of the UK federation have no deployed entities,
                    either in their own name or deployed on their behalf by other members.
                    The list is ordered by date of joining the UK federation.
                </p>
                <ul>
                    <xsl:for-each select="$nodeploy.out">
                        <xsl:sort select="members:JoinDate"/>
                        <li>
                            <xsl:value-of select="members:JoinDate"/>:
                            <xsl:value-of select="members:Name"/>
                        </li>
                    </xsl:for-each>
                </ul>                
                


                <!--
                    ***************************************************************
                    ***                                                         ***
                    ***      S H I B B O L E T H   1 . 3   R E M N A N T S      ***
                    ***                                                         ***
                    ***************************************************************
                -->
                <h2><a name="shib13">Shibboleth 1.3 Remnants</a></h2>
                <p>
                    The following lists show entities that are believed to be running the
                    Shibboleth 1.3 software, which reached its official end of life
                    date on 30-June-2010.
                    As heuristics have been used to create these lists, they may
                    not be completely accurate.
                </p>

                <h3>Shibboleth 1.3 Identity Provider Entities</h3>
                <xsl:call-template name="list.shibboleth.1.3.entities">
                    <xsl:with-param name="entities" select="$idps"/>
                </xsl:call-template>

                <h3>Shibboleth 1.3 Service Provider Entities</h3>
                <xsl:call-template name="list.shibboleth.1.3.entities">
                    <xsl:with-param name="entities" select="$sps"/>
                </xsl:call-template>
 
 
                <!--
                    ***************************************
                    ***                                 ***
                    ***   E X P O R T   O P T   O U T   ***
                    ***                                 ***
                    ***************************************
                -->
                
                <h2><a name="exportOptOut">Export Aggregate: Entities Opted Out</a></h2>
                <xsl:variable name="entities.export.opt.out" select="$entities[descendant::ukfedlabel:ExportOptOut]"/>
                <xsl:variable name="entities.export.opt.out.count" select="count($entities.export.opt.out)"/>
                <xsl:if test="$entities.export.opt.out.count != 0">
                    <ul>
                        <xsl:for-each select="$entities.export.opt.out">
                            <li>
                                <xsl:value-of select="@ID"/>
                                <xsl:text>: </xsl:text>
                                <xsl:if test="md:IDPSSODescriptor">
                                    <xsl:text>[IdP] </xsl:text>
                                </xsl:if>
                                <xsl:if test="md:SPSSODescriptor">
                                    <xsl:text>[SP] </xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="descendant::md:RequestedAttribute">
                                            <xsl:text>[RqA] </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>[!RqA] </xsl:text> 
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:if>
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
                                <xsl:if test="not(descendant::*[contains(@protocolSupportEnumeration,
                                    'urn:oasis:names:tc:SAML:2.0:protocol')])">
                                    <ul>
                                        <li>
                                            No SAML 2.0 support
                                        </li>
                                    </ul>                                    
                                </xsl:if>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                
                <!--
                    *************************************
                    ***                               ***
                    ***   E X P O R T   O P T   I N   ***
                    ***                               ***
                    *************************************
                -->
                
                <h2><a name="exportOptIn">Export Aggregate: Entities Explicitly Opted In</a></h2>
                <xsl:variable name="entities.export" select="$entities[descendant::ukfedlabel:ExportOptIn]"/>
                <xsl:variable name="entities.export.count" select="count($entities.export)"/>
                <xsl:if test="$entities.export.count != 0">
                    <ul>
                        <xsl:for-each select="$entities.export">
                            <li>
                                <xsl:value-of select="@ID"/>
                                <xsl:text>: </xsl:text>
                                <xsl:if test="md:IDPSSODescriptor">
                                    <xsl:text>[IdP] </xsl:text>
                                </xsl:if>
                                <xsl:if test="md:SPSSODescriptor">
                                    <xsl:text>[SP] </xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="descendant::md:RequestedAttribute">
                                            <xsl:text>[RqA] </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>[!RqA] </xsl:text> 
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:if>
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
                                <xsl:if test="not(descendant::*[contains(@protocolSupportEnumeration,
                                    'urn:oasis:names:tc:SAML:2.0:protocol')])">
                                    <ul>
                                        <li>
                                            No SAML 2.0 support
                                        </li>
                                    </ul>                                    
                                </xsl:if>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                
                <!--
                    *****************************************************************************
                    ***                                                                       ***
                    ***   E N T I T I E S   W I T H O U T   S A M L   2 . 0   S U P P O R T   ***
                    ***                                                                       ***
                    *****************************************************************************
                -->
                <h2><a name="nosaml2">Entities Without SAML 2.0 Support</a></h2>
                <h3>Service Providers Without SAML 2.0 Support</h3>
                <p>
                    This list shows the entity ID, entity owner and display name for all service provider
                    entities which do not declare support for the SAML 2.0 protocol. It is sorted by
                    entity owner. The display name is shown in parentheses if it is taken from the
                    OrganizationDisplayName element, and without parentheses if it is taken from
                    MDUI metadata.
                </p>
                <p>
                    The software used by the entity, if known, is included at the end of the listing within
                    brackets [like this].
                </p>
                <ul>
                    <xsl:for-each select="$sps[md:SPSSODescriptor[not(contains(@protocolSupportEnumeration,
                        'urn:oasis:names:tc:SAML:2.0:protocol'))]]">
                        <xsl:sort select="descendant::md:OrganizationName"/>
                        <li>
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
                        </li>
                    </xsl:for-each>
                </ul>
                <xsl:call-template name="entity.breakdown.by.software">
                    <xsl:with-param name="entities" select="$sps[md:SPSSODescriptor[not(contains(@protocolSupportEnumeration,
                        'urn:oasis:names:tc:SAML:2.0:protocol'))]]"/>
                </xsl:call-template>


            </body>
        </html>
    </xsl:template>
    
    <!--
        *****************************************
        ***                                   ***
        ***   O T H E R   T E M P L A T E S   ***
        ***                                   ***
        *****************************************
    -->
    
    <xsl:template match="members:Member|members:NonMember" mode="count">
        <xsl:param name="entities"/>
        <xsl:variable name="myName" select="string(members:Name)"/>
        <xsl:variable name="matched" select="$entities[md:Organization/md:OrganizationName = $myName]"/>
        <xsl:variable name="primaryScope" select="members:PrimaryScope"/>
        <tr>
            <td>
                <xsl:value-of select="$myName"/>
                <xsl:if test="members:NameComment">
                    <br />
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="members:NameComment"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </td>
            <!-- count total entities -->
            <td align="center">
                <xsl:choose>
                    <xsl:when test="count($matched) = 0">
                        -
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="count($matched)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- count IdPs -->
            <xsl:variable name="matchedIdPs" select="$matched[md:IDPSSODescriptor]"/>
            <td align="center">
                <xsl:choose>
                    <xsl:when test="count($matchedIdPs) = 0">
                        -
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="count($matchedIdPs)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- count SPs -->
            <xsl:variable name="matchedSPs" select="$matched[md:SPSSODescriptor]"/>
            <td align="center">
                <xsl:choose>
                    <xsl:when test="count($matchedSPs) = 0">
                        -
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="count($matchedSPs)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            
            <!-- Outsourcing in general -->
            <td align="center">
                <xsl:choose>
                
                	<!-- Special case: Eduserv does NOT outsource -->
                    <xsl:when test="members:Name = 'Eduserv'">
                        &#160;
                    </xsl:when>
                    
                    <!-- anyone else using the Athens IdP does outsource -->
                    <xsl:when test="@usesAthensIdP = 'true'">
                        *
                    </xsl:when>
                    
                    <!--
                    	Anyone pushing scopes to an entity is assumed to
                    	be outsourcing.  Strictly speaking, this should be
                    	anyone pushing scopes to an entity owned by another
                    	member.
                    -->
                    <xsl:when test="members:Scopes/members:Entity">
                        *
                    </xsl:when>
                    
                    <!-- if none of the above, not outsourcing -->
                    <xsl:otherwise>
                        &#160;
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            
            <!-- Primary Scope, if present -->
            <td align="left">
                <xsl:choose>
                    <xsl:when test="count($primaryScope) = 0">
                        &#160;
                    </xsl:when>
                    <xsl:otherwise>
                        <code><xsl:value-of select="$primaryScope"/></code>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="members:Name" mode="enumerate">
        <xsl:param name="entities"/>
        <xsl:variable name="myName" select="."/>
        <xsl:variable name="matched" select="$entities[md:Organization/md:OrganizationName = $myName]"/>
        <xsl:if test="count($matched) != 0">
            <li>
                <p><xsl:value-of select="$myName"/>:</p>
                <ul>
                    <xsl:for-each select="$matched">
                        <li>
                            <xsl:value-of select="@ID"/>
                            <xsl:text>:</xsl:text>
                            <xsl:if test="not(md:Extensions/ukfedlabel:UKFederationMember)"> [not-M]</xsl:if>
                            <xsl:if test="md:IDPSSODescriptor"> [IdP]</xsl:if>
                            <xsl:if test="md:Extensions/mdattr:EntityAttributes/saml:Attribute
                                [@Name = 'http://macedir.org/entity-category']
                                [@NameFormat = 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
                                [saml:AttributeValue[.='http://refeds.org/category/hide-from-discovery']]"> [H]</xsl:if>
                            <xsl:if test="md:SPSSODescriptor"> [SP]</xsl:if>
                            <xsl:if test="descendant::mdui:UIInfo"> [UIInfo]</xsl:if>
                            <xsl:apply-templates select="md:Extensions/ukfedlabel:Software" mode="short"/>
                            <xsl:text> </xsl:text>
                            <code><xsl:value-of select="@entityID"/></code>
                        </li>
                    </xsl:for-each>
                </ul>
            </li>
        </xsl:if>
    </xsl:template>

    <!--
        Display a Software label in a short form suitable for text displays
    -->
    <xsl:template match="ukfedlabel:Software" mode="short">
        <xsl:text> [</xsl:text>
        <xsl:choose>
            <xsl:when test="@name = 'Shibboleth'">
                <xsl:text>Shib</xsl:text>
            </xsl:when>
            <xsl:when test="@name='OpenAthens'">
                <xsl:text>OA</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@name"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>]</xsl:text>
    </xsl:template>



    <!--
        *********************************************
        ***                                       ***
        ***   " O F   T H E S E "   E X T R A S   ***
        ***                                       ***
        *********************************************
        
        Extra list entries for the "of these" breakdowns
        in the entity sections.
    -->
    <xsl:template name="ofthese.entity.extras">
        <xsl:param name="entities"/>
        <xsl:variable name="entityCount" select="count($entities)"/>

        <xsl:variable name="e.uiinfo" select="$entities[descendant::mdui:UIInfo]"/>
        <xsl:variable name="e.uiinfo.count" select="count($e.uiinfo)"/>
        <xsl:if test="$e.uiinfo.count != 0">
            <li>
                <p>
                    <xsl:value-of select="$e.uiinfo.count"/>
                    (<xsl:value-of select="format-number($e.uiinfo.count div $entityCount, '0.0%')"/>)
                    provide mdui:UIInfo metadata.
                </p>
            </li>
        </xsl:if>
        
        <xsl:variable name="e.algsupport"
            select="$entities[descendant::alg:* or descendant::md:EncryptionMethod]"/>
        <xsl:variable name="e.algsupport.count" select="count($e.algsupport)"/>
        <xsl:if test="$e.algsupport.count != 0">
            <li>
                <p>
                    <xsl:value-of select="$e.algsupport.count"/>
                    (<xsl:value-of select="format-number($e.algsupport.count div $entityCount, '0.0%')"/>)
                    provide algorithm support metadata:
                </p>
                
                <ul>
                    <xsl:variable name="e.alg.dig" select="$entities[descendant::alg:SigningMethod]"/>
                    <xsl:variable name="e.alg.dig.count" select="count($e.alg.dig)"/>
                    <li>
                        <p>
                            Declaring support for digest methods:
                            <xsl:value-of select="$e.alg.dig.count"/>
                        </p>
                    </li>
                    <ul>
                        <xsl:variable name="e.sha1" select="$entities[
                            descendant::alg:DigestMethod/@Algorithm='http://www.w3.org/2000/09/xmldsig#sha1']"/>
                        <xsl:variable name="e.sha1.count" select="count($e.sha1)"/>
                        <li>
                            SHA-1 digests:
                            <xsl:value-of select="$e.sha1.count"/>
                            (<xsl:value-of select="format-number($e.sha1.count div $e.alg.dig.count, '0.0%')"/>)
                        </li>
                        
                        <xsl:variable name="e.sha224" select="$entities[
                            descendant::alg:DigestMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#sha224']"/>
                        <xsl:variable name="e.sha224.count" select="count($e.sha224)"/>
                        <li>
                            SHA-224 digests:
                            <xsl:value-of select="$e.sha224.count"/>
                            (<xsl:value-of select="format-number($e.sha224.count div $e.alg.dig.count, '0.0%')"/>)
                        </li>
                        
                        <xsl:variable name="e.sha256" select="$entities[
                            descendant::alg:DigestMethod/@Algorithm='http://www.w3.org/2001/04/xmlenc#sha256']"/>
                        <xsl:variable name="e.sha256.count" select="count($e.sha256)"/>
                        <li>
                            SHA-256 digests:
                            <xsl:value-of select="$e.sha256.count"/>
                            (<xsl:value-of select="format-number($e.sha256.count div $e.alg.dig.count, '0.0%')"/>)
                        </li>
                        
                        <xsl:variable name="e.sha384" select="$entities[
                            descendant::alg:DigestMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#sha384']"/>
                        <xsl:variable name="e.sha384.count" select="count($e.sha384)"/>
                        <li>
                            SHA-384 digests:
                            <xsl:value-of select="$e.sha384.count"/>
                            (<xsl:value-of select="format-number($e.sha384.count div $e.alg.dig.count, '0.0%')"/>)
                        </li>
                        
                        <xsl:variable name="e.sha512" select="$entities[
                            descendant::alg:DigestMethod/@Algorithm='http://www.w3.org/2001/04/xmlenc#sha512']"/>
                        <xsl:variable name="e.sha512.count" select="count($e.sha512)"/>
                        <li>
                            SHA-512 digests:
                            <xsl:value-of select="$e.sha512.count"/>
                            (<xsl:value-of select="format-number($e.sha512.count div $e.alg.dig.count, '0.0%')"/>)
                        </li>

                        <xsl:variable name="e.sha3.any" select="$entities[
                            descendant::alg:DigestMethod/@Algorithm='http://www.w3.org/2007/05/xmldsig-more#sha3-224' or
                            descendant::alg:DigestMethod/@Algorithm='http://www.w3.org/2007/05/xmldsig-more#sha3-256' or
                            descendant::alg:DigestMethod/@Algorithm='http://www.w3.org/2007/05/xmldsig-more#sha3-384' or
                            descendant::alg:DigestMethod/@Algorithm='http://www.w3.org/2007/05/xmldsig-more#sha3-512']"/>
                        <xsl:variable name="e.sha3.any.count" select="count($e.sha3.any)"/>
                        <li>
                            any SHA-3 digest:
                            <xsl:value-of select="$e.sha3.any.count"/>
                            (<xsl:value-of select="format-number($e.sha3.any.count div $e.alg.dig.count, '0.0%')"/>)
                        </li>
                        
                    </ul>
                    
                    <xsl:variable name="e.alg.sig" select="$entities[descendant::alg:SigningMethod]"/>
                    <xsl:variable name="e.alg.sig.count" select="count($e.alg.sig)"/>
                    <li>
                        <p>
                            Declaring support for signing methods:
                            <xsl:value-of select="$e.alg.sig.count"/>
                        </p>
                    </li>
                    <ul>
                        <xsl:variable name="e.sha1" select="$entities[
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2000/09/xmldsig#rsa-sha1']"/>
                        <xsl:variable name="e.sha1.count" select="count($e.sha1)"/>
                        <li>
                            RSA + SHA-1 signatures:
                            <xsl:value-of select="$e.sha1.count"/>
                            (<xsl:value-of select="format-number($e.sha1.count div $e.alg.sig.count, '0.0%')"/>)
                        </li>
                        
                        <xsl:variable name="e.sha224" select="$entities[
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#rsa-sha224']"/>
                        <xsl:variable name="e.sha224.count" select="count($e.sha224)"/>
                        <li>
                            RSA + SHA-224 signatures:
                            <xsl:value-of select="$e.sha224.count"/>
                            (<xsl:value-of select="format-number($e.sha224.count div $e.alg.sig.count, '0.0%')"/>)
                        </li>
                        
                        <xsl:variable name="e.sha256" select="$entities[
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#rsa-sha256']"/>
                        <xsl:variable name="e.sha256.count" select="count($e.sha256)"/>
                        <li>
                            RSA + SHA-256 signatures:
                            <xsl:value-of select="$e.sha256.count"/>
                            (<xsl:value-of select="format-number($e.sha256.count div $e.alg.sig.count, '0.0%')"/>)
                        </li>

                        <xsl:variable name="e.sha384" select="$entities[
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#rsa-sha384']"/>
                        <xsl:variable name="e.sha384.count" select="count($e.sha384)"/>
                        <li>
                            RSA + SHA-384 signatures:
                            <xsl:value-of select="$e.sha384.count"/>
                            (<xsl:value-of select="format-number($e.sha384.count div $e.alg.sig.count, '0.0%')"/>)
                        </li>

                        <xsl:variable name="e.sha512" select="$entities[
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#rsa-sha512']"/>
                        <xsl:variable name="e.sha512.count" select="count($e.sha512)"/>
                        <li>
                            RSA + SHA-512 signatures:
                            <xsl:value-of select="$e.sha512.count"/>
                            (<xsl:value-of select="format-number($e.sha512.count div $e.alg.sig.count, '0.0%')"/>)
                        </li>
                        
                        <xsl:variable name="e.ec.any" select="$entities[
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha1' or
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha224' or
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256' or
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha384' or
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha512']"/>
                        <xsl:variable name="e.ec.any.count" select="count($e.ec.any)"/>
                        <li>
                            elliptic curve DSA signatures of any kind:
                            <xsl:value-of select="$e.ec.any.count"/>
                            (<xsl:value-of select="format-number($e.ec.any.count div $e.alg.sig.count, '0.0%')"/>)
                        </li>
                        
                        <xsl:variable name="e.dsa.any" select="$entities[
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2000/09/xmldsig#dsa-sha1' or
                            descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2009/xmldsig11#dsa-sha256']"/>
                        <xsl:variable name="e.dsa.any.count" select="count($e.dsa.any)"/>
                        <li>
                            non-EC DSA signatures of any kind:
                            <xsl:value-of select="$e.dsa.any.count"/>
                            (<xsl:value-of select="format-number($e.dsa.any.count div $e.alg.sig.count, '0.0%')"/>)
                            <xsl:variable name="e.dsa.old" select="$entities[
                                descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2000/09/xmldsig#dsa-sha1']"/>
                            <xsl:variable name="e.dsa.old.count" select="count($e.dsa.old)"/>
                            <xsl:variable name="e.dsa.new" select="$entities[
                                descendant::alg:SigningMethod/@Algorithm='http://www.w3.org/2009/xmldsig11#dsa-sha256']"/>
                            <xsl:variable name="e.dsa.new.count" select="count($e.dsa.new)"/>
                            [<xsl:value-of select="$e.dsa.old.count"/>, <xsl:value-of select="$e.dsa.new.count"/>]
                        </li>
                        
                    </ul>
                    
                    <xsl:variable name="e.alg.enc" select="$entities[descendant::md:EncryptionMethod]"/>
                    <xsl:variable name="e.alg.enc.count" select="count($e.alg.enc)"/>
                    <li>
                        <p>
                            Declaring support for encryption methods:
                            <xsl:value-of select="$e.alg.enc.count"/>
                        </p>
                    </li>
                    <ul>
                        <xsl:variable name="e.gcm" select="$entities[
                            descendant::md:EncryptionMethod/@Algorithm='http://www.w3.org/2009/xmlenc11#aes128-gcm' or
                            descendant::md:EncryptionMethod/@Algorithm='http://www.w3.org/2009/xmlenc11#aes192-gcm' or
                            descendant::md:EncryptionMethod/@Algorithm='http://www.w3.org/2009/xmlenc11#aes256-gcm']"/>
                        <xsl:variable name="e.gcm.count" select="count($e.gcm)"/>
                        <li>
                            GCM encryption:
                            <xsl:value-of select="$e.gcm.count"/>
                            (<xsl:value-of select="format-number($e.gcm.count div $e.alg.enc.count, '0.0%')"/>)
                        </li>
                    </ul>
                    
                </ul>
    
            </li>
        </xsl:if>

    </xsl:template>



    <!--
        Given a list of entities, extract and list those which are apparently running Shibboleth 1.3.
    -->
    <xsl:template name="list.shibboleth.1.3.entities">
        <xsl:param name="entities"/>
        <!--
            Remove everything that says it is something other than Shibboleth, or which includes
            a SAML 2.0 token in any of its role descriptors' protocolSupportEnumerations.
        -->
        <xsl:variable name="entities.1"
            select="set:difference($entities,
                $entities[
                    md:Extensions/ukfedlabel:Software[@name != 'Shibboleth'] |
                    md:*[contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')]
                ])"/>
        <!-- remove things that look like Shibboleth 2.x -->
        <xsl:variable name="entities.2"
            select="set:difference($entities.1,
                $entities.1[
                    md:IDPSSODescriptor/md:SingleSignOnService[contains(@Location, '/profile/Shibboleth/SSO')] |
                    md:SPSSODescriptor/md:AssertionConsumerService[contains(@Location, '/Shibboleth.sso/SAML2/POST')] |
                    md:Extensions/ukfedlabel:Software[@name='Shibboleth'][@version = '2']
                ]
            )"/>
        <!-- select only remainder that look like Shibboleth 1.3 -->
        <xsl:variable name="entities.3"
            select="$entities.2[
                md:Extensions/ukfedlabel:Software[@name='Shibboleth'][@version = '1.3'] |
                md:IDPSSODescriptor/md:SingleSignOnService[contains(@Location, '-idp/SSO')] |
                md:SPSSODescriptor/md:AssertionConsumerService[contains(@Location, 'Shibboleth.sso')]
            ]"/>
        <!-- final set -->
        <xsl:variable name="entities.out" select="$entities.3"/>
        <xsl:variable name="entities.out.count" select="count($entities.out)"/>
        <!-- print the list -->
        <p>
            <xsl:value-of select="$entities.out.count"/> entities:
        </p>
        <ul>
            <xsl:for-each select="$entities.out">
                <li>
                    <xsl:value-of select="@ID"/>:
                    <code><xsl:value-of select="@entityID"/></code>
                    <!-- suspect misclassification if an SP has an encryption key -->
                    <xsl:if test="md:SPSSODescriptor/md:KeyDescriptor[@use='encryption']">
                        <xsl:text> [HasEncKey]</xsl:text>
                    </xsl:if>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="md:Organization/md:OrganizationName"/>
                    <xsl:text>)</xsl:text>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    
    <!--
        Break down a set of entities by the software used.
    -->
    <xsl:template name="entity.breakdown.by.software">
        <xsl:param name="entities"/>
        <xsl:variable name="entityCount" select="count($entities)"/>
        <p>
            Breakdown by software used:
        </p>
        <ul>
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
                Classify Shibboleth 3 IdPs entities.
            -->
            <xsl:variable name="entities.shib.3.in" select="$entities.openathens.out"/>
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
                Classify Shibboleth 1.3 entities.
            -->
            <xsl:variable name="entities.shib.13.in" select="$entities.shib.2.out"/>
            <xsl:variable name="entities.shib.13"
                select="$entities.shib.13.in[
                    md:Extensions/ukfedlabel:Software[@name='Shibboleth'][@version = '1.3'] |
                    md:IDPSSODescriptor/md:SingleSignOnService[contains(@Location, '-idp/SSO')] |
                    md:SPSSODescriptor/md:AssertionConsumerService[contains(@Location, 'Shibboleth.sso')]
                ][
                    not(md:*[contains(@protocolSupportEnumeration, 'urn:oasis:names:tc:SAML:2.0:protocol')])
                ]"/>
            <xsl:variable name="entities.shib.13.out"
                select="set:difference($entities.shib.13.in, $entities.shib.13)"/>
            
            <!--
                Classify Athens Gateway entities
            -->
            <xsl:variable name="entities.gateways.in" select="$entities.shib.13.out"/>
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
                        'https://gateway.athensams.net:5057/services/SAML11AttributeAuthority']"/>
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
                <xsl:with-param name="entities" select="$entities.shib.3"/>
                <xsl:with-param name="name">Shibboleth 3.x</xsl:with-param>
                <xsl:with-param name="total" select="$entityCount"/>
            </xsl:call-template>
            
            <xsl:call-template name="entity.breakdown.by.software.line">
                <xsl:with-param name="entities" select="$entities.shib.2"/>
                <xsl:with-param name="name">Shibboleth 2.x</xsl:with-param>
                <xsl:with-param name="total" select="$entityCount"/>
            </xsl:call-template>
            
            <xsl:call-template name="entity.breakdown.by.software.line">
                <xsl:with-param name="entities" select="$entities.shib.13"/>
                <xsl:with-param name="name">Shibboleth 1.3</xsl:with-param>
                <xsl:with-param name="total" select="$entityCount"/>
                <xsl:with-param name="show.max" select="10"/>
            </xsl:call-template>

            <xsl:variable name="entities.shib" select="$entities.shib.13 | $entities.shib.2 | $entities.shib.3"/>
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

        </ul>
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
            <li>
                <p>
                    <xsl:value-of select="$name"/>: <xsl:value-of select="$n"/>
                    (<xsl:value-of select="format-number($n div $total, '0.0%')"/>)
                </p>
                <xsl:if test="($show != 0) or ($n &lt;= $show.max)">
                    <ul>
                        <xsl:for-each select="$entities">
                            <li>
                                <xsl:value-of select="@ID"/>:
                                <code><xsl:value-of select="@entityID"/></code>
                                <xsl:if test="$show.software != 0">
                                    <xsl:choose>
                                        <xsl:when test="md:Extensions/ukfedlabel:Software">
                                            (<xsl:value-of select="md:Extensions/ukfedlabel:Software/@name"/>)
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:if>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>
    
    <!--
        *********************************************************
        ***                                                   ***
        ***   K E Y D E S C R I P T O R   B R E A K D O W N   ***
        ***                                                   ***
        *********************************************************
    -->
    <xsl:template name="keydescriptor.breakdown">
        <xsl:param name="entities"/>
        <xsl:variable name="kd" select="$entities//md:KeyDescriptor"/>
        <xsl:variable name="kd.count" select="count($kd)"/>
        <p>
            <code>KeyDescriptor</code> elements: <xsl:value-of select="$kd.count"/>
            (<xsl:value-of select="format-number($kd.count div count($entities), '0.0')"/> per entity).
        </p>
    </xsl:template>
    
</xsl:stylesheet>