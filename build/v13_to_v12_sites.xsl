<?xml version="1.0" encoding="UTF-8"?>
<!--

	v13_to_v12_sites.xsl
	
	XSL stylesheet converting a SAML 2 metadata file describing a Shibboleth
	1.3 federation into the equivalent Shibboleth 1.2 sites file.
	
	Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
	xmlns:shibmeta="urn:mace:shibboleth:metadata:1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="urn:mace:shibboleth:1.0"
	exclude-result-prefixes="shibmeta md">

	<!--Force UTF-8 encoding for the output.-->
	<xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

	<!--
		Map EntitiesDescriptor to SiteGroup
	-->
	<xsl:template match="md:EntitiesDescriptor">
		<SiteGroup Name="{@Name}">
			<xsl:attribute name="xsi:schemaLocation">
				<xsl:text>urn:mace:shibboleth:1.0 shibboleth.xsd </xsl:text>
				<xsl:text>http://www.w3.org/2000/09/xmldsig# xmldsig-core-schema.xsd</xsl:text>
			</xsl:attribute>
			<!--
				Pass through text blocks and comments, and interesting elements.
				These may be: EntityDescriptor or nested EntitiesDescriptor.
			-->
			<xsl:apply-templates select="text()|comment()|md:EntityDescriptor|md:EntitiesDescriptor"/>
		</SiteGroup>
	</xsl:template>

	<!--
		Map EntityDescriptor to whichever of OriginSite and/or DestinationSite apply.
	-->
	<xsl:template match="md:EntityDescriptor">
		<xsl:if test="md:IDPSSODescriptor">
			<xsl:call-template name="OriginSite"/>
		</xsl:if>
		<xsl:if test="md:SPSSODescriptor">
			<xsl:call-template name="DestinationSite"/>
		</xsl:if>
	</xsl:template>

	<!--
		Map appropriate EntityDescriptor to OriginSite
	-->
	<xsl:template name="OriginSite">
		<OriginSite Name="{@entityID}">
			<!-- ErrorURL attribute -->
			<xsl:apply-templates select="md:IDPSSODescriptor/@errorURL"/>

			<!--
				Copy through comments and text blocks at the start of the output element.
				This means we don't lose comments, but there is no way to guarantee they will
				come out "in the right place".
			-->
			<xsl:apply-templates select="text()|comment()"/>

			<!--
				Alias elements
				
				For OriginSite, just take the OrganizationDisplayName to avoid problems with duplicated
				Alias elements in the WAYF.
			-->
			<!-- <xsl:apply-templates select="md:Organization/md:OrganizationName"/> -->
			<xsl:apply-templates select="md:Organization/md:OrganizationDisplayName"/>

			<!-- Contact elements -->
			<xsl:apply-templates select="md:ContactPerson"/>

			<!-- HandleService elements -->
			<xsl:apply-templates select="md:IDPSSODescriptor"/>

			<!-- AttributeAuthority elements -->
			<xsl:apply-templates select="md:AttributeAuthorityDescriptor/md:AttributeService"/>

			<!--
				Domain elements
				
				These may come from Scope elements under either of two md elements.  We pass
				through both: this will often result in duplication, but that isn't harmful.
			-->
			<xsl:apply-templates select="md:AttributeAuthorityDescriptor/md:Extensions/shibmeta:Scope"/>
			<xsl:apply-templates select="md:IDPSSODescriptor/md:Extensions/shibmeta:Scope"/>

		</OriginSite>
	</xsl:template>

	<!--
		Map IDPSSODescriptor to HandleService
	-->
	<xsl:template match="md:IDPSSODescriptor">
		<HandleService Name="{md:KeyDescriptor/ds:KeyInfo/ds:KeyName}"
			Location="{md:SingleSignOnService/@Location}" 
		/>
	</xsl:template>

	<!--
		Map AttributeService to AttributeAuthority
	-->
	<xsl:template match="md:AttributeService">
		<!-- pull out the host component of the location, after the // and before the next / -->
		<xsl:param name="host" select="substring-before(substring-after(@Location, '//'), '/')"/>
		<AttributeAuthority Location="{@Location}">
			<xsl:attribute name="Name">
				<xsl:choose>
					<!-- take off a trailing :port from the host, if present -->
					<xsl:when test="substring-before($host, ':') != ''">
						<xsl:value-of select="substring-before($host, ':')"/>
					</xsl:when>
					<!-- otherwise if the port is absent we just use the host unchanged -->
					<xsl:otherwise>
						<xsl:value-of select="$host"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</AttributeAuthority>
	</xsl:template>

	<!--
		Map Scope to Domain
	-->
	<xsl:template match="shibmeta:Scope">
		<Domain>
			<xsl:apply-templates select="@regexp"/>
			<xsl:value-of select="."/>
		</Domain>
	</xsl:template>

	<!--
		Map appropriate EntityDescriptor to DestinationSite
	-->
	<xsl:template name="DestinationSite">
		<DestinationSite Name="{@entityID}">
			<!-- ErrorURL attribute -->
			<xsl:apply-templates select="md:SPSSODescriptor/@errorURL"/>

			<!--
				Copy through comments and text blocks at the start of the output element.
				This means we don't lose comments, but there is no way to guarantee they will
				come out "in the right place".
			-->
			<xsl:apply-templates select="text()|comment()"/>

			<!--
				Alias elements
				
				This will cause duplication if the OrganizationName and the OrganizationDisplayName
				are the same.  If this turns out to be a problem, we could probably do some minimal cleanup
				under the assumption that there are only one of each.  Alternatively, we could just assume
				they are the same and ignore one or the other.
			-->
			<xsl:apply-templates select="md:Organization/md:OrganizationName"/>
			<xsl:apply-templates select="md:Organization/md:OrganizationDisplayName"/>

			<!-- Contact elements -->
			<xsl:apply-templates select="md:ContactPerson"/>

			<!-- AssertionConsumerServiceURL elements -->
			<xsl:apply-templates
				select="md:SPSSODescriptor/md:AssertionConsumerService[@Binding='urn:oasis:names:tc:SAML:1.0:profiles:browser-post']"/>

			<!-- AttributeRequester elements -->
			<xsl:apply-templates select="md:SPSSODescriptor/md:KeyDescriptor/ds:KeyInfo/ds:KeyName"/>
		</DestinationSite>
	</xsl:template>

	<!--
		Map AssertionConsumerService to AssertionConsumerServiceURL
	-->
	<xsl:template match="md:AssertionConsumerService">
		<AssertionConsumerServiceURL Location="{@Location}"/>
	</xsl:template>

	<!--
		Map ds:KeyName to AttributeRequester
	-->
	<xsl:template match="ds:KeyName">
		<AttributeRequester Name="{.}"/>
	</xsl:template>
	
	<!--
		Map OrganizationName or OrganizationDisplayName to Alias
	-->
	<xsl:template match="md:OrganizationName|md:OrganizationDisplayName">
		<Alias xml:lang="{@xml:lang}"><xsl:value-of select="."/></Alias>
	</xsl:template>

	<!--
		Map Contact to ContactPerson
	-->
	<xsl:template match="md:ContactPerson">
		<Contact Type="{@contactType}">
			<xsl:if test="md:EmailAddress">
				<xsl:attribute name="Email"><xsl:value-of select="substring-after(md:EmailAddress, 'mailto:')"/></xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="md:GivenName and md:SurName">
					<xsl:attribute name="Name"><xsl:value-of select="concat(md:GivenName, ' ', md:SurName)"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="md:GivenName">
					<xsl:attribute name="Name"><xsl:value-of select="md:GivenName"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="Name">Nobody</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</Contact>
	</xsl:template>
	
	<!--
		Map @errorURL to @ErrorURL
	-->
	<xsl:template match="@errorURL">
		<xsl:attribute name="ErrorURL"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>

	<!--
		By default, copy referenced attributes through unchanged.
	-->
	<xsl:template match="@*">
		<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>

	<!--
		By default, copy comments and text nodes through to the output unchanged.
	-->
	<xsl:template match="text()|comment()">
		<xsl:copy/>
	</xsl:template>

</xsl:stylesheet>
