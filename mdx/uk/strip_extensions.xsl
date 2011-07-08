<?xml version="1.0" encoding="UTF-8"?>
<!--
	strip_extensions.xsl
	
	Strip out any ukfedlabel namespace extensions that we don't intend to publish.
	This may require removing now-empty md:Extensions elements.
-->
<xsl:stylesheet version="1.0"
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"
	
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
	
	xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="md">

	<!--
		Handle <md:Extensions> elements.
		
		In general, at this stage in the flow we pass through any Extensions unaltered.
		However, certain changes (such as the filtering we perform on extensions in the
		ukfedlabel namespace) may cause the Extensions element to become empty, which is not
		permitted by the schema.  We therefore precompute the resulting Extensions element
		and suppress it entirely if it would have no child elements.
	-->
	<xsl:template match="md:Extensions">
		<!-- compute result -->
		<xsl:variable name="ext">
			<xsl:copy>
				<xsl:apply-templates select="node()|@*"/>
			</xsl:copy>
		</xsl:variable>
		<!-- copy through only if schema-valid -->
		<xsl:if test="count(exsl:node-set($ext)/md:Extensions/*) != 0">
			<xsl:copy-of select="$ext"/>
		</xsl:if>
	</xsl:template>
	
	<!--
		Pass through certain ukfedlabel namespace elements.
	-->
	<xsl:template match="ukfedlabel:UKFederationMember | ukfedlabel:AccountableUsers">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<!--
		Strip all other ukfedlabel namespace elements entirely.
	-->
	<xsl:template match="ukfedlabel:*"/>


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
