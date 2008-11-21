<?xml version="1.0" encoding="UTF-8"?>
<!--
    
    statistics.xsl
    
    XSL stylesheet taking a UK Federation metadata file and resulting in an HTML document
    giving statistics.
    
    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:shibmeta="urn:mace:shibboleth:metadata:1.0"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:members="http://ukfederation.org.uk/2007/01/members"
    xmlns:wayf="http://sdss.ac.uk/2006/06/WAYF"
    xmlns:uklabel="http://ukfederation.org.uk/2006/11/label"
    xmlns:eduservlabel="http://eduserv.org.uk/labels"
    xmlns:math="http://exslt.org/math"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:dyn="http://exslt.org/dynamic"
    xmlns:set="http://exslt.org/sets"
    exclude-result-prefixes="xsl ds shibmeta md xsi members wayf uklabel math date dyn set eduservlabel"
    version="1.0">

    <xsl:output method="html" omit-xml-declaration="yes"/>
    
    <xsl:template match="md:EntitiesDescriptor">
        
        <xsl:variable name="now" select="date:date-time()"/>

        <!--
            Pick up and break down the "members" document, which despite its name
            describes all known entity owners, whether members or non-members.
        -->
        <xsl:variable name="memberDocument" select="document('../xml/members.xml')"/>
        <!-- federation members -->
        <xsl:variable name="members" select="$memberDocument//members:Member"/>
        <xsl:variable name="memberCount" select="count($members)"/>
        <xsl:variable name="memberNames" select="$members/md:OrganizationName"/>
        <!-- federation non-member owners -->
        <xsl:variable name="nonMembers" select="$memberDocument//members:NonMember"/>
        <xsl:variable name="nonMemberCount" select="count($nonMembers)"/>
        <xsl:variable name="nonMemberNames" select="$nonMembers/md:OrganizationName"/>
        <!-- owners are the union of the above -->
        <xsl:variable name="owners" select="$members | $nonMembers"/>
        <xsl:variable name="ownerNames" select="$memberDocument//md:OrganizationName"/>
        
        <xsl:variable name="entities" select="//md:EntityDescriptor"/>
        <xsl:variable name="entityCount" select="count($entities)"/>

        <xsl:variable name="idps" select="$entities[md:IDPSSODescriptor]"/>
        <xsl:variable name="idpCount" select="count($idps)"/>
        <xsl:variable name="sps" select="$entities[md:SPSSODescriptor]"/>
        <xsl:variable name="spCount" select="count($sps)"/>
        <xsl:variable name="dualEntities" select="$entities[md:IDPSSODescriptor][md:SPSSODescriptor]"/>
        <xsl:variable name="dualEntityCount" select="count($dualEntities)"/>
        
        <xsl:variable name="concealedCount" select="count($idps[md:Extensions/wayf:HideFromWAYF])"/>
        <xsl:variable name="accountableCount"
            select="count($idps[md:Extensions/uklabel:AccountableUsers])"/>
        <xsl:variable name="federationMemberEntityCount"
            select="count($entities[md:Extensions/uklabel:UKFederationMember])"/>
        <xsl:variable name="sdssPolicyCount"
            select="count($entities[md:Extensions/uklabel:SDSSPolicy])"/>
        
        <xsl:variable name="memberEntities"
            select="dyn:closure($members/md:OrganizationName, '$entities[md:Organization/md:OrganizationName = current()]')"/>
        <xsl:variable name="memberEntityCount"
            select="dyn:sum($memberNames, 'count($entities[md:Organization/md:OrganizationName = current()])')"/>
        
        <xsl:variable name="artifactIdps"
            select="$idps[md:IDPSSODescriptor/md:ArtifactResolutionService]"/>
        <xsl:variable name="artifactIdpCount" select="count($artifactIdps)"/>
        <xsl:variable name="artifactSps"
            select="$sps[md:SPSSODescriptor/md:AssertionConsumerService/@Binding='urn:oasis:names:tc:SAML:1.0:profiles:artifact-01']"/>
        <xsl:variable name="artifactSpCount" select="count($artifactSps)"/>
        <xsl:variable name="artifactEntities" select="$artifactIdps | $artifactSps"/>
        <xsl:variable name="artifactEntityCount" select="count($artifactEntities)"/>
        
        <xsl:variable name="embeddedX509Entities" select="$entities[descendant::ds:X509Data]"/>
        <xsl:variable name="embeddedX509EntityCount" select="count($embeddedX509Entities)"/>
        
        <!--
        	Trust fabric statistics
        -->
        <xsl:variable name="pkixCapableEntities" select="$entities[descendant::ds:KeyName]"/>
        <xsl:variable name="dkeyCapableEntities" select="$entities[descendant::ds:X509Data]"/>
        <xsl:variable name="pkixEntities" select="set:difference($pkixCapableEntities, $dkeyCapableEntities)"/>
        <xsl:variable name="dkeyEntities" select="set:difference($dkeyCapableEntities, $pkixCapableEntities)"/>
        <xsl:variable name="hybridEntities" select="set:intersection($pkixCapableEntities, $dkeyCapableEntities)"/>
        <xsl:variable name="pkixEntityCount" select="count($pkixEntities)"/>
        <xsl:variable name="dkeyEntityCount" select="count($dkeyEntities)"/>
        <xsl:variable name="hybridEntityCount" select="count($hybridEntities)"/>
        
        <!--
            Look for some potential problems in the metadata.  We need to do this
            at the start so that we can include or exclude the associated section.
        -->
        <!-- spaces in entity IDs -->
        <xsl:variable name="prob.space.entityID" select="$entities[contains(@entityID, ' ')]"/>
        <!-- spaces in Locations -->
        <xsl:variable name="prob.space.location" select="$entities[descendant::*[contains(@Location,' ')]]"/>

        <!-- Locations that don't start with https:// -->
        <xsl:variable name="prob.nohttps.location.exceptions"
            select="$entities[@entityID='no.such.entity']"/>
        <xsl:variable name="prob.nohttps.location.entities"
            select="set:difference($entities, $prob.nohttps.location.exceptions)"/>
        <xsl:variable name="prob.nohttps.location"
            select="$prob.nohttps.location.entities[descendant::*[@Location and not(starts-with(@Location,'https://'))]]"/>
        
        <!-- duplicate entity IDs -->
        <xsl:variable name="prob.distinct.entityIDs" select="set:distinct($entities/@entityID)"/>
        <xsl:variable name="prob.dup.entityID"
            select="set:distinct(set:difference($entities/@entityID, $prob.distinct.entityIDs))"/>
        
        <!-- duplicate IdP OrganizationDisplayName -->
        <xsl:variable name="prob.distinct.ODNs"
            select="set:distinct($idps/md:Organization/md:OrganizationDisplayName)"/>
        <xsl:variable name="prob.dup.ODNs"
            select="set:distinct(set:difference($idps/md:Organization/md:OrganizationDisplayName, $prob.distinct.ODNs))"/>
        
        <!-- entities without known owner -->
        <xsl:variable name="ownedEntities"
            select="dyn:closure($owners/md:OrganizationName, '$entities[md:Organization/md:OrganizationName = current()]')"/>
        <xsl:variable name="prob.unowned.entities" select="set:difference($entities, $ownedEntities)"/>
        
        <!-- all problems, used as a conditional -->
        <xsl:variable name="prob.all" select="$prob.space.entityID | $prob.space.location |
            $prob.nohttps.location |
            $prob.dup.entityID | $prob.dup.ODNs | $prob.unowned.entities"/>
        <xsl:variable name="prob.count" select="count($prob.all)"/>

        <html>
            <head>
                <title>UK Federation metadata statistics</title>
            </head>
            <body>
                <h1>UK Federation metadata statistics</h1>
                <p>This document is regenerated each time the UK Federation metadata is altered.</p>
                <p>This version was created at <xsl:value-of select="$now"/>.</p>
                <p>Contents:</p>
                <ul>
                    <xsl:if test="$prob.count != 0">
                        <li><p><a href="#problems">Metadata Problems</a></p></li>                        
                    </xsl:if>
                    <li><p><a href="#members">Member Statistics</a></p></li>
                    <li><p><a href="#entities">Entity Statistics</a></p></li>
                    <li><p><a href="#bySoftware">Entities by Software</a></p></li>
                    <li><p><a href="#byOwner">Entities by Owner</a></p></li>
                    <li><p><a href="#keyedEntities">Entities with Embedded Key Material</a></p></li>
                    <li><p><a href="#accountableIdPs">Identity Provider Accountability</a></p></li>
                    <li><p><a href="#scopes">Identity Providers by Scope</a></p></li>
                    <li><p><a href="#scopesByMember">Primary Scopes by Member</a></p></li>
                    <li><p><a href="#membersByScope">Members by Primary Scope</a></p></li>
                    <li><p><a href="#undeployedMembers">Members Lacking Deployment</a></p></li>
                </ul>
                

                
                <!--
                    Metadata Problems section
                -->                
                <xsl:if test="$prob.count != 0">
                    <h2><a name="problems">Metadata Problems</a></h2>
                    <xsl:if test="count($prob.space.entityID) != 0">
                        <p>The following entities have <code>entityID</code> attributes that include space characters:</p>
                        <ul>
                            <xsl:for-each select="$prob.space.entityID">
                                <li>
                                    <xsl:value-of select="@ID"/>:
                                    "<code><xsl:value-of select="@entityID"/></code>"
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    <xsl:if test="count($prob.space.location) != 0">
                        <p>The following entities include elements with <code>Location</code> attributes
                        that include space characters:</p>
                        <ul>
                            <xsl:for-each select="$prob.space.location">
                                <li>
                                    <xsl:value-of select="@ID"/>:
                                    <code><xsl:value-of select="@entityID"/></code>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    <xsl:if test="count($prob.nohttps.location) != 0">
                        <p>The following entities include elements with <code>Location</code> attributes
                        that don't start with <code>https://</code>:</p>
                        <ul>
                            <xsl:for-each select="$prob.nohttps.location">
                                <li>
                                    <xsl:value-of select="@ID"/>:
                                    <code><xsl:value-of select="@entityID"/></code>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    <xsl:if test="count($prob.dup.entityID) != 0">
                        <p>The following entity names are used by more than one entity:</p>
                        <ul>
                            <xsl:for-each select="$prob.dup.entityID">
                                <li>
                                    <code><xsl:value-of select="."/></code>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    
                    <xsl:if test="count($prob.dup.ODNs) != 0">
                        <p>The following OrganizationDisplayName values are used by more than one IdP entity:</p>
                        <ul>
                            <xsl:for-each select="$prob.dup.ODNs">
                                <xsl:variable name="prob.dup.ODN" select="."/>
                                <li>
                                    <code><xsl:value-of select="$prob.dup.ODN"/></code>
                                    <ul>
                                        <xsl:for-each select="$idps[md:Organization/md:OrganizationDisplayName = $prob.dup.ODN]">
                                            <li>
                                                <xsl:value-of select="@ID"/>:
                                                <code><xsl:value-of select="@entityID"/></code>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    
                    <xsl:if test="count($prob.unowned.entities) != 0">
                        <p>
                            The following
                            <xsl:choose>
                                <xsl:when test="count($prob.unowned.entities) = 1">
                                    entity does not appear
                                </xsl:when>
                                <xsl:otherwise>
                                    entities do not appear
                                </xsl:otherwise>
                            </xsl:choose>
                            to have <code>OrganizationName</code> values corresponding to the registered names of
                            federation members or other known legitimate entity owners:
                        </p>
                        <ul>
                            <xsl:for-each select="$prob.unowned.entities">
                                <xsl:sort select="md:Organization/md:OrganizationName"/>
                                <li>
                                    <xsl:value-of select="md:Organization/md:OrganizationName"/>:
                                    <code><xsl:value-of select="@entityID"/></code>
                                    (<xsl:value-of select="@ID"/>)
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                </xsl:if>

                
                
                <h2><a name="members">Member Statistics</a></h2>
                <p>Number of members: <xsl:value-of select="$memberCount"/></p>
                <p>The following table shows, for each federation member, the number of entities
                belonging to that member.</p>
                <table border="1" cellspacing="2" cellpadding="4">
                    <tr>
                        <th align="left">Member</th>
                        <th>Entities</th>
                        <th>IdPs</th>
                        <th>SPs</th>
                        <th>AIdP</th>
                        <th align="left">Primary Scope</th>
                    </tr>
                    <xsl:apply-templates select="$members" mode="count">
                        <xsl:with-param name="entities" select="$entities"/>
                    </xsl:apply-templates>
                </table>
                <p>This accounts for <xsl:value-of select="$memberEntityCount"/>
                (<xsl:value-of select="format-number($memberEntityCount div $entityCount, '0.0%')"/>)
                of the <xsl:value-of select="$entityCount"/> entities in the federation metadata.</p>
                
                <xsl:variable name="memberDualEntities" select="$memberEntities[md:IDPSSODescriptor][md:SPSSODescriptor]"/>
                <xsl:variable name="memberDualEntityCount" select="count($memberDualEntities)"/>
                <xsl:variable name="memberIdps" select="$memberEntities[md:IDPSSODescriptor]"/>
                <xsl:variable name="memberIdpCount" select="count($memberIdps)"/>
                <xsl:variable name="memberSps" select="$memberEntities[md:SPSSODescriptor]"/>
                <xsl:variable name="memberSpCount" select="count($memberSps)"/>
                <p>These <xsl:value-of select="$memberEntityCount"/> entities break down into:</p>
                <ul>
                    <li>
                        <p>Identity providers: <xsl:value-of select="$memberIdpCount - $memberDualEntityCount"/></p>
                    </li>
                    <li>
                        <p>Service providers: <xsl:value-of select="$memberSpCount - $memberDualEntityCount"/></p>
                    </li>
                    <li>
                        <p>Gateways: <xsl:value-of select="$memberDualEntityCount"/></p>
                    </li>
                </ul>                

                <!--
                    Break down members by whether or not they have entities registered
                -->
                <xsl:variable name="membersWithIdPs"
                    select="$members[md:OrganizationName = $idps//md:OrganizationName]"/>
                <xsl:variable name="membersWithSps"
                    select="$members[md:OrganizationName = $sps//md:OrganizationName]"/>
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
                
                <h3>Additional Non-member Entity Owners</h3>
                <p>
                    In addition, the UK federation operator maintains agreements with certain
                    other organisations so that metadata for entities belonging to those
                    organisations can be published within the UK federation metadata for the
                    benefit of UK federation members.
                </p>
                <p>Number of non-member relationships: <xsl:value-of select="$nonMemberCount"/></p>
                <table border="1" cellspacing="2" cellpadding="4">
                    <tr>
                        <th align="left">Non-member agreement</th>
                        <th>Entities</th>
                        <th>IdPs</th>
                        <th>SPs</th>
                        <th>AIdP</th>
                        <th align="left">Scope</th>
                    </tr>
                    <xsl:apply-templates select="$nonMembers" mode="count">
                        <xsl:with-param name="entities" select="$entities"/>
                    </xsl:apply-templates>
                </table>
                

                <h2><a name="entities">Entity Statistics</a></h2>
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
                            <xsl:value-of select="$sdssPolicyCount"/>
                            (<xsl:value-of select="format-number($sdssPolicyCount div $entityCount, '0.0%')"/>)
                            are labelled as having been owned by organisations asserting that they would
                            follow the SDSS Federation policy.
                        </p>
                    </li>
                    <li>
                        <p>
                            <xsl:value-of select="$artifactEntityCount"/>
                            (<xsl:value-of select="format-number($artifactEntityCount div $entityCount, '0.0%')"/>)
                            support the Browser/Artifact profile.
                        </p>
                    </li>
                    <li>
                        <p>
                            <xsl:value-of select="$embeddedX509EntityCount"/>
                            (<xsl:value-of select="format-number($embeddedX509EntityCount div $entityCount, '0.0%')"/>)
                            <xsl:choose>
                                <xsl:when test="$embeddedX509EntityCount = 1">
                                    has
                                </xsl:when>
                                <xsl:otherwise>
                                    have
                                </xsl:otherwise>
                            </xsl:choose>
                            at least one embedded <code>ds:X509Data</code> element providing explicit key material.
                        </p>
                    </li>

                    <xsl:variable name="exampleEntities" select="$entities[contains(md:Organization/md:OrganizationURL, 'example')]"/>
                    <xsl:variable name="exampleEntityCount" select="count($exampleEntities)"/>
                    <xsl:if test="$exampleEntityCount != 0">
                        <li>
                            <p>
                                <xsl:value-of select="$exampleEntityCount"/>
                                (<xsl:value-of select="format-number($exampleEntityCount div $entityCount, '0.0%')"/>)
                                <xsl:choose>
                                    <xsl:when test="$exampleEntityCount = 1">
                                        has
                                    </xsl:when>
                                    <xsl:otherwise>
                                        have
                                    </xsl:otherwise>
                                </xsl:choose>
                                legacy "example" <code>OrganizationURL</code> elements.
                            </p>
                        </li>
                    </xsl:if>

                </ul>

                <p>Trust models:</p>
                <ul>
                    <li>
                        <p>
                            PKIX only:
                            <xsl:value-of select="$pkixEntityCount"/>
                            (<xsl:value-of select="format-number($pkixEntityCount div $entityCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Hybrid (PKIX and direct key):
                            <xsl:value-of select="$hybridEntityCount"/>
                            (<xsl:value-of select="format-number($hybridEntityCount div $entityCount, '0.0%')"/>)
                        </p>
                    </li>
                    <li>
                        <p>
                            Direct key only:
                            <xsl:value-of select="$dkeyEntityCount"/>
                            (<xsl:value-of select="format-number($dkeyEntityCount div $entityCount, '0.0%')"/>)
                        </p>
                    </li>
                </ul>

                <h3>Identity Providers</h3>
                <p>There are <xsl:value-of select="$idpCount"/> identity providers,
                including <xsl:value-of select="$dualEntityCount"/>
                dual-nature entities (both identity and service providers in one).</p>
                <p>Of these:</p>
                <ul>
                    <li>
                        <p>Hidden from main WAYF: <xsl:value-of select="$concealedCount"/>
                        (<xsl:value-of select="format-number($concealedCount div $idpCount, '0.0%')"/>).</p>
                    </li>
                    <li>
                        <p>Asserting user accountability: <xsl:value-of select="$accountableCount"/>
                        (<xsl:value-of select="format-number($accountableCount div $idpCount, '0.0%')"/>).</p>
                    </li>
                    <li>
                        <p>
                            Support Browser/Artifact: <xsl:value-of select="$artifactIdpCount"/>
                            (<xsl:value-of select="format-number($artifactIdpCount div $idpCount, '0.0%')"/>).
                        </p>
                    </li>
                </ul>
                
                <h3>Service Providers</h3>
                <p>There are <xsl:value-of select="$spCount"/> service providers,
                    including <xsl:value-of select="$dualEntityCount"/>
                    dual-nature entities (both identity and service providers in one).</p>
                <p>Of these:</p>
                <ul>
                    <li>
                        <p>
                            Support Browser/Artifact: <xsl:value-of select="$artifactSpCount"/>
                            (<xsl:value-of select="format-number($artifactSpCount div $spCount, '0.0%')"/>).
                        </p>
                    </li>
                </ul>
                
                <h2><a name="bySoftware">Entities by Software</a></h2>

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
                        md:Extensions/uklabel:Software
                            [@name != 'Shibboleth']
                            [@name != 'EZproxy']
                            [@name != 'OpenAthens SP']
                            [@name != 'Guanxi']
                    ]"/>
                <xsl:variable name="entities.misc.out"
                    select="set:difference($entities.misc.in, $entities.misc)"/>
                
                <!--
                    Classify EZproxy SPs
                -->
                <xsl:variable name="entities.ezproxy.in" select="$entities.misc.out"/>
                <xsl:variable name="entities.ezproxy"
                    select="$entities.ezproxy.in[md:Extensions/uklabel:Software/@name='EZproxy']"/>
                <xsl:variable name="entities.ezproxy.out"
                    select="set:difference($entities.ezproxy.in, $entities.ezproxy)"/>

                <!--
                    Classify OpenAthens SP entities.
                -->
                <xsl:variable name="entities.openathenssp.in" select="$entities.ezproxy.out"/>
                <xsl:variable name="entities.openathenssp"
                    select="$entities.openathenssp.in[md:Extensions/uklabel:Software/@name='OpenAthens SP']"/>
                <xsl:variable name="entities.openathenssp.count" select="count($entities.openathenssp)"/>
                <xsl:variable name="entities.openathenssp.out"
                    select="set:difference($entities.openathenssp.in, $entities.openathenssp)"/>
                
                <!--
                    Classify Shibboleth 2.0 IdPs and SPs.
                -->
                <xsl:variable name="entities.shib.2.in" select="$entities.openathenssp.out"/>
                <xsl:variable name="entities.shib.2"
                    select="$entities.shib.2.in[
                        md:IDPSSODescriptor/md:SingleSignOnService[contains(@Location, '/profile/Shibboleth/SSO')] |
                        md:SPSSODescriptor/md:AssertionConsumerService[contains(@Location, '/Shibboleth.sso/SAML2/POST')] |
                        md:Extensions/uklabel:Software[@name='Shibboleth'][@version = '2']
                    ]"/>
                <xsl:variable name="idps.shib.2" select="$entities.shib.2[md:IDPSSODescriptor]"/>
                <xsl:variable name="sps.shib.2" select="$entities.shib.2[md:SPSSODescriptor]"/>
                <xsl:variable name="entities.shib.2.out"
                    select="set:difference($entities.shib.2.in, $entities.shib.2)"/>

                <!--
                    Classify Shibboleth 1.3 entities.
                -->
                <xsl:variable name="entities.shib.13.in" select="$entities.shib.2.out"/>
                <xsl:variable name="entities.shib.13.knownHere" select="
                    $entities.shib.13.in[@entityID='urn:mace:ac.uk:sdss.ac.uk:provider:identity:shib.ncl.ac.uk'] |
                    $entities.shib.13.in[@entityID='https://typekey.sdss.ac.uk/shibboleth'] |
                    $entities.shib.13.in[@entityID='https://typekey.iay.org.uk/shibboleth'] |
                    $entities.shib.13.in[@entityID='https://idp-1.bgfl.org/shibboleth'] |
                    $entities.shib.13.in[@entityID='urn:mace:ac.uk:sdss.ac.uk:provider:identity:shibboleth-i.sgul.ac.uk'] |
                    $entities.shib.13.in[@entityID='https://idp.protectnetwork.org/protectnetwork-idp'] |
                    $entities.shib.13.in[@entityID='urn:mace:ac.uk:sdss.ac.uk:provider:service:dangermouse.ncl.ac.uk'] |
                    $entities.shib.13.in[@entityID='https://spie.oucs.ox.ac.uk/shibboleth/wiki'] |
                    $entities.shib.13.in[@entityID='https://sdauth.sciencedirect.com/']
                "/>
                <xsl:variable name="entities.shib.13.unknownHere"
                    select="set:difference($entities.shib.13.in, $entities.shib.13.knownHere)"/>
                <xsl:variable name="entities.shib.13.known" select="
                    $entities.shib.13.unknownHere[md:Extensions/uklabel:Software[@name='Shibboleth'][@version = '1.3']] |
                    $entities.shib.13.knownHere
                "/>
                <xsl:variable name="entities.shib.13.unknown"
                    select="set:difference($entities.shib.13.in, $entities.shib.13.known)"/>
                <xsl:variable name="entities.shib.13"
                    select="$entities.shib.13.in[
                        md:IDPSSODescriptor/md:SingleSignOnService[contains(@Location, '-idp/SSO')] |
                        md:SPSSODescriptor/md:AssertionConsumerService[contains(@Location, 'Shibboleth.sso')]
                    ] | $entities.shib.13.known"/>
                <xsl:variable name="entities.shib.13.count" select="count($entities.shib.13)"/>
                <xsl:variable name="entities.shib.13.out"
                    select="set:difference($entities.shib.13.in, $entities.shib.13)"/>
                
                <!--
                    Classify Athens Gateway entities
                -->
                <xsl:variable name="entities.gateways.in" select="$entities.shib.13.out"/>
                <xsl:variable name="knownGateways" select="
                    $entities.gateways.in[@entityID='urn:mace:eduserv.org.uk:athens:federation:beta'] |
                    $entities.gateways.in[@entityID='urn:mace:eduserv.org.uk:athens:federation:uk']
                    "/>
                <xsl:variable name="gatewayCount" select="count($knownGateways)"/>
                <xsl:variable name="entities.gateways.out"
                    select="set:difference($entities.gateways.in, $knownGateways)"/>
                
                <!--
                    Classify OpenAthens virtual IdPs.
                -->
                <xsl:variable name="entities.openathens.virtual.in" select="$entities.gateways.out"/>
                <xsl:variable name="entities.openathens.virtual"
                    select="$entities.openathens.virtual.in[md:Extensions/eduservlabel:AthensPUIDAuthority]"/>
                <xsl:variable name="entities.openathens.virtual.count"
                    select="count($entities.openathens.virtual)"/>
                <xsl:variable name="entities.openathens.virtual.out"
                    select="set:difference($entities.openathens.virtual.in, $entities.openathens.virtual)"/>
                
                <!--
                    Classify Guanxi entities.
                -->
                <xsl:variable name="entities.guanxi.in" select="$entities.openathens.virtual.out"/>
                <xsl:variable name="entities.guanxi"
                    select="$entities.guanxi.in[md:Extensions/uklabel:Software/@name='Guanxi']"/>
                <xsl:variable name="entities.guanxi.count" select="count($entities.guanxi)"/>
                <xsl:variable name="entities.guanxi.out"
                    select="set:difference($entities.guanxi.in, $entities.guanxi)"/>
                
                <!--
                    Variables containing all classified and unclassified entities, respectively.
                -->
                <xsl:variable name="entities.unclassified" select="$entities.guanxi.out"/>
                <xsl:variable name="entities.classified"
                    select="set:difference($entities, $entities.unclassified)"/>

                <!--
                    Things become more ad hoc below this point.  In the long run, these algorithms should be
                    put on the same "chained" footing as the ones above.
                -->

                <!--
                    Classify AthensIM entities
                -->
                <xsl:variable name="athensImEntities"
                    select="$idps/descendant::md:SingleSignOnService[contains(@Location, '/origin/hs')]/ancestor::md:EntityDescriptor"/>
                <xsl:variable name="athensImEntityCount" select="count($athensImEntities)"/>

                <!--
                    Remaining entities are unknown.
                -->                
                <xsl:variable name="knownSoftwareEntities"
                    select="$entities.classified | $athensImEntities"/>
                <xsl:variable name="unknownSoftwareEntities"
                    select="set:difference($entities, $knownSoftwareEntities) | $entities.misc"/>
                <xsl:variable name="unknownSoftwareEntityCount" select="count($unknownSoftwareEntities)"/>
                
                <!--
                    ***************************************************************
                    ***                                                         ***
                    ***   R E P O R T   C L A S S I F I E D   E N T I T I E S   ***
                    ***                                                         ***
                    ***************************************************************
                -->
                
                <h3>Shibboleth 2</h3>
                <p>
                    There are <xsl:value-of select="count($entities.shib.2)"/> entities in the metadata
                    running Shibboleth 2.
                    This is <xsl:value-of select="format-number(count($entities.shib.2) div $entityCount, '0.0%')"/>
                    of all entities.
                </p>
                
                <h4>Shibboleth 2 Identity Providers</h4>
                <p>
                    The following <xsl:value-of select="count($idps.shib.2)"/> identity providers are
                    running Shibboleth 2.
                    This is <xsl:value-of select="format-number(count($idps.shib.2) div $idpCount, '0.0%')"/>
                    of all identity providers.</p>
                <ul>
                    <xsl:for-each select="$idps.shib.2">
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <code><xsl:value-of select="@entityID"/></code>:
                            <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>.
                        </li>
                    </xsl:for-each>
                </ul>
                
                <h4>Shibboleth 2 Service Providers</h4>
                <p>
                    The following service providers are running Shibboleth 2.
                    This is <xsl:value-of select="format-number(count($sps.shib.2) div $spCount, '0.0%')"/>
                    of all service providers.
                </p>
                <ul>
                    <xsl:for-each select="$sps.shib.2">
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <code><xsl:value-of select="@entityID"/></code>
                        </li>
                    </xsl:for-each>
                </ul>
                
                <h3>Shibboleth 1.3</h3>
                <p>
                    We have verified with the owners that the following entities are running Shibboleth 1.3, even
                    if that does not appear to be the case from their metadata:
                </p>
                <ul>
                    <xsl:for-each select="$entities.shib.13.known">
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <code><xsl:value-of select="@entityID"/></code>
                        </li>
                    </xsl:for-each>
                </ul>
                <p>
                    Including the above, there are
                    <xsl:value-of select="$entities.shib.13.count"/> entities in the metadata that look like they are probably
                    running Shibboleth 1.3.  This is <xsl:value-of select="format-number($entities.shib.13.count div $entityCount, '0.0%')"/>
                    of all entities.
                </p>
                
                <xsl:variable name="entitiesShib" select="$entities.shib.13 | $entities.shib.2"/>
                <xsl:variable name="entitiesShibCount" select="count($entitiesShib)"/>
                <h3>Shibboleth Combined</h3>
                <p>
                    Combining all versions of the Shibboleth reference software gives a total of
                    <xsl:value-of select="$entitiesShibCount"/> entities, or
                    <xsl:value-of select="format-number($entitiesShibCount div $entityCount, '0.0%')"/>
                    of all entities.
                </p>
                <p>
                    This means that
                    <xsl:value-of select="$entityCount - $entitiesShibCount"/> entities
                    (<xsl:value-of select="format-number(($entityCount - $entitiesShibCount) div $entityCount, '0.0%')"/>)
                    are running something other than the Shibboleth reference software.
                </p>
                
                <xsl:variable name="entities.ezproxy.count" select="count($entities.ezproxy)"/>
                <xsl:if test="$entities.ezproxy.count != 0">
                    <h3>EZproxy Entities</h3>
                    <p>
                        <xsl:if test="$entities.ezproxy.count = 1">
                            There is 1 entity in the metadata that appears to be
                            running EZproxy service provider software.
                        </xsl:if>
                        <xsl:if test="$entities.ezproxy.count != 1">
                            There are <xsl:value-of select="$entities.ezproxy.count"/> entities
                            in the metadata that
                            appear to be running EZproxy service provider software.
                        </xsl:if>
                        This is <xsl:value-of select="format-number($entities.ezproxy.count div $entityCount, '0.0%')"/>
                        of all entities, or <xsl:value-of select="format-number($entities.ezproxy.count div $spCount, '0.0%')"/>
                        of service providers.
                    </p>
                    <ul>
                        <xsl:for-each select="$entities.ezproxy">
                            <li>
                                <xsl:value-of select="@ID"/>:
                                <code><xsl:value-of select="@entityID"/></code>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                
                <!--
                    AthensIM entities
                -->
                <xsl:if test="$athensImEntityCount != 0">
                    <h3>AthensIM Entities</h3>
                    <p>
                        <xsl:if test="$athensImEntityCount = 1">
                            There is 1 entity in the metadata that appears to be
                            running AthensIM identity provider software.
                        </xsl:if>
                        <xsl:if test="$athensImEntityCount != 1">
                            There are <xsl:value-of select="$athensImEntityCount"/> entities in the metadata that
                            appear to be running AthensIM identity provider software.
                        </xsl:if>
                        This is <xsl:value-of select="format-number($athensImEntityCount div $entityCount, '0.0%')"/>
                        of all entities, or <xsl:value-of select="format-number($athensImEntityCount div $idpCount, '0.0%')"/>
                        of identity providers.
                    </p>
                    <ul>
                        <xsl:for-each select="$athensImEntities">
                            <li>
                                <xsl:value-of select="@ID"/>:
                                <code><xsl:value-of select="@entityID"/></code>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>

                <!--
                    Guanxi entities.  Currently assumed to be identity providers only.
                -->                
                <xsl:if test="$entities.guanxi.count != 0">
                    <h3>Guanxi Entities</h3>
                    <p>
                        <xsl:if test="$entities.guanxi.count = 1">
                            The following entity is known to be running the Guanxi software:
                        </xsl:if>
                        <xsl:if test="$entities.guanxi.count != 1">
                            The following entities are known to be running the Guanxi software:
                        </xsl:if>
                    </p>
                    <ul>
                        <xsl:for-each select="$entities.guanxi">
                            <li>
                                <xsl:value-of select="@ID"/>:
                                <code><xsl:value-of select="@entityID"/></code>:
                                <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>.
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                
                <!--
                    Athens Gateway entities.
                -->
                <xsl:if test="$gatewayCount != 0">
                    <h3>Gateway Entities</h3>
                    <p>
                        <xsl:if test="$gatewayCount = 1">
                            The following entity is known to be running Athens/Shibboleth gateway software:
                        </xsl:if>
                        <xsl:if test="$gatewayCount != 1">
                            The following entities are known to be running Athens/Shibboleth gateway software:
                        </xsl:if>
                    </p>
                    <ul>
                        <xsl:for-each select="$knownGateways">
                            <li>
                                <xsl:value-of select="@ID"/>:
                                <code><xsl:value-of select="@entityID"/></code>:
                                <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>.
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                
                <!--
                    OpenAthens virtual IdPs
                -->
                <xsl:if test="$entities.openathens.virtual.count != 0">
                    <h3>OpenAthens Virtual Identity Providers</h3>
                    <p>
                        The following <xsl:value-of select="$entities.openathens.virtual.count"/>
                        entities are virtual identity providers run by Eduserv
                        as part of the OpenAthens system on behalf of their clients:
                    </p>
                    <ul>
                        <xsl:for-each select="$entities.openathens.virtual">
                            <li>
                                <xsl:value-of select="@ID"/>:
                                <code><xsl:value-of select="@entityID"/></code>:
                                <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>.
                            </li>
                        </xsl:for-each>
                    </ul>
                    <p>
                        This is
                        <xsl:value-of select="format-number($entities.openathens.virtual.count div $entityCount, '0.0%')"/>
                        of all entities, or
                        <xsl:value-of select="format-number($entities.openathens.virtual.count div $idpCount, '0.0%')"/>
                        of identity providers.
                    </p>
                </xsl:if>
                
                <!--
                    OpenAthens SP entities.
                -->
                <xsl:if test="$entities.openathenssp.count != 0">
                    <h3>OpenAthens SP Entities</h3>
                    <p>
                        <xsl:if test="$entities.openathenssp.count = 1">
                            There is 1 entity in the metadata running
                            OpenAthens SP
                            service provider software.
                        </xsl:if>
                        <xsl:if test="$entities.openathenssp.count != 1">
                            There are <xsl:value-of select="$entities.openathenssp.count"/>
                            entities in the metadata running
                            OpenAthens SP
                            service provider software.
                        </xsl:if>
                    </p>
                    <ul>
                        <xsl:for-each select="$entities.openathenssp">
                            <li>
                                <xsl:value-of select="@ID"/>:
                                <code><xsl:value-of select="@entityID"/></code>
                            </li>
                        </xsl:for-each>
                    </ul>
                    <p>
                        This is <xsl:value-of select="format-number($entities.openathenssp.count div $entityCount, '0.0%')"/>
                        of all entities, or <xsl:value-of select="format-number($entities.openathenssp.count div $spCount, '0.0%')"/>
                        of service providers.
                    </p>
                </xsl:if>

                <!--
                    Unknown entities.
                -->
                <h3>Unknown or Other Software</h3>
                <p>
                    There are <xsl:value-of select="$unknownSoftwareEntityCount"/> entities in the metadata that
                    don't fall into any of the categories above.
                    This is <xsl:value-of select="format-number($unknownSoftwareEntityCount div $entityCount, '0.0%')"/>
                    of all entities.
                </p>
                <ul>
                    <xsl:for-each select="$unknownSoftwareEntities">
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <code><xsl:value-of select="@entityID"/></code>
                            <xsl:choose>
                                <xsl:when test="@entityID = 'https://adfs.devnet3.plymouth.ac.uk'">
                                    (Microsoft ADFS)
                                </xsl:when>
                                <xsl:when test="@entityID = 'https://www.educationcity.com/sso/shib'">
                                    (proprietary implementation)
                                </xsl:when>
                                <xsl:when test="md:Extensions/uklabel:Software">
                                    (<xsl:value-of select="md:Extensions/uklabel:Software/@name"/>)
                                </xsl:when>
                            </xsl:choose>
                        </li>
                    </xsl:for-each>
                </ul>
                
                <h2><a name="byOwner">Entities by Owner</a></h2>
                <ul>
                    <xsl:apply-templates select="$ownerNames" mode="enumerate">
                        <xsl:with-param name="entities" select="$entities"/>
                    </xsl:apply-templates>
                </ul>
                
                <h2><a name="keyedEntities">Entities with Embedded Key Material</a></h2>
                <ul>
                    <xsl:for-each select="$embeddedX509Entities">
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <code><xsl:value-of select="@entityID"/></code>
                        </li>
                    </xsl:for-each>
                </ul>
                
                <h2><a name="accountableIdPs">Identity Provider Accountability</a></h2>
                <h3>Asserting User Accountability</h3>
                <ul>
                    <xsl:for-each select="$idps[md:Extensions/uklabel:AccountableUsers]">
                        <xsl:sort select="md:Organization/md:OrganizationDisplayName"/>
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <xsl:if test="not(md:Extensions/uklabel:UKFederationMember)">[not-M] </xsl:if>
                            <xsl:if test="md:Extensions/wayf:HideFromWAYF">[H] </xsl:if>
                            <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>
                        </li>
                    </xsl:for-each>
                </ul>
                
                <h3>Not Asserting User Accountability</h3>
                <ul>
                    <xsl:for-each select="$idps[not(md:Extensions/uklabel:AccountableUsers)]">
                        <xsl:sort select="md:Organization/md:OrganizationDisplayName"/>
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <xsl:if test="not(md:Extensions/uklabel:UKFederationMember)">[not-M] </xsl:if>
                            <xsl:if test="md:Extensions/wayf:HideFromWAYF">[H] </xsl:if>
                            <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>
                        </li>
                    </xsl:for-each>
                </ul>

                <!--
                    *****************************************************************
                    ***                                                           ***
                    ***   I D E N T I T Y   P R O V I D E R S   B Y   S C O P E   ***
                    ***                                                           ***
                    *****************************************************************
                -->                
                <h2><a name="scopes">Identity Providers by Scope</a></h2>
                <xsl:variable name="allScopes" select="set:distinct($idps//shibmeta:Scope)"/>
                <ul>
                    <xsl:for-each select="$allScopes">
                        <xsl:sort select="."/>
                        <xsl:variable name="thisScope" select="string(.)"/>
                        <xsl:variable name="thisScopeIdPs"
                            select="$idps//shibmeta:Scope[.=$thisScope]/ancestor::md:EntityDescriptor"/>
                        <xsl:variable name="thisScopeIdPCount" select="count($thisScopeIdPs)"/>
                        <li>
                            <xsl:value-of select="$thisScope"/>:
                            <xsl:choose>
                                <xsl:when test="$thisScopeIdPCount = 1">
                                    <xsl:value-of select="$thisScopeIdPs/md:Organization/md:OrganizationDisplayName"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <ul>
                                        <xsl:for-each select="$thisScopeIdPs">
                                            <xsl:sort select="md:Organization/md:OrganizationDisplayName"/>
                                            <li>
                                                <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:otherwise>
                            </xsl:choose>
                        </li>
                    </xsl:for-each>
                </ul>
                
                <!--
                    ***********************************************************
                    ***                                                     ***
                    ***   P R I M A R Y   S C O P E S   B Y   M E M B E R   ***
                    ***                                                     ***
                    ***********************************************************
                -->
                <h2><a name="scopesByMember">Primary Scopes by Member</a></h2>
                <table border="1" cellspacing="2" cellpadding="4">
                    <tr>
                        <th align="left">Member</th>
                        <th align="left">Primary Scope</th>
                    </tr>
                    <xsl:variable name="membersWithScopes"
                        select="$members[descendant::members:Scope[@isPrimary='true']]"/>
                    <xsl:for-each select="$membersWithScopes">
                        <xsl:sort select="md:OrganizationName"/>
                        <tr>
                            <td><xsl:value-of select="md:OrganizationName"/></td>
                            <td><code><xsl:value-of select="descendant::members:Scope[@isPrimary='true'][position()=1]"/></code></td>
                        </tr>
                    </xsl:for-each>
                </table>
                
                <!--
                    ***********************************************************
                    ***                                                     ***
                    ***   P R I M A R Y   S C O P E S   B Y   M E M B E R   ***
                    ***                                                     ***
                    ***********************************************************
                -->
                <h2><a name="membersByScope">Members by Primary Scope</a></h2>
                <table border="1" cellspacing="2" cellpadding="4">
                    <tr>
                        <th align="left">Primary Scope</th>
                        <th align="left">Member</th>
                    </tr>
                    <xsl:variable name="membersWithScopes"
                        select="$members[descendant::members:Scope[@isPrimary='true']]"/>
                    <xsl:for-each select="$membersWithScopes">
                        <xsl:sort select="descendant::members:Scope[@isPrimary='true'][position()=1]"/>
                        <tr>
                            <td><code><xsl:value-of select="descendant::members:Scope[@isPrimary='true'][position()=1]"/></code></td>
                            <td><xsl:value-of select="md:OrganizationName"/></td>
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
                            <xsl:value-of select="md:OrganizationName"/>
                        </li>
                    </xsl:for-each>
                </ul>                
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="members:Member|members:NonMember" mode="count">
        <xsl:param name="entities"/>
        <xsl:variable name="myName" select="string(md:OrganizationName)"/>
        <xsl:variable name="matched" select="$entities[md:Organization/md:OrganizationName = $myName]"/>
        <xsl:variable name="primaryScope" select="members:Scopes/members:Scope[@isPrimary='true'][position()=1]"/>
        <tr>
            <td><xsl:value-of select="$myName"/></td>
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
            <!-- has Athens IdP access? -->
            <td align="center">
                <xsl:choose>
                    <xsl:when test="@usesAthensIdP = 'true'">
                        *
                    </xsl:when>
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
    
    <xsl:template match="md:OrganizationName" mode="enumerate">
        <xsl:param name="entities"/>
        <xsl:variable name="myName" select="."/>
        <xsl:variable name="matched" select="$entities[md:Organization/md:OrganizationName = $myName]"/>
        <xsl:if test="count($matched) != 0">
            <li>
                <p><xsl:value-of select="$myName"/>:</p>
                <ul>
                    <xsl:for-each select="$matched">
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <xsl:if test="not(md:Extensions/uklabel:UKFederationMember)">[not-M] </xsl:if>
                            <xsl:if test="md:IDPSSODescriptor">[IdP] </xsl:if>
                            <xsl:if test="md:SPSSODescriptor">[SP] </xsl:if>
                            <code><xsl:value-of select="@entityID"/></code>
                        </li>
                    </xsl:for-each>
                </ul>
            </li>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>