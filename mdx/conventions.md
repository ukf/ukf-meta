# Conventions for the `/mdx/` directory tree

This document describes the current conventions for the metadata aggregation framework used by the UK federation, and contained in the `/mdx/` directory tree.

Because these conventions have been developed over time, and are still being developed, not all of them are currently implemented by all parts of the framework.  These conventions should be applied in their then-current state for any new work, and when significant changes are made to existing code.

## Ruleset Directory

The `_rules` subdirectory of `/mdx/` holds checking rulesets.  The underscore at the start of the directory name is intended to be used as a continuing convention to allow functional subdirectories to be distinguished from channels.

## Channels

Each directory under `/mdx/` whose name does not start with an underscore
represents a source of metadata, referred to as a
channel. In most cases, a channel corresponds to a access management federation.

Most channels are named in the form "*country*`_`*source*".  For example,
`us_incommon` is the channel name for the US's InCommon federation.
Channels not associated with particular countries are named as "`int_`*source*",
for example `int_edugain`.

Exceptions are made for the UK federation, whose channel is just
called `uk`, and for a test channel called `test`.

Each channel's directory contains resources associated with the channel, such
as X.509 certificates for signature verification, and a number of Spring bean configuration files.

The `beans.xml` file is present in all channels and defines the channel's public API for
use by other channels.
 
A channel may also provide a number of Spring configuration files implementing
channel-specific verbs, named `verbs.xml` and/or `<verb>.xml`.

Most channels contain a non-versioned file called `imported.xml`.  This is not a Spring
configuration file, but is used as the result of import verbs performed on the channel.

Documentation for the channel, if any, can appear either as comments within the channel's `beans.xml`, or as Markdown in a file called `readme.md`.

## General Spring conventions

Because many more beans are defined than will be used in any particular operation, all Spring configuration files should include the `default-lazy-init="true"` option on the root `<beans>` element.  This means that beans are only created when they are first used; unused beans are not created and initialised and thus take up no resources.  One downside of this is that bean configuration errors may be deferred until the bean is first used, so new bean definitions and changes to bean definitions need to be explicitly tested before being checked in to the repository.

All aggregator component beans should declare `init-method="initialize"`.

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

## Aggregates

Most federations publish more than one metadata aggregate.  We use the following conventional names for some of the more common cases:

* `production` is the primary aggregate published for the benefit of a federation's own members.  Some federations have more than one such aggregate, so that names like `productionIdps` and `productionSps` are necessary.
* `test` is an aggregate published for testing purposes.
* `export` is an aggregate published for consumption by peers (other federations) in general.
* `edugain` is an export aggregate published for consumption by eduGAIN.
* `uk` is an export aggregate published specifically for consumption by the UK federation.

Aggregate names such as the above are used in the construction of bean names:

* `channel_xxxAggregate` is a stage that fetches the channel's `xxx` aggregate.
* `channel_xxxEntities` is a stage that fetches the channel's `xxx` aggregate, disassembles it into a collection of entites and then processes those entities for UK federation consumption.

As well as the physical aggregates published by a federation, the name `exported` is used (as for example in the bean name `channel_exportedEntities`) to represent the aggregate that either is that used for import by the UK federation, or is closest in spirit to that purpose.  This aggregate is usually selected as follows, in descending order of preference:

* The channel's `uk` aggregate, if it has one.
* The channel's `export` aggregate, if it has one.
* The channel's `edugain` aggregate, if it has one.
* The channel's `production` aggregate.

Thus, most channels would be expected to contain the following beans as part of their API:

* `channel_exportedAggregate`
* `channel_exportedEntities`

In older channels, these are explicit bean definitions.  In newer channels, the convention is to use the Spring <alias> feature to designate the existing aggregate-specific beans.

## Common `beans.xml` channel beans

*channel*`_signingCertificate`

*channel*`_checkSignature`

## Verbs

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

The most common verbs function by fetching, optionally processing as if for UK import, and then serialising into the channel's `imported.xml`, one of the channel's aggregates.  These verbs have named constructed with the aggregate name as a suffix, with an initial capital.  The *omission* of processing for UK import is indicated by an additional suffix of `raw`.  For example:

* `importProductionRaw` fetches and re-serialises the channel's `production` aggregate without otherwise processing it.
* `importProduction` fetches the channel's production aggregate, disassembles it into a collection, processes that collection for import, and finally serialises an `<EntitiesDescriptor>` containing the surviving entities.

The verbs `import` and `importRaw` are intended to be a synonym for `importExported` and `importExportedRaw` respectively.  However, in many of the older channels they are in fact equivalent to `importExported` and `importProductionRaw`, which in turn may not be explicitly present.

## `verbs.xml` and `<verb>.xml` conventions

Verb definition files should import the channel's `beans.xml` file as well as
the `common-beans.xml` file from the parent `/mdx/` directory through a relative
path.

Verb definition files should not import each other; any beans required to be
shared between verb definition files should be moved into the channel's
`beans.xml` file and given an appropriately channel-qualified name.
