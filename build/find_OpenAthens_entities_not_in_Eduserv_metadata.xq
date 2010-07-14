xquery version "1.0";
declare default element namespace "urn:oasis:names:tc:SAML:2.0:metadata";
(:This xquery script finds all Eduserv entities that appear in UK Federation metadata
 :but not in the Eduserv metadata.
 :It returns the UK Federation ID and the entityID
 :
 :To run this, you can use the xquery debug perspective in Eclipse, or in Oxygen.
 :You could also download the free version of Saxon from http://saxon.sourceforge.net/
 :and include saxon8.jar in your classpath and then run 
 :
 :java net.sf.saxon.query find_OpenAthens_entities_not_in_Eduserv_metadata.xq
 :
 :The output is an XML file listing the entityID's of Eduserv entities that appear in
 :UK Federation metadata but not in the Eduserv metadata.
 :
 :Gary Gray
 :13 July 2010
 :)
 <Entities>
 {
for $f in doc("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")/EntitiesDescriptor/EntityDescriptor[Organization/OrganizationName='Eduserv']
where $f/@entityID[not(. = /doc("https://auth.athensams.net/saml/metadata?name=ukfederation")/EntitiesDescriptor/EntityDescriptor/@entityID)]
return
<Entity ID="{data($f/@ID)}">{data($f/@entityID)}
</Entity>
}
</Entities>