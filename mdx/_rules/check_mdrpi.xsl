<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_mdrpi.xsl

    Checking ruleset containing rules associated with the SAML V2.0 Metadata
    Extensions for Registration and Publication Information Version 1.0, see:

        http://wiki.oasis-open.org/security/SAML2MetadataDRI

    This ruleset reflects WD08, 12-Dec-2011.

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns:set="http://exslt.org/sets"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>

    <!--
        Section 2.1

        RegistrationInfo MUST appear within the Extensions of either
        EntitiesDescriptor or EntityDescriptor.
    -->
    <xsl:template match="mdrpi:RegistrationInfo[not(parent::md:Extensions)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">RegistrationInfo must only appear within an Extensions element</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="md:Extensions[mdrpi:RegistrationInfo]
        [not(parent::md:EntityDescriptor)][not(parent::md:EntitiesDescriptor)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">RegistrationInfo must only appear within Extensions of EntityDescriptor or EntitiesDescriptor</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Section 2.1

        <mdrpi:RegistrationInfo> MUST NOT appear more than once within a given <md:Extensions> element.
    -->
    <xsl:template match="md:Extensions/mdrpi:RegistrationInfo[position()>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">more than one RegistrationInfo element in one Extensions element</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Section 2.1

        If RegistrationInfo appears on an EntitiesDescriptor, that precludes any appearance on nested
        EntitiesDescriptor or EntityDescriptor elements.
    -->
    <xsl:template match="md:EntitiesDescriptor[md:Extensions/mdrpi:RegistrationInfo]
        [md:EntityDescriptor//mdrpi:RegistrationInfo | md:EntitiesDescriptor//mdrpi:RegistrationInfo]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">RegistrationInfo may not appear on both EntitiesDescriptor and child elements</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Section 2.1.1

        registrationInstant values MUST be expressed in the UTC timezone using the 'Z' timezone identifier.
    -->
    <xsl:template match="mdrpi:RegistrationInfo[@registrationInstant]
        [substring(@registrationInstant, string-length(@registrationInstant)) != 'Z']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>registrationInstant does not end with 'Z': </xsl:text>
                <xsl:value-of select="@registrationInstant"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Section 2.1.1

        RegistrationPolicy elements are required to have unique xml:lang values within a given container.
    -->
    <xsl:template match="mdrpi:RegistrationInfo">
        <!-- unique xml:lang over RegistrationPolicy elements -->
        <xsl:call-template name="uniqueLang">
            <xsl:with-param name="e" select="mdrpi:RegistrationPolicy"/>
        </xsl:call-template>

        <!-- handle individual elements -->
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template name="uniqueLang">
        <xsl:param name="e"/>
        <xsl:variable name="l" select="$e/@xml:lang"></xsl:variable>
        <xsl:variable name="u" select="set:distinct($l)"/>
        <xsl:if test="count($l) != count($u)">
            <xsl:call-template name="error">
                <xsl:with-param name="m">
                    <xsl:text>non-unique lang values on </xsl:text>
                    <xsl:value-of select="name($e)"/>
                    <xsl:text> elements</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!--
        Section 2.2

        PublicationInfo MUST appear within the Extensions of either
        EntitiesDescriptor or EntityDescriptor.
    -->
    <xsl:template match="md:PublicationInfo[not(parent::md:Extensions)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">PublicationInfo must only appear within an Extensions element</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="md:Extensions[mdrpi:PublicationInfo]
        [not(parent::md:EntityDescriptor)][not(parent::md:EntitiesDescriptor)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">PublicationInfo must only appear within Extensions of EntityDescriptor or EntitiesDescriptor</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Section 2.2

        PublicationInfo SHOULD NOT appear except on the document element.

        Interpreted as a MUST NOT for now.
    -->
    <xsl:template match="mdrpi:PublicationInfo[parent::md:Extensions/parent::md:*/parent::*]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">PublicationInfo must be within document element's Extensions</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Section 2.2

        <mdrpi:PublicationInfo> MUST NOT appear more than once within a given <md:Extensions> element.
    -->
    <xsl:template match="md:Extensions/mdrpi:PublicationInfo[position()>1]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">more than one PublicationInfo element in one Extensions element</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        Section 2.1, 2.2

        Restrict the elements in this namespace which can appear directly within md:Extensions
        to the two defined container elements.  This will catch mis-spelled containers.
    -->
    <xsl:template match="md:Extensions/mdrpi:*
        [not(local-name()='RegistrationInfo')][not(local-name()='PublicationInfo')]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>misspelled or misplaced mdrpi element within md:Extensions: </xsl:text>
                <xsl:value-of select="local-name()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
