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
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    exclude-result-prefixes="xsl ds shibmeta md xsi members wayf uklabel math date dyn set eduservlabel idpdisc"
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

        <!-- missing Binding attribute on DiscoveryServiceResponse elements -->
        <xsl:variable name="prob.discovery.binding.missing"
            select="$entities[descendant::idpdisc:DiscoveryResponse[not(@Binding)]]"/>
        
        <!-- wrong Binding attribute value on DiscoveryServiceResponse elements -->
        <xsl:variable name="prob.discovery.binding.wrong"
            select="$entities[descendant::idpdisc:DiscoveryResponse[@Binding]
                [@Binding!='urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol']]"/>
        
        <!-- all problems, used as a conditional -->
        <xsl:variable name="prob.all" select="$prob.space.entityID | $prob.space.location |
            $prob.nohttps.location | $prob.discovery.binding.missing | $prob.discovery.binding.wrong |
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
                    <li><p><a href="#byOwner">Entities by Owner</a></p></li>
                    <li><p><a href="#accountableIdPs">Identity Provider Accountability</a></p></li>
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
                    
                    <xsl:if test="count($prob.discovery.binding.missing) != 0">
                        <p>
                            The following
                            <xsl:choose>
                                <xsl:when test="count($prob.discovery.binding.missing) = 1">
                                    entity has a discovery response element
                                </xsl:when>
                                <xsl:otherwise>
                                    entities have discovery response elements
                                </xsl:otherwise>
                            </xsl:choose>
                            lacking a <code>Binding</code> attribute:
                        </p>
                        <ul>
                            <xsl:for-each select="$prob.discovery.binding.missing">
                                <xsl:sort select="@ID"/>
                                <li>
                                    <xsl:value-of select="@ID"/>:
                                    <code><xsl:value-of select="@entityID"/></code>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    
                    <xsl:if test="count($prob.discovery.binding.wrong) != 0">
                        <p>
                            The following
                            <xsl:choose>
                                <xsl:when test="count($prob.discovery.binding.missing) = 1">
                                    entity has a discovery response element
                                </xsl:when>
                                <xsl:otherwise>
                                    entities have discovery response elements
                                </xsl:otherwise>
                            </xsl:choose>
                            with an unrecognised <code>Binding</code> value:
                        </p>
                        <ul>
                            <xsl:for-each select="$prob.discovery.binding.wrong">
                                <xsl:sort select="@ID"/>
                                <li>
                                    <xsl:value-of select="@ID"/>:
                                    <code><xsl:value-of select="@entityID"/></code>
                                    (<code><xsl:value-of select="descendant::idpdisc:DiscoveryResponse/@Binding"/></code>)
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

                <xsl:call-template name="entity.breakdown.by.trust">
                    <xsl:with-param name="entities" select="$entities"/>
                </xsl:call-template>
                <xsl:call-template name="entity.breakdown.by.software">
                    <xsl:with-param name="entities" select="$entities"/>
                </xsl:call-template>



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
                            Support artifact resolution: <xsl:value-of select="$artifactIdpCount"/>
                            (<xsl:value-of select="format-number($artifactIdpCount div $idpCount, '0.0%')"/>).
                        </p>
                    </li>
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
                    
                    <xsl:variable name="idp.sso.saml.2.0"
                        select="$idps[contains(md:IDPSSODescriptor/@protocolSupportEnumeration,
                        'urn:oasis:names:tc:SAML:2.0:protocol')]"/>
                    <xsl:variable name="idp.sso.saml.2.0.count" select="count($idp.sso.saml.2.0)"/>
                    <li>
                        <p>
                            SAML 2.0 SSO: <xsl:value-of select="$idp.sso.saml.2.0.count"/>
                            (<xsl:value-of select="format-number($idp.sso.saml.2.0.count div $idpCount, '0.0%')"/>)
                        </p>
                    </li>
                    
                </ul>

                <xsl:call-template name="entity.breakdown.by.trust">
                    <xsl:with-param name="entities" select="$idps"/>
                </xsl:call-template>
                <xsl:call-template name="entity.breakdown.by.software">
                    <xsl:with-param name="entities" select="$idps"/>
                </xsl:call-template>




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
                    
                </ul>
                
                <xsl:call-template name="entity.breakdown.by.trust">
                    <xsl:with-param name="entities" select="$sps"/>
                </xsl:call-template>
                <xsl:call-template name="entity.breakdown.by.software">
                    <xsl:with-param name="entities" select="$sps"/>
                </xsl:call-template>

                
                
                <h2><a name="byOwner">Entities by Owner</a></h2>
                <ul>
                    <xsl:apply-templates select="$ownerNames" mode="enumerate">
                        <xsl:with-param name="entities" select="$entities"/>
                    </xsl:apply-templates>
                </ul>
                <h2><a name="accountableIdPs">Identity Provider Accountability</a></h2>
                
                <p>
                    The following entities are visible in the main federation WAYF list
                    but do not assert user accountability:
                </p>
                <ul>
                    <xsl:for-each select="$idps[not(md:Extensions/uklabel:AccountableUsers)]
                            [not(md:Extensions/wayf:HideFromWAYF)]">
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
                            <xsl:value-of select="@ID"/>
                            <xsl:text>:</xsl:text>
                            <xsl:if test="not(md:Extensions/uklabel:UKFederationMember)"> [not-M]</xsl:if>
                            <xsl:if test="md:IDPSSODescriptor"> [IdP]</xsl:if>
                            <xsl:if test="md:SPSSODescriptor"> [SP]</xsl:if>
                            <xsl:apply-templates select="md:Extensions/uklabel:Software" mode="short"/>
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
    <xsl:template match="uklabel:Software" mode="short">
        <xsl:text> [</xsl:text>
        <xsl:choose>
            <xsl:when test="@name = 'Shibboleth'">
                <xsl:text>Shib</xsl:text>
            </xsl:when>
            <xsl:when test="@name='OpenAthens SP'">
                <xsl:text>OASP</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@name"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="@fullVersion">
                <xsl:text> </xsl:text>
                <xsl:value-of select="@fullVersion"/>
            </xsl:when>
            <xsl:when test="@version">
                <xsl:text> </xsl:text>
                <xsl:value-of select="@version"/>
            </xsl:when>
        </xsl:choose>
        <xsl:text>]</xsl:text>
    </xsl:template>



    <!--
        Break down a set of entities by the trust models available.
    -->
    <xsl:template name="entity.breakdown.by.trust">
        <xsl:param name="entities"/>
        <xsl:variable name="entityCount" select="count($entities)"/>
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
                    md:Extensions/uklabel:Software
                        [@name != 'Shibboleth']
                        [@name != 'EZproxy']
                        [@name != 'OpenAthens SP']
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
                select="$entities.ezproxy.in[md:Extensions/uklabel:Software/@name='EZproxy']"/>
            <xsl:variable name="entities.ezproxy.out"
                select="set:difference($entities.ezproxy.in, $entities.ezproxy)"/>

            <!--
                Classify simpleSAMLphp entities.
            -->
            <xsl:variable name="entities.simplesamlphp.in" select="$entities.ezproxy.out"/>
            <xsl:variable name="entities.simplesamlphp"
                select="$entities.simplesamlphp.in[md:Extensions/uklabel:Software/@name='simpleSAMLphp']"/>
            <xsl:variable name="entities.simplesamlphp.out"
                select="set:difference($entities.simplesamlphp.in, $entities.simplesamlphp)"/>
            
            <!--
                Classify Atypon SAML SP entities.
            -->
            <xsl:variable name="entities.atyponsamlsp.in" select="$entities.simplesamlphp.out"/>
            <xsl:variable name="entities.atyponsamlsp"
                select="$entities.atyponsamlsp.in[md:Extensions/uklabel:Software/@name='Atypon SAML SP 1.1/2.0']"/>
            <xsl:variable name="entities.atyponsamlsp.out"
                select="set:difference($entities.atyponsamlsp.in, $entities.atyponsamlsp)"/>
            
            <!--
                Classify OpenAthens SP entities.
            -->
            <xsl:variable name="entities.openathenssp.in" select="$entities.atyponsamlsp.out"/>
            <xsl:variable name="entities.openathenssp"
                select="$entities.openathenssp.in[md:Extensions/uklabel:Software/@name='OpenAthens SP']"/>
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
            <xsl:variable name="entities.shib.2.out"
                select="set:difference($entities.shib.2.in, $entities.shib.2)"/>

            <!--
                Classify Shibboleth 1.3 entities.
            -->
            <xsl:variable name="entities.shib.13.in" select="$entities.shib.2.out"/>
            <xsl:variable name="entities.shib.13"
                select="$entities.shib.13.in[
                    md:Extensions/uklabel:Software[@name='Shibboleth'][@version = '1.3'] |
                    md:IDPSSODescriptor/md:SingleSignOnService[contains(@Location, '-idp/SSO')] |
                    md:SPSSODescriptor/md:AssertionConsumerService[contains(@Location, 'Shibboleth.sso')]
                ]"/>
            <xsl:variable name="entities.shib.13.out"
                select="set:difference($entities.shib.13.in, $entities.shib.13)"/>
            
            <!--
                Classify Athens Gateway entities
            -->
            <xsl:variable name="entities.gateways.in" select="$entities.shib.13.out"/>
            <xsl:variable name="entities.gateways"
                select="$entities.gateways.in[md:Extensions/uklabel:Software/@name='Eduserv Gateway']"/>
            <xsl:variable name="entities.gateways.out"
                select="set:difference($entities.gateways.in, $entities.gateways)"/>
            
            <!--
                Classify OpenAthens virtual IdPs.
            -->
            <xsl:variable name="entities.openathens.virtual.in" select="$entities.gateways.out"/>
            <xsl:variable name="entities.openathens.virtual"
                select="$entities.openathens.virtual.in[md:Extensions/eduservlabel:AthensPUIDAuthority]"/>
            <xsl:variable name="entities.openathens.virtual.out"
                select="set:difference($entities.openathens.virtual.in, $entities.openathens.virtual)"/>
            
            <!--
                Classify Guanxi entities.
            -->
            <xsl:variable name="entities.guanxi.in" select="$entities.openathens.virtual.out"/>
            <xsl:variable name="entities.guanxi"
                select="$entities.guanxi.in[md:Extensions/uklabel:Software/@name='Guanxi']"/>
            <xsl:variable name="entities.guanxi.out"
                select="set:difference($entities.guanxi.in, $entities.guanxi)"/>
            
            <!--
                Classify AthensIM entities.
            -->
            <xsl:variable name="entities.athensim.in" select="$entities.guanxi.out"/>
            <xsl:variable name="entities.athensim"
                select="$entities.athensim.in[md:Extensions/uklabel:Software/@name='AthensIM']"/>
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
                <xsl:with-param name="entities" select="$entities.shib.13"/>
                <xsl:with-param name="name">Shibboleth 1.3</xsl:with-param>
                <xsl:with-param name="total" select="$entityCount"/>
            </xsl:call-template>

            <xsl:call-template name="entity.breakdown.by.software.line">
                <xsl:with-param name="entities" select="$entities.shib.2"/>
                <xsl:with-param name="name">Shibboleth 2.x</xsl:with-param>
                <xsl:with-param name="total" select="$entityCount"/>
            </xsl:call-template>
            
            <xsl:variable name="entities.shib" select="$entities.shib.13 | $entities.shib.2"/>
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
                <xsl:with-param name="entities" select="$entities.openathenssp"/>
                <xsl:with-param name="name">OpenAthens SP</xsl:with-param>
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
        <xsl:variable name="n" select="count($entities)"/>
        <xsl:if test="$n != 0">
            <li>
                <p>
                    <xsl:value-of select="$name"/>: <xsl:value-of select="$n"/>
                    (<xsl:value-of select="format-number($n div $total, '0.0%')"/>)
                </p>
                <xsl:if test="($show != 0) or ($n &lt;= 8)">
                    <ul>
                        <xsl:for-each select="$entities">
                            <li>
                                <xsl:value-of select="@ID"/>:
                                <code><xsl:value-of select="@entityID"/></code>
                                <xsl:if test="$show.software != 0">
                                    <xsl:choose>
                                        <xsl:when test="md:Extensions/uklabel:Software">
                                            (<xsl:value-of select="md:Extensions/uklabel:Software/@name"/>)
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
    
</xsl:stylesheet>