<?xml version="1.0" encoding="UTF-8"?>
<!--

    orgnamescope.xsl
    
    XSL stylesheet taking a UK federation metadata file and resulting in a table listing entityID, member (Organisation) name, Organisation Display Name and Scopes.
    
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
        xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
        xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
        xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
	exclude-result-prefixes="xsi xsl md mdrpi shibmd" >

        <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

        <xsl:template match="/">
        <div style="margin-left:-20%;margin-right:+20%;">
        <table id="orgnameidp" class="tiger">
        <tr class="ind1">
        <th>DisplayName</th>
        <th>Organisation Name</th>
        <th>entityID</th>
        <th>Scopes</th>
        <th>Visibility</th>
        </tr>
        <small>
            <xsl:apply-templates/>
        </small>
        </table>
	</div>
	</xsl:template>

	<xsl:template name="metadata-aggregate" match="md:EntitiesDescriptor">
		<xsl:variable name="entities" select="//md:EntityDescriptor"/>
		<xsl:variable name="idps" select="$entities[md:IDPSSODescriptor]"/>
		<xsl:for-each select="$idps[(md:Extensions/mdrpi:RegistrationInfo/@registrationAuthority='http://ukfederation.org.uk')]">
			<xsl:sort select="md:Organization/md:OrganizationDisplayName[@xml:lang='en']"/><tr class="ind1" valign="top"><td>
           		<xsl:value-of select="md:Organization/md:OrganizationDisplayName[@xml:lang='en']"/></td><td>
           		<xsl:value-of select="md:Organization/md:OrganizationName[@xml:lang='en']"/></td><td>
           		<xsl:variable name="entityID" select="@entityID"/>
           		<a class='external' href="https://met.refeds.org/met/entity/{$entityID}/?federation=uk-access-management-federation">
           		<xsl:value-of select="@entityID"/></a></td><td>
           		<xsl:for-each select="md:IDPSSODescriptor/md:Extensions">
               			<xsl:variable name="numberofscopes">
                   			<xsl:value-of select="count(shibmd:Scope)"/>
               			</xsl:variable>
				<xsl:choose>
                   		<xsl:when test="$numberofscopes &gt; 5"><br/><details><summary>
                        		<xsl:value-of select="$numberofscopes"/> Scopes</summary>
                        		<xsl:for-each select="shibmd:Scope">
						<xsl:value-of select="."/><br/>
                            			<xsl:if test="position != last()"><br/></xsl:if>
                        		</xsl:for-each></details>
                   		</xsl:when>
                   		<xsl:otherwise>
                        		<xsl:for-each select="shibmd:Scope">
                            			<xsl:value-of select="."/><br/>
                            			<xsl:if test="position != last()"><br/></xsl:if>
                        		</xsl:for-each>
				</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each></td><td>
			<xsl:choose>
           		<xsl:when test="md:Extensions/mdattr:EntityAttributes/saml:Attribute
				[@Name='http://macedir.org/entity-category']
				[@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
				[saml:AttributeValue[.='http://refeds.org/category/hide-from-discovery']]"
				>No</xsl:when>
           		<xsl:otherwise>Yes</xsl:otherwise>
       			</xsl:choose>
		</td></tr>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>

