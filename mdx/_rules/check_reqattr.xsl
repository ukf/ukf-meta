<?xml version="1.0" encoding="UTF-8"?>
<!--

    check_reqattr.xsl

    Checking ruleset for RequestedAttribute elements in SAML 2.0 metadata.

    The main check being performed here is that the Name and NameFormat attributes
    of a RequestedAttribute element together designate a real SAML attribute, either
    explicitly or implicitly covered by some specification.  Other combinations
    of Name+NameFormat are presumptively erroneous.

    Attribute profiles we make use of here:

    * eduPerson 2008

    * MACE-Dir SAML Attribute Profiles, April 2008

    * SWITCHaai Attribute Specification, 2010-06-23

    * grEduPerson
        from http://aai.grnet.gr/static/grEduPerson.schema
        and http://aai.grnet.gr/static/policy/policy-en.pdf

    * SCHAC
        Only very basic coverage, most attributes to come later.
        http://www.terena.org/activities/tf-emc2/docs/schac/schac-schema-IAD-1.4.1.pdf
        http://www.terena.org/registry/terena.org/attribute-def/
        http://www.terena.org/registry/terena.org/schac/
        Assuming encoding rules equivalent to MACEAttr.
    
    * eduroam.cz
        Currently only a single attribute, documented at:
        https://www.eduroam.cz/attributes/eduroamUID

    * SAML V2.0 Subject Identifier Attributes Profile
        https://docs.oasis-open.org/security/saml-subject-id-attr/v1.0/cs01/saml-subject-id-attr-v1.0-cs01.pdf

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"

    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="check_framework.xsl"/>


    <!--
        Lack of NameFormat is equivalent to an explicit NameFormat of
        'urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified',
        see http://tools.oasis-open.org/issues/browse/SECURITY-11

        This is almost certainly not correct, as an implicit
        NameFormat of 'unspecified' is not the same as saying that
        any NameFormat will match.
    -->
    <xsl:template match="md:RequestedAttribute[not(@NameFormat)]">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>RequestedAttribute </xsl:text>
                <xsl:value-of select="@Name"/>
                <xsl:text> lacks NameFormat attribute</xsl:text>
                <xsl:text> (implicitly 'urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified')</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        Present but unknown, and therefore presumptively unsuitable, NameFormat values.
    -->
    <xsl:template match="md:RequestedAttribute[@NameFormat]
        [@NameFormat!='urn:mace:shibboleth:1.0:attributeNamespace:uri']
        [@NameFormat!='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']">
        <xsl:call-template name="error">
            <xsl:with-param name="m">
                <xsl:text>RequestedAttribute uses NameFormat of </xsl:text>
                <xsl:value-of select="@NameFormat"/>
                <xsl:text>: unsuitable for cross-domain use</xsl:text>
                <xsl:if test="@FriendlyName">
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="@FriendlyName"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!--
        If NameFormat is "urn:mace:shibboleth:1.0:attributeNamespace:uri", then we are
        dealing with a SAML 1.x attribute.
    -->
    <xsl:template match="md:RequestedAttribute
        [@NameFormat='urn:mace:shibboleth:1.0:attributeNamespace:uri']">
        <xsl:choose>

            <!--
                MACE-Dir Attribute Profile for SAML 1.x

                2.2.1: Legacy names that are explicitly permitted.

                Taken from MACE-Dir SAML Attribute Profiles, April 2008
            -->
            <xsl:when test="
                @Name='urn:mace:dir:attribute-def:eduPersonScopedAffiliation' or
                @Name='urn:mace:dir:attribute-def:eduPersonPrimaryAffiliation' or
                @Name='urn:mace:dir:attribute-def:eduPersonAffiliation' or
                @Name='urn:mace:dir:attribute-def:eduPersonPrincipalName' or
                @Name='urn:mace:dir:attribute-def:eduPersonEntitlement' or
                @Name='urn:mace:dir:attribute-def:eduPersonTargetedID' or
                @Name='urn:mace:dir:attribute-def:eduPersonNickname' or
                @Name='urn:mace:dir:attribute-def:eduPersonPrimaryOrgUnitDN' or
                @Name='urn:mace:dir:attribute-def:eduPersonOrgUnitDN' or
                @Name='urn:mace:dir:attribute-def:eduPersonOrgDN' or
                @Name='urn:mace:dir:attribute-def:eduCourseMember' or
                @Name='urn:mace:dir:attribute-def:businessCategory' or
                @Name='urn:mace:dir:attribute-def:carLicense' or
                @Name='urn:mace:dir:attribute-def:cn' or
                @Name='urn:mace:dir:attribute-def:departmentNumber' or
                @Name='urn:mace:dir:attribute-def:description' or
                @Name='urn:mace:dir:attribute-def:displayName' or
                @Name='urn:mace:dir:attribute-def:employeeNumber' or
                @Name='urn:mace:dir:attribute-def:employeeType' or
                @Name='urn:mace:dir:attribute-def:facsimileTelephoneNumber' or
                @Name='urn:mace:dir:attribute-def:givenName' or
                @Name='urn:mace:dir:attribute-def:homePhone' or
                @Name='urn:mace:dir:attribute-def:homePostalAddress' or
                @Name='urn:mace:dir:attribute-def:initials' or
                @Name='urn:mace:dir:attribute-def:jpegPhoto' or
                @Name='urn:mace:dir:attribute-def:l' or
                @Name='urn:mace:dir:attribute-def:labeledURI' or
                @Name='urn:mace:dir:attribute-def:mail' or
                @Name='urn:mace:dir:attribute-def:manager' or
                @Name='urn:mace:dir:attribute-def:mobile' or
                @Name='urn:mace:dir:attribute-def:o' or
                @Name='urn:mace:dir:attribute-def:ou' or
                @Name='urn:mace:dir:attribute-def:pager' or
                @Name='urn:mace:dir:attribute-def:physicalDeliveryOfficeName' or
                @Name='urn:mace:dir:attribute-def:postalAddress' or
                @Name='urn:mace:dir:attribute-def:postalCode' or
                @Name='urn:mace:dir:attribute-def:postOfficeBox' or
                @Name='urn:mace:dir:attribute-def:preferredLanguage' or
                @Name='urn:mace:dir:attribute-def:roomNumber' or
                @Name='urn:mace:dir:attribute-def:seeAlso' or
                @Name='urn:mace:dir:attribute-def:sn' or
                @Name='urn:mace:dir:attribute-def:st' or
                @Name='urn:mace:dir:attribute-def:street' or
                @Name='urn:mace:dir:attribute-def:telephoneNumber' or
                @Name='urn:mace:dir:attribute-def:title' or
                @Name='urn:mace:dir:attribute-def:uid' or
                @Name='urn:mace:dir:attribute-def:userCertificate' or
                @Name='urn:mace:dir:attribute-def:userSMIMECertificate'
                ">
                <!-- OK -->
            </xsl:when>

            <!--
                Legacy name for eduPersonAssurance (from eduPerson 2008)
            -->
            <xsl:when test="@Name='urn:mace:dir:attribute-def:eduPersonAssurance'">
                <!-- OK -->
            </xsl:when>

            <!--
                MACE-Dir Attribute Profile for SAML 1.x

                2.3.2.1.1: Recommended name and syntax for eduPersonTargetedID.
            -->
            <xsl:when test="@Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.10'">
                <!-- OK -->
            </xsl:when>

            <!--
                MACE-Dir Attribute Profile for SAML 1.x

                'urn:oid:' equivalents of legacy names should NOT appear.
                If they do, they are probably intended to be a SAML 2.0 mapping.

                The list is in same order as the list of legacy names above, and
                includes the OID for eduPersonAssurance at the end.
            -->
            <xsl:when test="
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.9' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.5' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.1' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.6' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.7' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.10' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.2' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.8' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.4' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.3' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.6.1.2' or
                @Name='urn:oid:2.5.4.15' or
                @Name='urn:oid:2.16.840.1.113730.3.1.1' or
                @Name='urn:oid:2.5.4.3' or
                @Name='urn:oid:2.16.840.1.113730.3.1.2' or
                @Name='urn:oid:2.5.4.13' or
                @Name='urn:oid:2.16.840.1.113730.3.1.241' or
                @Name='urn:oid:2.16.840.1.113730.3.1.3' or
                @Name='urn:oid:2.16.840.1.113730.3.1.4' or
                @Name='urn:oid:2.5.4.23' or
                @Name='urn:oid:2.5.4.42' or
                @Name='urn:oid:0.9.2342.19200300.100.1.20' or
                @Name='urn:oid:0.9.2342.19200300.100.1.39' or
                @Name='urn:oid:2.5.4.43' or
                @Name='urn:oid:0.9.2342.19200300.100.1.60' or
                @Name='urn:oid:2.5.4.7' or
                @Name='urn:oid:1.3.6.1.4.1.250.1.57' or
                @Name='urn:oid:0.9.2342.19200300.100.1.3' or
                @Name='urn:oid:0.9.2342.19200300.100.1.10' or
                @Name='urn:oid:0.9.2342.19200300.100.1.41' or
                @Name='urn:oid:2.5.4.10' or
                @Name='urn:oid:2.5.4.11' or
                @Name='urn:oid:0.9.2342.19200300.100.1.42' or
                @Name='urn:oid:2.5.4.19' or
                @Name='urn:oid:2.5.4.16' or
                @Name='urn:oid:2.5.4.17' or
                @Name='urn:oid:2.5.4.18' or
                @Name='urn:oid:2.16.840.1.113730.3.1.39' or
                @Name='urn:oid:0.9.2342.19200300.100.1.6' or
                @Name='urn:oid:2.5.4.34' or
                @Name='urn:oid:2.5.4.4' or
                @Name='urn:oid:2.5.4.8' or
                @Name='urn:oid:2.5.4.9' or
                @Name='urn:oid:2.5.4.20' or
                @Name='urn:oid:2.5.4.12' or
                @Name='urn:oid:0.9.2342.19200300.100.1.1' or
                @Name='urn:oid:2.5.4.36' or
                @Name='urn:oid:2.16.840.1.113730.3.1.40' or
                @Name='urn:oid:1.3.6.1.4.1.5923.1.1.1.11'
                ">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>RequestedAttribute</xsl:text>
                        <xsl:if test="@FriendlyName">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@FriendlyName"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:text> uses OID name </xsl:text>
                        <xsl:value-of select="@Name"/>
                        <xsl:text> with SAML 1.x NameFormat: should use urn:mace name or SAML 2.0 NameFormat</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <!--
                SWITCHaai SAML 1.x names are prefixed by 'urn:mace:switch.ch:attribute-def:'

                Arranged in order of appearance in the specification.
            -->
            <xsl:when test="
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonUniqueID' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonMatriculationNumber' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonCardUID' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonDateOfBirth' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonGender' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonHomeOrganization' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonHomeOrganizationType' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonStudyBranch1' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonStudyBranch2' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonStudyBranch3' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonStudyLevel' or
                @Name='urn:mace:switch.ch:attribute-def:swissEduPersonStaffCategory'
                ">
                <!-- OK -->
            </xsl:when>

            <!--
                SWITCHaai SAML 2.0 names are oid-based, and should not appear
                with the SAML 1.x NameFormat.

                Arranged in order of appearance in the specification.
            -->
            <xsl:when test="
                @Name='urn:oid:2.16.756.1.2.5.1.1.1' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.11' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.12' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.2' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.3' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.4' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.5' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.6' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.7' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.8' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.9' or
                @Name='urn:oid:2.16.756.1.2.5.1.1.10'
                ">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>RequestedAttribute</xsl:text>
                        <xsl:if test="@FriendlyName">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@FriendlyName"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:text> uses OID name </xsl:text>
                        <xsl:value-of select="@Name"/>
                        <xsl:text> with SAML 1.x NameFormat: should use urn:mace name or SAML 2.0 NameFormat</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <!--
                grEduPerson SAML 1.x binding
            -->
            <xsl:when test="@Name='urn:mace:grnet.gr:grEduPerson:attribute-def:grEduPersonUndergraduateBranch'">
                <!-- OK -->
            </xsl:when>

            <!--
                grEduPerson SAML 2.0 names should not appear.
            -->
            <xsl:when test="@Name='urn:oid:1.3.6.1.4.1.16515.2.3.2.1'">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>RequestedAttribute uses OID name </xsl:text>
                        <xsl:value-of select="@Name"/>
                        <xsl:text> with SAML 1.x NameFormat: should use urn:mace name or SAML 2.0 NameFormat</xsl:text>
                        <xsl:if test="@FriendlyName">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@FriendlyName"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <!--
                SCHAC SAML 1.x binding
            -->
            <xsl:when test="
                @Name='urn:mace:terena.org:attribute-def:schacHomeOrganization' or
                @Name='urn:mace:terena.org:attribute-def:schacPersonalUniqueCode'
                ">
                <!-- OK -->
            </xsl:when>

            <!--
                SCHAC SAML 2.0 names should not appear.
            -->
            <xsl:when test="
                @Name='urn:oid:1.3.6.1.4.1.25178.1.2.9' or
                @Name='urn:oid:1.3.6.1.4.1.25178.1.2.14'
                ">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>RequestedAttribute uses OID name </xsl:text>
                        <xsl:value-of select="@Name"/>
                        <xsl:text> with SAML 1.x NameFormat: should use urn:mace name or SAML 2.0 NameFormat</xsl:text>
                        <xsl:if test="@FriendlyName">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@FriendlyName"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <!--
                MACE-Dir Attribute Profile for SAML 1.x

                Forward-looking "urn:oid:" names are permitted, which is to say
                any "urn:oid" name which does not correspond to a legacy name.

                (Any erroneous OIDs have been eliminated above.)
            -->
            <xsl:when test="starts-with(@Name, 'urn:oid:')">
                <!-- OK -->
            </xsl:when>

            <!--
                Otherwise unknown attribute names.
            -->
            <xsl:otherwise>
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>RequestedAttribute uses unknown name </xsl:text>
                        <xsl:value-of select="@Name"/>
                        <xsl:text> with SAML 1.x NameFormat</xsl:text>
                        <xsl:if test="@FriendlyName">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@FriendlyName"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>


    <!--
        If NameFormat is "urn:oasis:names:tc:SAML:2.0:attrname-format:uri", then we are
        dealing with a SAML 2.0 attribute.
    -->
    <xsl:template match="md:RequestedAttribute
        [@NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']">
        <xsl:choose>

            <!--
                Common error: using the legacy MACEAttr name with the SAML 2.0 NameFormat.
            -->
            <xsl:when test="starts-with(@Name, 'urn:mace:dir:attribute-def:')">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>RequestedAttribute uses legacy MACEAttr name </xsl:text>
                        <xsl:value-of select="@Name"/>
                        <xsl:text> with SAML 2.0 NameFormat: should use urn:oid name or SAML 1.x NameFormat</xsl:text>
                        <xsl:if test="@FriendlyName">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@FriendlyName"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <!--
                Common error: using the legacy SWITCHaai name with the SAML 2.0 NameFormat.
            -->
            <xsl:when test="starts-with(@Name, 'urn:mace:switch.ch:attribute-def:')">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>RequestedAttribute uses legacy SWITCHaai name </xsl:text>
                        <xsl:value-of select="@Name"/>
                        <xsl:text> with SAML 2.0 NameFormat: should use urn:oid name or SAML 1.x NameFormat</xsl:text>
                        <xsl:if test="@FriendlyName">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@FriendlyName"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <!--
                Common error: using the legacy grEduPerson name with the SAML 2.0 NameFormat.
            -->
            <xsl:when test="starts-with(@Name, 'urn:mace:grnet.gr:grEduPerson:attribute-def:')">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>RequestedAttribute uses legacy format name </xsl:text>
                        <xsl:value-of select="@Name"/>
                        <xsl:text> with SAML 2.0 NameFormat: should use urn:oid name or SAML 1.x NameFormat</xsl:text>
                        <xsl:if test="@FriendlyName">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@FriendlyName"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <!--
                Common error: using the legacy SCHAC name with the SAML 2.0 NameFormat.
            -->
            <xsl:when test="starts-with(@Name, 'urn:mace:terena.org:attribute-def:')">
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>RequestedAttribute uses legacy format name </xsl:text>
                        <xsl:value-of select="@Name"/>
                        <xsl:text> with SAML 2.0 NameFormat: should use urn:oid name or SAML 1.x NameFormat</xsl:text>
                        <xsl:if test="@FriendlyName">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@FriendlyName"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <!--
                MACE-Dir Attribute Profile for SAML 2.0

                Attributes are named per the X.500/LDAP attribute profile in [SAML2Prof].
            -->
            <xsl:when test="starts-with(@Name, 'urn:oid:')">
                <!-- OK -->
            </xsl:when>

            <!--
                eduroam.cz SAML 2.x binding
            -->
            <xsl:when test="@Name='http://eduroam.cz/attributes/eduroamUID'">
                <!-- OK -->
            </xsl:when>

            <!--
                SAML V2.0 Subject Identifier Attributes Profile Version 1.0
            -->
            <xsl:when test="
                @Name = 'urn:oasis:names:tc:SAML:attribute:subject-id' or
                @Name = 'urn:oasis:names:tc:SAML:attribute:pairwise-id'
                ">
                <!-- OK -->
            </xsl:when>

            <!--
                Otherwise unknown attribute names.
            -->
            <xsl:otherwise>
                <xsl:call-template name="error">
                    <xsl:with-param name="m">
                        <xsl:text>RequestedAttribute uses unknown name </xsl:text>
                        <xsl:value-of select="@Name"/>
                        <xsl:text> with SAML 2.0 NameFormat</xsl:text>
                        <xsl:if test="@FriendlyName">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="@FriendlyName"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
