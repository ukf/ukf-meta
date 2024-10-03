<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:uklabel="http://ukfederation.org.uk/2006/11/label"
    exclude-result-prefixes="xsl md xsi uklabel"
    version="1.0">

    <xsl:output method="html" omit-xml-declaration="yes" encoding="UTF-8"/>
    
    <xsl:template match="md:EntitiesDescriptor">
        
<h1>Federation Identity Providers Asserting User Accountability</h1>

<p>The following IdPs assert user accountability (in accordance with section six of the <a href="https://www.ukfederation.org.uk/doc/rules-of-membership">UK federation's rules of membership</a>):</p>
<br />
<ul>

    <xsl:for-each select="//md:EntityDescriptor[md:IDPSSODescriptor][md:Extensions/uklabel:AccountableUsers]">
        <xsl:sort select="md:Organization/md:OrganizationDisplayName"/>
        <li><xsl:value-of select="md:Organization/md:OrganizationDisplayName"/></li>
    </xsl:for-each>

</ul>
    </xsl:template>
</xsl:stylesheet>

