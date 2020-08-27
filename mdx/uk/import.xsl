<?xml version="1.0" encoding="UTF-8"?>
<!--

    import.xsl

    XSL stylesheet that takes a SAML 2 metadata file containing
    an EntityDescriptor from some other system (e.g., metadata
    generated automatically by a Shibboleth installation) and
    adjusts it towards the standard used for a UK federation
    metadata repository fragment file.

    Warning:

    * the XSLT template is unusual compared with what you see in
    so many other files, since it does not copy across comments
    from the input file to the output. This has the effect that
    all comments from the incoming file are strippped, but comments
    generated within the transform itself are unaffected.

    Assumptions:

    * the output will have oXygen's "format and indent" applied
    via the Eclipse plug-in.  This means that output format doesn't
    need to be particularly precise.

    * the metadata comes from a UK federation member

    * the metadata most likely represents a Shibboleth 2.x entity

    Author: Ian A. Young <ian@iay.org.uk>

-->
<xsl:stylesheet version="1.0"
    xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    xmlns:init="urn:oasis:names:tc:SAML:profiles:SSO:request-init"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:remd="http://refeds.org/metadata"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:ukfedlabel="http://ukfederation.org.uk/2006/11/label"

    xmlns:xalan="http://xml.apache.org/xalan"

    exclude-result-prefixes="idpdisc init md mdui xalan"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Force UTF-8 encoding for the output.
    -->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8"
        indent="yes" xalan:indent-amount="4"
    />

    <!--
        Parameters passed in from verbs.xml.
    -->
    <xsl:param name="now_ISO"/>
    <xsl:param name="now_date_ISO"/>

    <xsl:strip-space elements="md:EntityDescriptor"/>

    <!--
        Top-level EntityDescriptor element.
    -->
    <xsl:template match="md:EntityDescriptor">
        <xsl:text>&#10;</xsl:text>
        <EntityDescriptor ID="uk000000_CHANGE_THIS"
            xsi:schemaLocation="urn:oasis:names:tc:SAML:2.0:metadata saml-schema-metadata-2.0.xsd
            urn:oasis:names:tc:SAML:metadata:algsupport sstc-saml-metadata-algsupport-v1.0.xsd
            urn:oasis:names:tc:SAML:metadata:attribute sstc-metadata-attr.xsd
            urn:oasis:names:tc:SAML:metadata:rpi saml-metadata-rpi-v1.0.xsd
            urn:oasis:names:tc:SAML:metadata:ui sstc-saml-metadata-ui-v1.0.xsd
            urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol sstc-saml-idp-discovery.xsd
            urn:oasis:names:tc:SAML:profiles:SSO:request-init sstc-request-initiation.xsd
            urn:oasis:names:tc:SAML:2.0:assertion saml-schema-assertion-2.0.xsd
            urn:mace:shibboleth:metadata:1.0 shibboleth-metadata-1.0.xsd
            http://ukfederation.org.uk/2006/11/label uk-fed-label.xsd
            http://refeds.org/metadata refeds-metadata.xsd
            http://www.w3.org/2001/04/xmlenc# xenc-schema.xsd
            http://www.w3.org/2009/xmlenc11# xenc-schema-11.xsd
            http://www.w3.org/2000/09/xmldsig# xmldsig-core-schema.xsd">

            <!--
                Copy across the @entityID attribute.  Other attributes from the input document
                are discarded.
            -->
            <xsl:attribute name="entityID"><xsl:value-of select="@entityID"/></xsl:attribute>

            <!--
                Entity comment.
            -->
            <!-- <xsl:text>&#10;</xsl:text> -->
            <xsl:text>&#10;</xsl:text>
            <xsl:comment>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>        *** ENTITY COMMENT GOES HERE ***</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    </xsl:text>
            </xsl:comment>

            <!--
                Always have an Extensions element.  This may combine new material with any material
                present in an existing Extensions element.
            -->
            <Extensions>

                <!--
                    Pull up scopes from role descriptor if they are not
                    already present at the entity level.
                -->
                <xsl:if test="not(md:Extensions/shibmd:Scope)">
                    <xsl:apply-templates select="md:IDPSSODescriptor/md:Extensions/shibmd:Scope"/>
                </xsl:if>

                <!--
                    Always assumed to be owned by a member of the UK federation.
                -->
                <xsl:comment> *** FILL IN APPROPRIATE orgID VALUE BELOW *** </xsl:comment>
                <ukfedlabel:UKFederationMember orgID="ukforg99999"/>

                <!--
                    Dummy elements to include for IdPs only.
                -->
                <xsl:if test="md:IDPSSODescriptor">
                    <xsl:comment> *** VERIFY OR REMOVE THE FOLLOWING ELEMENT *** </xsl:comment>
                    <ukfedlabel:AccountableUsers/>
                    <xsl:comment> *** VERIFY OR REMOVE THE FOLLOWING ELEMENT AND ITS CHILDREN *** </xsl:comment>
                    <mdattr:EntityAttributes>
                        <saml:Attribute Name="http://macedir.org/entity-category" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri">
                            <saml:AttributeValue>http://refeds.org/category/hide-from-discovery</saml:AttributeValue>
                        </saml:Attribute>
                    </mdattr:EntityAttributes>
                </xsl:if>

                <!--
                    Dummy Software element.
                -->
                <ukfedlabel:Software name="*** FILL IN ***"
                    version="*** FILL IN OR REMOVE ***" fullVersion="*** FILL IN OR REMOVE ***">
                    <xsl:attribute name="date"><xsl:value-of select="$now_date_ISO"/></xsl:attribute>
                </ukfedlabel:Software>

                <!--
                    Include any existing extensions at the top level.
                -->
                <xsl:apply-templates select="md:Extensions/*"/>

                <!--
                    Add registration information consisting of the registration instant
                    and an identifier for the registrar.

                    Any RegistrationInfo on the input document is discarded by a rule below.
                -->
                <xsl:element name="mdrpi:RegistrationInfo">
                    <xsl:attribute name="registrationAuthority">http://ukfederation.org.uk</xsl:attribute>
                    <xsl:attribute name="registrationInstant">
                        <xsl:value-of select="$now_ISO"/>
                    </xsl:attribute>
                    <xsl:element name="mdrpi:RegistrationPolicy">
                        <xsl:attribute name="xml:lang">en</xsl:attribute>
                        <xsl:text>http://ukfederation.org.uk/doc/mdrps-20130902</xsl:text>
                    </xsl:element>
                </xsl:element>

            </Extensions>

            <!--
                Express role descriptors in a fixed order.
            -->
            <xsl:apply-templates select="md:IDPSSODescriptor"/>
            <xsl:apply-templates select="md:AttributeAuthorityDescriptor"/>
            <xsl:apply-templates select="md:SPSSODescriptor"/>

            <!--
                Include an Organization if there isn't one there already.
            -->
            <xsl:choose>
                <xsl:when test="md:Organization">
                    <xsl:apply-templates select="md:Organization"/>
                </xsl:when>
                <xsl:otherwise>
                    <Organization>
                        <OrganizationName xml:lang="en">*** FILL IN ***</OrganizationName>
                        <OrganizationDisplayName xml:lang="en">*** FILL IN ***</OrganizationDisplayName>
                        <OrganizationURL xml:lang="en">http://*** FILL IN ***/</OrganizationURL>
                    </Organization>
                </xsl:otherwise>
            </xsl:choose>

            <!--
                Include a support contact if there isn't one.
            -->
            <xsl:choose>
                <xsl:when test="md:ContactPerson[@contactType='support']">
                    <xsl:apply-templates select="md:ContactPerson[@contactType='support']"/>
                </xsl:when>
                <xsl:otherwise>
                    <ContactPerson contactType="support">
                        <GivenName>*** FILL IN ***</GivenName>
                        <SurName>*** FILL IN ***</SurName>
                        <EmailAddress>mailto:*** FILL IN ***</EmailAddress>
                    </ContactPerson>
                </xsl:otherwise>
            </xsl:choose>

            <!--
                Include a technical contact if there isn't one.
            -->
            <xsl:choose>
                <xsl:when test="md:ContactPerson[@contactType='technical']">
                    <xsl:apply-templates select="md:ContactPerson[@contactType='technical']"/>
                </xsl:when>
                <xsl:otherwise>
                    <ContactPerson contactType="technical">
                        <GivenName>*** FILL IN ***</GivenName>
                        <SurName>*** FILL IN ***</SurName>
                        <EmailAddress>mailto:*** FILL IN ***</EmailAddress>
                    </ContactPerson>
                </xsl:otherwise>
            </xsl:choose>

            <!--
                Include an administrative contact if there isn't one.
            -->
            <xsl:choose>
                <xsl:when test="md:ContactPerson[@contactType='administrative']">
                    <xsl:apply-templates select="md:ContactPerson[@contactType='administrative']"/>
                </xsl:when>
                <xsl:otherwise>
                    <ContactPerson contactType="administrative">
                        <GivenName>*** FILL IN ***</GivenName>
                        <SurName>*** FILL IN ***</SurName>
                        <EmailAddress>mailto:*** FILL IN ***</EmailAddress>
                    </ContactPerson>
                </xsl:otherwise>
            </xsl:choose>

        </EntityDescriptor>
    </xsl:template>


    <!--
        ***********************************
        ***                             ***
        ***   D S   N A M E S P A C E   ***
        ***                             ***
        ***********************************
    -->


    <!--
        ds:KeyName

        Remove KeyName elements.
    -->
    <xsl:template match="ds:KeyName">
        <!-- do nothing -->
    </xsl:template>


    <!--
        Discard ds:X509SubjectName
    -->
    <xsl:template match="ds:X509SubjectName">
        <!-- do nothing -->
    </xsl:template>


    <!--
        *********************************************
        ***                                       ***
        ***   I D P D I S C   N A M E S P A C E   ***
        ***                                       ***
        *********************************************
    -->


    <!--
        idpdisc:DiscoveryResponse

        Add missing Binding attribute.
    -->
    <xsl:template match="idpdisc:DiscoveryResponse[not(@Binding)]">
        <idpdisc:DiscoveryResponse>
            <xsl:attribute name="Binding">urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol</xsl:attribute>
            <xsl:apply-templates select="node()|@*"/>
        </idpdisc:DiscoveryResponse>
    </xsl:template>


    <!--
        *****************************************
        ***                                   ***
        ***   M D R P I   N A M E S P A C E   ***
        ***                                   ***
        *****************************************
    -->

    <!--
        mdrpi:RegistrationInfo

        By definition, any RegistrationInfo element appearing within the input
        document should be discarded, as this is a new registration.
    -->
    <xsl:template match="mdrpi:RegistrationInfo"/>


    <!--
        *************************************
        ***                               ***
        ***   X S I   N A M E S P A C E   ***
        ***                               ***
        *************************************
    -->

    <!-- Remove xsi:type from any entity attribute values. -->
    <xsl:template match="saml:AttributeValue/@xsi:type"/>

    <!--
        *********************************************
        ***                                       ***
        ***   D E F A U L T   T E M P L A T E S   ***
        ***                                       ***
        *********************************************
    -->


    <!--By default, copy text blocks and attributes unchanged.-->
    <xsl:template match="text()|@*">
        <xsl:copy/>
    </xsl:template>


    <!--By default, copy all elements from the input to the output, along with their attributes and contents.-->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
