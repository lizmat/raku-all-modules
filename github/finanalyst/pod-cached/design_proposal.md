# A Redesign of the Perl 6 Documentation System

## Current state

The github repo perl6/doc contains
- some tools and content to create all the `html` files starting at `https://doc.perl6.org`
- documentation in pod6 format for Perl6 under directory `doc`, mostly in three sub-directories
    - `Language/` contains tutorials and reference
    - `Programs/` contains three pod files relating to debugging
    - `Type/` contains pod6 related to lower-level content.
- the files for creating `perl6doc`

In order to generate the files locally (into the directory `html`)
- the local machine needs perl6, several perl6 modules, a working node.js (to generate highlighted code)
- other dependencies not documented, `npm` is required, which required `sudo apt install libssl1.0-dev nodejs-dev node-gyp npm`

The generation process is as follows:
- `util/manage-page-order.p6` is called
    - all files are copied from the `doc/` directory to `build/`
    - the files in the `Language` section are re-named and ordered according to `00-CONTROL-POD6`
- `pod2onepage` is called (it is in the rakudo-star distribution) to generate a single file `html/perl.html`
- `htmlify.p6` is called
    - Each `build` subdirectory is processed and pages are classified into `kinds`
    - A global register `$*DR` is generated containing information about each pod6 file and every reference and link in all the pod6 files
    - html files are created for each page using the `POD::To::HTML` Perl 6 module.
    - `index.html` files are generated for each section of `doc.perl6.org`
    - a `search.js` is generated and placed in the html/assets directory. This file is written with explicit references to all search items
    - perl5 functions are handled separately to perl6 functions and included in the search js
    - two categories of extra pages - for syntax and for routines are generated.

## Weaknesses
This system has been cultivated over a long period of time by various individuals. This has led to:
- functions spread around `htmlify.p6`, `manage-page-order.p6`, `Pod::To::HTML`,
`PERL6::Documentable`, `Pod::To::BigPage`
- functionality is repeated, eg., `badcharacters` and html encoding
- low level of testing, so changing htmlify.p6 can appear to be OK, only for it to produce html files with incorrect links.
- a mixture of hard-coded html generation, and few templates
- a great deal of code in the repo that is not used
- at least one function (disambiguation) which take a long time to complete, but whose purpose no one quite remembers,
and yet because there are few tests, no one wants to remove.
- links in pod6 files are hard-coded, meaning that if the link is to another pod6 file and that file name changes, the link is broken.

## Desirable Features of a Documentation System
- Separation of content and presentation.
    - The processing of the pod files (in this context the content) is currently tightly linked to the presentation (the html)
- Ability to manage multiple languages - the current system has no provision for multiple languages, which means
that when someone translates it into another language (highly desirable), the whole system has to be held in another repository, the new language cannot easily use the html conversion system, and there is utterly no provision for synchronising different languages
    - This element is not specifically addressed again, but the proposed design should enable multiple languages more easily.
- Extensibility of search functionality
    - By indexing the pod separate to generating (eg) html, different types of search function can be created.

# Development Principles
- The pod6 files are a rich source of content and their internal design should not be fundamentally changed
- The pod6 files with content should be changeable in terms of what they contain, and whether they can be split into other files, and what those files should be called.
    - The linking strategy may need revising (when linking to other documents within the set of source pod files)
    - Any change in link strategy should be easily handled automatically.
- Separation of software for operating on documentation set, and software for creating rendering, eg. to html pages
- Three sets of tests
    - Validity of pod files and integrity of pod collection
    - Tests of utility software
    - Tests of finally rendered product
- Strategy of processing
    - The pod collection is processed to validate the pod, create a cache, index items, create a toc, create a dependency tree mapping source pod to index and toc items.
    - The pod collection may then be processed to create subsidiary pod items, updating the cache, index, toc, and a dependency tree
    - Pod blocks are taken from cache and rendered into pages, generating a dependency tree, mapping source pod to pages.
    - Each time a source pod file is changed, the dependency trees are used to update the pod collection and html pages.
    - Templates are used to produce different formats, eg., HTML, md
    - A config file is used to map source & secondary pod files in the collection to multiple or a single output.
    - The default would be html output to a single page.

# Targets and References
Since the documentation makes extensive use of links to other parts of the documentation, care needs to be given to targets. In the Constraints section, some constraints are placed on a target for a cross-documentation reference.
- The proposal requires the insertion of targets in the pod files.
- Anchors are defined in the config for pod blocks, eg `=head some text :anchor<a-pod-file-name-some-text>`

# Documentation Constraints
1. Documentation consists of 'chapters', which start with pod title and subtitle
1. A chapter is contained in a uniquely named pod file.
1. The set of all Documentation pod files under `/doc/` is called "`doc-set`"
    - name of files, arrangement within sub-directories irrelevant.
1. The `doc-set` may be programmatically enhanced with derived pod files.
    - Derived pod files must be placed under the subdirectory `/doc/derived/`
1. Within `doc-set`
    - all targets, independent of chapter, must be **uniquely** named wrt `doc-set`
    - link references inside `doc-set` have custom URL type `doc://`
1. chapters contain referential items,
    - an item may be marked in some existing pod manner, eg., a target, a header, a code definition, X<> pod element
    - an item may be defined by a regex.
    - the (search) target generated by an item is the line on which the item appears

### Justification of this set of definitions.
- by making `doc-set` target names unique, it does not matter which final rendering format chapters are eventually mapped to. The rendering of a target (in html, the `href` of an anchor) depends on the rendering strategy.
- search functionality also can rely on unique targets
- defining referential items by regex and by explicit marking allows for new types of search
  - Since updates to the pod files trigger target/reference testing and synchronisation only for the pod file, synchronisation  between languages can be built on git repo diffs.

# Development strategy
- Combine `Pod::To::HTML` and `Pod::To::BigPage` into a new `Pod::Cached`
    - `Pod::Cached` will only be concerned with creating and maintaining a pod cache and indexation.
- Create a Rendering modules to replace all HTML generation with templates, using Mustache
- Allow for one-page or multiple pages using configuration files, the goal being to replicate the output of both the other P2* modules.
- Move the code for generating the extra pod pages for Routines and Syntax to a separate processor, rather than in htmlify.p6
- Implement the new linking strategy.

### Initializing the `doc-set`
- pod files in documentation do not currently contain unique targets
- link references to documentation use pod filename and section headings.
- tools needed to
    - identify link references
    - create unique target name (based on existing filename/heading)
    - insert target with unique name into pod

## Tools for testing documentation
- verify chapter is valid pod6 and has titles/subtitles
- verify all links conform to acceptable URLs (eg doc:// or https://)
- verify all link targets in `doc-set` are unique
- identify code sections, verify code.

## Tools for indexing documentation
- verify targets in a pod file are unique by referencing the data structure
    - if a pod file contains a target name that already exists in the datastructure for another pod file, then the non-compliance is reported, and the data structure is not affected.
- identify all referential items in a pod file, and add to the datastructure
    - to allow for flexibility, referential items are defined in a Grammar.
    - new referential items are added by adding a rule to the Grammar.
- the position for the data structure of a target or referential item is by line number in the pod file. (It is for the rendering software to implement the linking).
- the datastructure is serialised, eg., as a JSON file. Suggested names: `references.json`, `toc.json`
> NOTE this implies that the documentation suite consists of pod6 files, references.json and toc.json

1. pod file tools are run only when the pod file is modified.
1. The tools are run on the whole `doc-set` periodically to ensure `doc-set` remains consistent

## Reference Data Structure
- The data structure is created to exist as a hash in a Perl 6 program
- Two main keys: <files> and <items>
    - <files> contains a hash of ( 'filename' => @list-of-references )
    - <items> contains a hash of ('item-name' => ('filename' => <pod6 file name>, 'line-start' => <number of line for reference> , 'title' => <string to be used to render reference> ))

## Repo Structure
The following is the directory structure of the repo
- `doc/`  source pod files
    - `references.json`  the serialised data structure indexing all of the documentation
    - *subdirectories*
    - `derived/`
        - *subdirectories*
- `cache/` directory with pods cached

# Rendering
Documentation rendering heavily depends on purpose, and since there are multiple purposes, documentation design should presuppose multiple renderings.
1. A rendering may not change `doc-set`
1. A rendering may not change`references.json` or `toc.json`
1. Rendering should be done in a separate folder, eg., `simple-html`

## Simple-html strategy
This aims to reproduce the current web site.
- It generated html pages for each Chapter
- It generates extra html pages for subsections
- It generates a `search.js` function added to each web-page.
