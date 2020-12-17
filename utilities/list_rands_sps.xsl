<?xml version="1.0" encoding="UTF-8"?>
<!--

    list_rands_sps.xsl

    Lists SPs which assert they are Research and Scholarship (R&S)

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="//md:EntitiesDescriptor">
        <xsl:text>&lt;!DOCTYPE html&gt;&#10;</xsl:text>
        <xsl:text>&lt;html lang="en"&gt;&#10;</xsl:text>
        <xsl:text>&lt;head&gt;&#10;</xsl:text>
        <xsl:text>&lt;title&gt;</xsl:text>
        <xsl:text>List of SPs asserting the Research and Scholarship entity category</xsl:text>
        <xsl:text>&lt;/title&gt;&#10;</xsl:text>
        <xsl:text>&lt;meta charset="UTF-8"&gt;&#10;</xsl:text>
        <xsl:text>&lt;/head&gt;&#10;</xsl:text>
        <xsl:text>&lt;body&gt;&#10;</xsl:text>
        <xsl:text>&lt;h1&gt;</xsl:text>
        <xsl:text>List of SPs asserting the Research and Scholarship entity category</xsl:text>
        <xsl:text>&lt;/h1&gt;&#10;</xsl:text>
        <xsl:apply-templates />
    </xsl:template>

    <!-- Select SPs which assert R&S entity category -->
    <xsl:template match="md:EntityDescriptor
        [md:Extensions/mdattr:EntityAttributes/saml:Attribute
            [@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']
            [@Name='http://macedir.org/entity-category']
            /saml:AttributeValue[.='http://refeds.org/category/research-and-scholarship']
        ]">
        <xsl:text>&lt;h2&gt;</xsl:text>
        <!-- Display name -->
	<xsl:value-of select="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='en']" />
        <xsl:text>&lt;/h2&gt;&#10;</xsl:text>
        <!-- table header -->
        <xsl:text>&lt;table&gt;&#10;</xsl:text>
        <!-- entityID -->
        <xsl:call-template name="row">
            <xsl:with-param name="label"><xsl:text>entityID</xsl:text></xsl:with-param>
            <xsl:with-param name="value" select="./@entityID"/>
        </xsl:call-template>
        <!-- registrationAuthority -->
        <xsl:call-template name="row">
            <xsl:with-param name="label"><xsl:text>registrationAuthority</xsl:text></xsl:with-param>
            <xsl:with-param name="value" select="md:Extensions/mdrpi:RegistrationInfo/@registrationAuthority"/>
        </xsl:call-template>
        <!-- InformationURL (is mandatory, but xml:lang='en' is only recommended) -->
        <xsl:choose>
            <xsl:when test="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:InformationURL[@xml:lang='en']">
	        <xsl:call-template name="row">
                    <xsl:with-param name="label"><xsl:text>InformationURL</xsl:text></xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:text>&lt;a href=&quot;</xsl:text>
                        <xsl:value-of select="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:InformationURL[@xml:lang='en']"/>
                        <xsl:text>&quot;&gt;</xsl:text>
                        <xsl:value-of select="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:InformationURL[@xml:lang='en']"/>
                        <xsl:text>&lt;/a&gt;</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="row">
                    <xsl:with-param name="label"><xsl:text>InformationURL</xsl:text></xsl:with-param>
                    <xsl:with-param name="value"><xsl:text>No English language version available</xsl:text></xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <!-- Description -->
        <xsl:call-template name="row">
            <xsl:with-param name="label"><xsl:text>Description</xsl:text></xsl:with-param>
            <xsl:with-param name="value" select="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Description[@xml:lang='en']"/>
        </xsl:call-template>
        <!-- PrivacyStatementURL (is not mentioned in v1.3 of entity category, but good practice nevertheless -->
        <xsl:choose>
            <xsl:when test="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:PrivacyStatementURL[@xml:lang='en']">
                <xsl:call-template name="row">
                    <xsl:with-param name="label"><xsl:text>PrivacyStatementURL</xsl:text></xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:text>&lt;a href=&quot;</xsl:text>
                        <xsl:value-of select="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:PrivacyStatementURL[@xml:lang='en']"/>
                        <xsl:text>&quot;&gt;</xsl:text>
                        <xsl:value-of select="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:PrivacyStatementURL[@xml:lang='en']"/>
                        <xsl:text>&lt;/a&gt;</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="row">
                    <xsl:with-param name="label"><xsl:text>PrivacyStatementURL</xsl:text></xsl:with-param>
                    <xsl:with-param name="value"><xsl:text>No English language version available</xsl:text></xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <!-- table footer -->
        <xsl:text>&lt;/table&gt;&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="text()">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template name="row">
        <xsl:param name="label"/>
        <xsl:param name="value"/>
        <xsl:text>&lt;tr&gt;&#10;</xsl:text>
        <xsl:call-template name="cellth">
            <xsl:with-param name="content">
                <xsl:value-of select="$label" />
            </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="celltd">
            <xsl:with-param name="content">
                <xsl:value-of select="$value" />
            </xsl:with-param>
        </xsl:call-template>
        <xsl:text>&lt;/tr&gt;&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="cellth">
        <xsl:param name="content"/>
        <xsl:text>&#09;&lt;th&gt;</xsl:text>
        <xsl:value-of select="$content" />
        <xsl:text>&lt;/th&gt;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="celltd">
        <xsl:param name="content"/>
        <xsl:text>&#09;&lt;td&gt;</xsl:text>
        <xsl:value-of select="$content" />
        <xsl:text>&lt;/td&gt;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
