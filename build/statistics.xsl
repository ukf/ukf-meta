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
    xmlns:math="http://exslt.org/math"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:dyn="http://exslt.org/dynamic"
    xmlns:set="http://exslt.org/sets"
    exclude-result-prefixes="xsl ds shibmeta md xsi members wayf uklabel math date dyn set"
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
        <!-- Locations that don't start with http, at least -->
        <xsl:variable name="prob.nohttp.location" select="$entities[descendant::*[@Location and not(starts-with(@Location,'http'))]]"/>
        <!-- duplicate entity IDs -->
        <xsl:variable name="prob.distinct.entityIDs" select="set:distinct($entities/@entityID)"/>
        <xsl:variable name="prob.dup.entityID"
            select="set:distinct(set:difference($entities/@entityID, $prob.distinct.entityIDs))"/>
        <!-- entities without known owner -->
        <xsl:variable name="ownedEntities"
            select="dyn:closure($owners/md:OrganizationName, '$entities[md:Organization/md:OrganizationName = current()]')"/>
        <xsl:variable name="prob.unowned.entities" select="set:difference($entities, $ownedEntities)"/>
        <!-- all problems, used as a conditional -->
        <xsl:variable name="prob.all" select="$prob.space.entityID | $prob.space.location |
            $prob.nohttp.location |
            $prob.dup.entityID | $prob.unowned.entities"/>
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
                    <xsl:if test="count($prob.nohttp.location) != 0">
                        <p>The following entities include elements with <code>Location</code> attributes
                        that don't start with <code>http</code>:</p>
                        <ul>
                            <xsl:for-each select="$prob.nohttp.location">
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
                which appear to belong to that member.  To appear in this value, the entity's
                <code>OrganizationName</code> must <em>exactly</em> match the
                member's registered formal name.</p>
                <table border="1" cellspacing="2" cellpadding="4">
                    <tr>
                        <th align="left">Member</th>
                        <th>Entities</th>
                        <th>IdPs</th>
                        <th>SPs</th>
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
                            federation members.  This is an undercount, as the label is not applied
                            in the case of members transitioning from the SDSS Federation until
                            the entity's metadata has been fully verified with the member.
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
                    This is a list of identity providers that we *know* are running 1.3, even though they
                    may not look like it.
                -->
                <xsl:variable name="known13idps" select="
                    $entities[@entityID='urn:mace:ac.uk:sdss.ac.uk:provider:identity:shib.ncl.ac.uk'] |
                    $entities[@entityID='https://typekey.sdss.ac.uk/shibboleth'] |
                    $entities[@entityID='https://typekey.iay.org.uk/shibboleth'] |
                    $entities[@entityID='https://idp-1.bgfl.org/shibboleth'] |
                    $entities[@entityID='https://idp.protectnetwork.org/protectnetwork-idp']
                    "/>
                
                <!--
                    This is a list of service providers that we *know* are running 1.3, even though they
                    may not look like it.
                -->
                <xsl:variable name="known13sps" select="
                    $entities[@entityID='urn:mace:ac.uk:sdss.ac.uk:provider:service:dangermouse.ncl.ac.uk'] |
                    $entities[@entityID='https://spie.oucs.ox.ac.uk/shibboleth/wiki'] |
                    $entities[@entityID='https://sdauth.sciencedirect.com/']                 
                    "/>
                
                <!--
                    Entities for which we have explicit knowledge that they are running 1.3
                -->
                <xsl:variable name="known13entities" select="$known13idps | $known13sps"/>
                
                <xsl:variable name="sps13"
                    select="$known13sps |
                        $sps/descendant::md:AssertionConsumerService[contains(@Location, 'Shibboleth.sso')]/ancestor::md:EntityDescriptor"/>
                <xsl:variable name="idps13"
                    select="$known13idps |
                        $idps/descendant::md:SingleSignOnService[contains(@Location, '-idp/SSO')]/ancestor::md:EntityDescriptor"/>
                <xsl:variable name="entities13" select="$sps13 | $idps13"/>
                <xsl:variable name="entities13Count" select="count($entities13)"/>
                <h3>Shibboleth 1.3</h3>
                <p>
                    We have verified with the owners that the following entities are running Shibboleth 1.3, even
                    if that does not appear to be the case from their metadata:
                </p>
                <ul>
                    <xsl:for-each select="$known13entities">
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <code><xsl:value-of select="@entityID"/></code>
                        </li>
                    </xsl:for-each>
                </ul>
                <p>
                    Including the above, there are
                    <xsl:value-of select="$entities13Count"/> entities in the metadata that look like they are probably
                    running Shibboleth 1.3.  This is <xsl:value-of select="format-number($entities13Count div $entityCount, '0.0%')"/>
                    of all entities.
                </p>
                
                <xsl:variable name="sps12"
                    select="set:difference(
                        $sps/descendant::md:AssertionConsumerService[contains(@Location, 'Shibboleth.shire')]/ancestor::md:EntityDescriptor,
                        $known13sps)"/>
                <xsl:variable name="idps12"
                    select="set:difference(
                        $idps/descendant::md:SingleSignOnService[contains(@Location, '/HS')]/ancestor::md:EntityDescriptor,
                        $known13idps)"/>
                <xsl:variable name="entities12" select="$idps12 | $sps12"/>
                <xsl:variable name="entities12Count" select="count($entities12)"/>
                <h3>Shibboleth 1.2</h3>
                <p>There are <xsl:value-of select="$entities12Count"/> entities in the metadata that look like they might still
                be running Shibboleth 1.2.  This is <xsl:value-of select="format-number($entities12Count div $entityCount, '0.0%')"/>
                of all entities.</p>
                
                <h4>Shibboleth 1.2 Identity Providers</h4>
                <p>The following <xsl:value-of select="count($idps12)"/> identity providers look like they might be
                running Shibboleth 1.2 because they have at least one <code>SingleSignOnService/@Location</code>
                containing <code>"/HS"</code>.
                    This is <xsl:value-of select="format-number(count($idps12) div $idpCount, '0.0%')"/>
                    of all identity providers.</p>
                <ul>
                    <xsl:for-each select="$idps12">
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <code><xsl:value-of select="@entityID"/></code>:
                            <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>.
                        </li>
                    </xsl:for-each>
                </ul>
                
                <h4>Shibboleth 1.2 Service Providers</h4>
                <p>The following <xsl:value-of select="count($sps12)"/> service providers look like they might be
                    running Shibboleth 1.2 because they have at least one <code>AssertionConsumerService/@Location</code>
                    containing <code>"Shibboleth.shire"</code>.
                    This is <xsl:value-of select="format-number(count($sps12) div $spCount, '0.0%')"/>
                    of all service providers.</p>
                <ul>
                    <xsl:for-each select="$sps12">
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <code><xsl:value-of select="@entityID"/></code>
                        </li>
                    </xsl:for-each>
                </ul>
                <xsl:variable name="mixedVersionSps"
                    select="$sps12/descendant::md:AssertionConsumerService[contains(@Location, 'Shibboleth.sso')]/ancestor::md:EntityDescriptor"/>
                <xsl:variable name="mixedVersionSpCount" select="count($mixedVersionSps)"/>
                <xsl:if test="$mixedVersionSpCount != 0">
                    <p>On the other hand, the following <xsl:value-of select="$mixedVersionSpCount"/> entities also sport
                        1.3-style <code>AssertionConsumerService/@Location</code> elements
                        containing <code>"Shibboleth.sso"</code>.  These may therefore be in transition, or
                        simply need a metadata update to remove the old <code>@Location</code>:
                    </p>
                    <ul>
                        <xsl:for-each select="$mixedVersionSps">
                            <li>
                                <xsl:value-of select="@ID"/>:
                                <code><xsl:value-of select="@entityID"/></code>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                
                <xsl:variable name="entitiesShib" select="$entities12 | $entities13"/>
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
                
                <xsl:variable name="athensImEntities"
                    select="$idps/descendant::md:SingleSignOnService[contains(@Location, '/origin/hs')]/ancestor::md:EntityDescriptor"/>
                <xsl:variable name="athensImEntityCount" select="count($athensImEntities)"/>
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
                <xsl:variable name="knownGuanxiIdps" select="
                    $entities[@entityID='urn:mace:ac.uk:sdss.ac.uk:provider:identity:uhi.ac.uk']
                    "/>
                <xsl:variable name="guanxiCount" select="count($knownGuanxiIdps)"/>
                <xsl:if test="$guanxiCount != 0">
                    <h3>Guanxi Entities</h3>
                    <p>
                        <xsl:if test="$guanxiCount = 1">
                            The following entity is known to be running the Guanxi software:
                        </xsl:if>
                        <xsl:if test="$guanxiCount != 1">
                            The following entities are known to be running the Guanxi software:
                        </xsl:if>
                    </p>
                    <ul>
                        <xsl:for-each select="$knownGuanxiIdps">
                            <li>
                                <xsl:value-of select="@ID"/>:
                                <code><xsl:value-of select="@entityID"/></code>:
                                <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>.
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                
                <!--
                    Athens Gateway entities
                -->
                <xsl:variable name="knownGateways" select="
                    $entities[@entityID='urn:mace:eduserv.org.uk:athens:federation:beta'] |
                    $entities[@entityID='urn:mace:eduserv.org.uk:athens:federation:uk']
                    "/>
                <xsl:variable name="gatewayCount" select="count($knownGateways)"/>
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
                
                <xsl:variable name="knownSoftwareEntities"
                    select="$entities12 | $entities13 | $athensImEntities | $knownGuanxiIdps | $knownGateways"/>
                <xsl:variable name="unknownSoftwareEntities" select="set:difference($entities, $knownSoftwareEntities)"/>
                <xsl:variable name="unknownSoftwareEntityCount" select="count($unknownSoftwareEntities)"/>
                <h3>Unknown Software</h3>
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
                            <xsl:value-of select="md:Organization/md:OrganizationDisplayName"/>
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