<?xml version="1.0" encoding="UTF-8"?>
<!--
    
    statistics.xsl
    
    XSL stylesheet taking a UK Federation metadata file and resulting in an HTML document
    giving statistics.
    
    Author: Ian A. Young <ian@iay.org.uk>
    
    $Id: statistics.xsl,v 1.1 2007/02/28 15:18:01 iay Exp $
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
    exclude-result-prefixes="xsl ds shibmeta md xsi members wayf uklabel math date dyn"
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
        
        <xsl:variable name="concealedCount" select="count($idps[md:Extensions/wayf:HideFromWAYF])"/>
        <xsl:variable name="accountableCount"
            select="count($idps[md:Extensions/uklabel:AccountableUsers])"/>
        <xsl:variable name="memberEntityCount"
            select="count($entities[md:Extensions/uklabel:UKFederationMember])"/>
        <xsl:variable name="sdssPolicyCount"
            select="count($entities[md:Extensions/uklabel:SDSSPolicy])"/>
        
        <xsl:variable name="memberEntityCount"
            select="dyn:sum($memberNames, 'count($entities[md:Organization/md:OrganizationName = current()])')"/>
        <xsl:variable name="nonMemberEntityCount"
            select="$entityCount - $memberEntityCount"/>
        
        <html>
            <head>
                <title>UK Federation metadata statistics</title>
            </head>
            <body>
                <h1>UK Federation metadata statistics</h1>
                <p>This document is regenerated each time the UK Federation metadata is altered.</p>
                <p>This version was created at <xsl:value-of select="$now"/>.</p>
                
                <h2>Member Statistics</h2>
                <p>Number of members: <xsl:value-of select="$memberCount"/></p>
                <p>The following table shows, for each federation member, the number of entities
                which appear to belong to that member.  To appear in this value, the entity's
                <code>OrganizationDisplayName</code> must <em>exactly</em> match the
                member's registered formal name.</p>
                <table border="1" cellspacing="2" cellpadding="4">
                    <tr>
                        <th align="left">Member</th>
                        <th>Entities</th>
                    </tr>
                    <xsl:apply-templates select="$members">
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

                <h2>Entity Statistics</h2>
                <p>Total entities: <xsl:value-of select="$entityCount"/></p>
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
                
                <p>
                    Of the <xsl:value-of select="$entityCount"/> entities,
                <xsl:value-of select="$memberEntityCount"/>
                (<xsl:value-of select="format-number($memberEntityCount div $entityCount, '0.0%')"/>)
                are labelled as being owned by full
                federation members.  This is an undercount, as the label is not applied
                in the case of members transitioning from the SDSS Federation until
                the entity's metadata has been fully verified with the member.</p>

                <p>Of the <xsl:value-of select="$entityCount"/> entities,
                <xsl:value-of select="$sdssPolicyCount"/>
                (<xsl:value-of select="format-number($sdssPolicyCount div $entityCount, '0.0%')"/>)
                are labelled as having been owned by organisations asserting that they would
                follow the SDSS Federation policy.</p>
                
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
                </ul>
                
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="members:Member">
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
    
</xsl:stylesheet>