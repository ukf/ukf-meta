# UK federation Metadata Toolchain

This is the metadata repository and main toolset for the [UK Access Management Federation for Education and Research](http://ukfederation.org.uk) ("the UK federation").

## Private and Public Repository Variants

There are two variants of the repository:

* The private variant of the repository is used as part of UK federation operations.

* The public, read-only variant of the repository is made available on [GitHub](https://github.com/ukf/ukf-meta). If you're reading this, you're probably accessing this more restricted version. We provide it for the benefit of other federation operators who may be wondering how the UK federation systems operate, perhaps with a view to implementing something similar.

The public repository is kept roughly in synchronisation with the private one using [our `ukf-meta-meta` tools](https://github.com/ukf/ukf-meta-meta). We do this when we have made significant changes to the toolset and we think other federation operators may find the changes of interest.

We exclude a significant amount of material from the public repository. One reason for this is to save space: for example, the private repository retains a copy of every signed metadata aggregate we produced between 2005 and 2016.

The second main category excluded from the public repository is the historic registration database: version-controlled XML documents describing registered entities and the federation membership. We don't include this material because it may include personal information.

Since 2016, we have separated the entity database and aggregate record from the main toolchain repository, but the nature of Git is to never discard anything. We will therefore continue to make this repository publicly available only in redacted form.

## Copyright and License

The contents of this repository are Copyright (C) the named contributors or their
employers, as appropriate.

In particular, all content authored prior to the 1st of August 2016 is
Copyright (C) 2011&mdash;2016, University of Edinburgh.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

> <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
