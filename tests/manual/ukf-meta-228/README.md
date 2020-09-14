# Tests for discarding inappropriate metadata on entity registration

sp.xml and idp.xml have EntityAttribute elements that we wish to discard on import
because most Entity Attributes require some checking by the helpdesk.

sp.xml and idp.xml also include elements in the ukfedlabel namespace that
have been seen on import, presumably they have been cut-and-pasted into
the EntityDescriptor by the entity operator
