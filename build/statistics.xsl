<?xml version="1.0" encoding="UTF-8"?>
<!--
    
    statistics.xsl
    
    XSL stylesheet taking a UK Federation metadata file and resulting in an HTML document
    giving statistics.
    
    Author: Ian A. Young <ian@iay.org.uk>
    
    $Id: statistics.xsl,v 1.16 2007/03/21 12:16:06 iay Exp $
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

        <xsl:variable name="memberDocument" select="document('../xml/members.xml')"/>
        <xsl:variable name="members" select="$memberDocument//members:Member"/>
        <xsl:variable name="memberCount" select="count($members)"/>
        <xsl:variable name="memberNames" select="$members/md:OrganizationName"/>
        
        <xsl:variable name="entities" select="//md:EntityDescriptor"/>
        <xsl:variable name="entityCount" select="count($entities)"/>

        <xsl:variable name="idps" select="$entities[md:IDPSSODescriptor]"/>
        <xsl:variable name="idpCount" select="count($idps)"/>
        <xsl:variable name="sps" select="$entities[md:SPSSODescriptor]"/>
        <xsl:variable name="spCount" select="count($sps)"/>
        <xsl:variable name="dualEntities" select="$entities[md:IDPSSODescriptor][md:SPSSODescriptor]"/>
        <xsl:variable name="dualEntityCount" select="count($dualEntities)"/>
        <xsl:variable name="exampleEntities" select="$entities[contains(md:Organization/md:OrganizationURL, 'example')]"/>
        <xsl:variable name="exampleEntityCount" select="count($exampleEntities)"/>
        
        <xsl:variable name="concealedCount" select="count($idps[md:Extensions/wayf:HideFromWAYF])"/>
        <xsl:variable name="accountableCount"
            select="count($idps[md:Extensions/uklabel:AccountableUsers])"/>
        <xsl:variable name="federationMemberEntityCount"
            select="count($entities[md:Extensions/uklabel:UKFederationMember])"/>
        <xsl:variable name="sdssPolicyCount"
            select="count($entities[md:Extensions/uklabel:SDSSPolicy])"/>
        
        <xsl:variable name="memberEntities"
            select="dyn:closure($members/md:OrganizationName, '$entities[md:Organization/md:OrganizationName = current()]')"/>
        <xsl:variable name="nonMemberEntities"
            select="set:difference($entities, $memberEntities)"/>
        <xsl:variable name="memberEntityCount"
            select="dyn:sum($memberNames, 'count($entities[md:Organization/md:OrganizationName = current()])')"/>
        <xsl:variable name="nonMemberEntityCount"
            select="$entityCount - $memberEntityCount"/>
        
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
                    <li><p><a href="#members">Member Statistics</a></p></li>
                    <li><p><a href="#entities">Entity Statistics</a></p></li>
                    <li><p><a href="#bySoftware">Entities by Software</a></p></li>
                    <li><p><a href="#orphans">Orphan Entities</a></p></li>
                    <li><p><a href="#bymember">Entities by Member</a></p></li>
                    <li><p><a href="#keyedEntities">Entities with Embedded Key Material</a></p></li>
                </ul>
                
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
                    </tr>
                    <xsl:apply-templates select="$members" mode="count">
                        <xsl:with-param name="entities" select="$entities"/>
                    </xsl:apply-templates>
                </table>
                <p>This accounts for <xsl:value-of select="$memberEntityCount"/>
                (<xsl:value-of select="format-number($memberEntityCount div $entityCount, '0.0%')"/>)
                of the <xsl:value-of select="$entityCount"/> entities in the federation metadata.</p>
                
                <p>The remaining <xsl:value-of select="$nonMemberEntityCount"/>
                    (<xsl:value-of select="format-number($nonMemberEntityCount div $entityCount, '0.0%')"/>)
                    may simply have misspelled
                    <code>OrganizationName</code> values.</p>

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
                            (<xsl:value-of select="format-number($artifactSpCount div $idpCount, '0.0%')"/>).
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
                    $entities[@entityID='https://typekey.iay.org.uk/shibboleth']                    
                    "/>
                
                <!--
                    This is a list of service providers that we *know* are running 1.3, even though they
                    may not look like it.
                -->
                <xsl:variable name="known13sps" select="
                    $entities[@entityID='urn:mace:ac.uk:sdss.ac.uk:provider:service:dangermouse.ncl.ac.uk'] |
                    $entities[@entityID='https://spie.oucs.ox.ac.uk/shibboleth/wiki']                 
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
                        $idps/descendant::md:SingleSignOnService[contains(@Location, '/shibboleth-idp/SSO')]/ancestor::md:EntityDescriptor"/>
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
                        </li>
                    </xsl:for-each>
                </ul>
                
                <h2><a name="orphans">Orphan Entities</a></h2>
                <p>
                    There are <xsl:value-of select="$nonMemberEntityCount"/> entities
                    (<xsl:value-of select="format-number($nonMemberEntityCount div $entityCount, '0.0%')"/>
                    of the total) that don't appear to
                    have <code>OrganizationName</code> values corresponding to the registered names of
                    federation members.  This may be because of typographical errors or simply because the
                    entities belong to SDSS Federation members in transition.  The list is sorted alphabetically
                    by <code>OrganizationName</code>.
                    <ul>
                        <xsl:for-each select="$nonMemberEntities">
                            <xsl:sort select="md:Organization/md:OrganizationName"/>
                            <li>
                                <xsl:value-of select="md:Organization/md:OrganizationName"/>:
                                <code><xsl:value-of select="@entityID"/></code>
                                (<xsl:value-of select="@ID"/>)
                            </li>
                        </xsl:for-each>
                    </ul>
                </p>
                
                <h2><a name="bymember">Entities by Member</a></h2>
                <ul>
                    <xsl:apply-templates select="$members" mode="enumerate">
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
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="members:Member" mode="count">
        <xsl:param name="entities"/>
        <xsl:variable name="myName" select="string(md:OrganizationName)"/>
        <xsl:variable name="matched" select="$entities[md:Organization/md:OrganizationName = $myName]"/>
        <tr>
            <td><xsl:value-of select="$myName"/></td>
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
        </tr>
    </xsl:template>
    
    <xsl:template match="members:Member" mode="enumerate">
        <xsl:param name="entities"/>
        <xsl:variable name="myName" select="string(md:OrganizationName)"/>
        <xsl:variable name="matched" select="$entities[md:Organization/md:OrganizationName = $myName]"/>
        <xsl:if test="count($matched) != 0">
            <li>
                <p><xsl:value-of select="$myName"/>:</p>
                <ul>
                    <xsl:for-each select="$matched">
                        <li>
                            <xsl:value-of select="@ID"/>:
                            <xsl:if test="md:Extensions/uklabel:UKFederationMember">[M] </xsl:if>
                            <code><xsl:value-of select="@entityID"/></code>
                        </li>
                    </xsl:for-each>
                </ul>
            </li>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>