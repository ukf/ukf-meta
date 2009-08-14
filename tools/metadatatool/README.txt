This folder contains all the required resources required to run the
metadatatool application used in UK federation metadata signature.

This bundle was originally derived from a version of the Shibboleth
1.3 identity provider software.

Contents:

* The endorsed folder contains specific versions of Xerces and Xalan, and
should be endorsed for the Java runtime.  Other versions of Xerces and
Xalan, and in particular the ones built in to versions of the Java runtime,
are known to give different results with this application.

* The lib folder contains the shib-util.jar containing the implementation of
metadatatool, along with all required dependencies.

The main class to execute is edu.internet2.middleware.shibboleth.utils.MetadataTool
