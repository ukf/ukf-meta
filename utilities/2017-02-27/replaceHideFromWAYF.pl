#!/usr/bin/perl -wni

# If line contains HideFromWAYF, replace it with the Entity Category
if (/HideFromWAYF/) {
    print <<EOF;
        <mdattr:EntityAttributes>
            <saml:Attribute Name="http://macedir.org/entity-category" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri">
                <saml:AttributeValue>http://refeds.org/category/hide-from-discovery</saml:AttributeValue>
            </saml:Attribute>
        </mdattr:EntityAttributes>
EOF
# and don't print the line containing HideFromWAYF
    next;
}

# If the line didn't have HideFromWAYF, print it unchanged
print;

