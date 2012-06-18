# Conventions for the `/mdx/` directory tree.

Each directory under `/mdx/` represents a source of metadata, referred to as a
channel. Each channel is named in the form "country_source", for example:
`us_incommon` is the channel name for the US's InCommon federation. Exceptions are made for the UK federation, whose channel is just
called `uk`, and for channels not associated with particular countries, which
are named as "int_source", for example `int_edugain`.

Each channel contains a number of Spring bean configuration files. The
`beans.xml` file is present in all channels.  In addition a channel may provide a
`verbs.xml` and/or `<verb>.xml` files implementing channel-specific verbs.  For example, a file called `test.xml` would be one place where you could put a verb called `test`.

## `beans.xml` conventions

Most beans defined within a channel appear in a `beans.xml` configuration file
within the channel directory.

As well as being available to channel-local operations, these beans are
available to operations involving more than one channel. Therefore, all beans
defined in `beans.xml` should be named with the channel name as a prefix in
order to avoid clashes when beans from more than one channel are brought
together at run time. For example, a bean which would naturally be called
`productionAggregate` would be named `us_incommon_productionAggregate` within
the `us_incommon` channel, `se_swamid_productionAggregate` within the
`se_swamid` channel and so on.

All beans defined in `beans.xml` should be set as `lazy-init="true"`. All
aggregator component beans should additionally declare
`init-method="initialize"`.

## Common `beans.xml` channel beans

channel_productionAggregate is a stage that fetches the source's production
aggregate

channel_exportAggregate is a stage that fetches the source's export aggregate.
Omitted if the source doesn't have an export aggregate.

channel_signingCertificate

channel_checkSignature

channel_exportedEntities is a composite stage which returns the source's
exported entities as a collection. If the source doesn't have an export
aggregate, it may instead derive a pseudo export collection from the
production aggregate.

## `verbs.xml` and `<verb>.xml` conventions

Verbs are operations that can be directly executed by the aggregator CLI. They
are implemented as aggregator pipeline objects named by the verb they
implement, without qualification by the channel name. A qualified name is not
required in this case because verbs are never called from other channels, only
from the CLI.

Verbs are defined either in a file named after the verb (e.g., `collect.xml`,
`import.xml`) or in a `verbs.xml` file. The Ant build file looks for a
specifically-named file first, then falls back to the `verbs.xml` file.

For example, executing the `import` verb on the `us_incommon` channel involves
looking for an `import.xml` file in the `us_incommon` directory. If this is
found, the `import` pipeline in `/mdx/us_incommon/import.xml` is invoked;
otherwise, the CLI is invoked on the `import` pipeline in
`/mdx/us_incommon/verbs.xml`.

Verb definition files should import the channel's `beans.xml` file as well as
the `common-beans.xml` file from the parent `/mdx/` directory through a relative
path.

Verb definition files should not import each other; any beans required to be
shared between verb definition files should be moved into the channel's
`beans.xml` file and given an appropriately channel-qualified name.

All aggregator component beans declared within a verb definition file should
declare `init-method="initialize"`. If more than one verb is defined in a
`verbs.xml` file, all beans within the file should also be set as
`lazy-init="true"`.
