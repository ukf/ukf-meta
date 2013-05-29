# `fr_renater` Channel

France -- RENATER federation

[Federation web site.](https://services.renater.fr/federation/en/index)

eduGAIN participant

## Metadata Signing Practices

The production metadata we are fetching may be an old format; it is signed using the certificate in `metadata-federation-renater.crt`, which is a self-signed certificate with a 1024-bit key, as follows:

    Issuer: C=FR, O=RENATER, CN=Certificat de signature des meta donnees de la federation Education-Recherche
    Validity
        Not Before: Mar 25 09:51:37 2009 GMT
        Not After : Mar 23 09:51:37 2019 GMT
    Subject: C=FR, O=RENATER, CN=Certificat de signature des meta donnees de la federation Education-Recherche

The eduGAIN aggregate, which is pulled from a different server, is signed with a different certificate:

    Issuer: C=FR, O=GIP RENATER, CN=AC metadata federation education-recherche/emailAddress=support-federation@support.renater.fr
    Validity
        Not Before: Mar 15 14:46:04 2013 GMT
        Not After : Mar 13 14:46:04 2023 GMT
    Subject: C=FR, O=GIP RENATER, CN=metadata federation education-recherche/emailAddress=support-federation@support.renater.fr

This is held in `renater-federation-metadata.crt`, and has a 2048-bit RSA key.  Note that this certificate is not self-signed, but is issued by the root CA held in `renater-federation-metadata-ca.crt`.