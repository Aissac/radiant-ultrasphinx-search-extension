Ultrasphinx Search
===

About
---

An extension by [Aissac][aissac] that adds Sphinx support to [Radiant CMS][radiant].

Ultrasphinx search extension indexes the title and content of every page with a field boost applied to title. Note that your database is never changed by anything this extension does.

Instalation
---

First, obviously, you need to install the Sphinx Engine itself. You can get it [here][0.9.8]. We used the [0.9.8][0.9.8] version. Unpack the run:

    ./configure --with-mysql
    make
    sudo make install

Ultrasphinx has one gem dependency, the chronic gem

    sudo gem install chronic

Then proceed to install the [ultrasphinx plugin][usplugin]. We're using git submodules to install plugins/extensions:

    git submodule add git://github.com/fauna/ultrasphinx.git vendor/plugins/ultrasphinx

Ultrasphinx features out-of-the-box compatibility with [will_paginate][wp], which can be used as gem or git submodule:

    git submodule add git://github.com/mislav/will_paginate.git vendor/plugins/will_paginate
    or
    sudo gem install mislav-will_paginate

At last, you need the Ultrasphinx search Extension

    git submodule add git://github.com/aissac/ultrasphinx_search.git vendor/extensions/ultrasphinx_search

Now, the tricky part, configuring ultrasphinx. First, copy the `examples/default.base` file to `RADIANT_ROOT/config/ultrasphinx/default.base`. This file sets up the Sphinx daemon options such as port, host, and index location. You need to set `html_strip = 1` because you wouldn't want Sphinx to index the html or radiant tags. The Ultrasphinx_search Extension indexes the title and content of every page, so you don't need to worry about setting up indexes. It also gives a higher weight to the page title.

In the RADIANT_ROOT you need to create an `app/models` folder. (This has to go, maybe in 1.1)

Now, you're ready to start using Sphinx on your Radiant project. Run:

    rake ultrasphinx:configure - which rebuilds the configuration file for the development environment.
    sudo rake ultrasphinx:index (why sudo?) - which re-indexes and rotates all indexes.
    sudo rake ultrasphinx:daemon:start -  which starts the search daemon.

A problem with Ultrasphinx  is that it does not support delta indexing as it should be, meaning that there is no indexing on the after_save callback, so you need to manually (or using Cron job?) index after the content has been updated.
    
Further documentation on getting ultrasphinx working can be found [here][evanweaver] or [here][insoshi]

Usage
---

### Configuration

Ultrasphinx search Extension offers an `Ultrasphinx Results` page type.

On this `Ultrasphinx Results` page you need to create a page part, named `sphinx` where you can configure the Sphinx results. The options are:

    excerpt: true
    before_match: '<strong>'
    after_match: '</strong>'
    chunk_separator: '...'
    limit: 256
    around: 3
    per_page: 10

### Available Tags

* See the "available tags" documentation built into the Radiant page admin for more details.
* Use the `<r:if_results>...</r:if_results>` and `<r:unless_results>...</r:unless_results>` conditional tags to render only if there are results
* Use the `<r:results:each>...</r:results:each>` to cycle through the results.
* Use the `<results:excerpt_content />` to display the highlighted results.
* Use the `<results:pagination />` to display the will_paginate pagination links.

#### Example

Build the search form like below, where the action points to the Ultrasphinx Results page. The text field must have the name attribute set to `query`:

    <form action="/results">
      <input type="text" name="query" />
      <input type="submit" value="Search" />
    </form>

On the Ultrasphinx Results page:

    <r:if_results>
      <r:results:each>
        <r:link /><br />
        <r:excerpt_content /> <br />
        <hr />
      </r:results:each>
      <r:results:pagination />
    </r:if_results>
    <r:unless_results>
      <p>There are no results</p>
    </r:unless_results>
    
TODO
---

Contributors
---

[radiant]: http://radiantcms.org/
[aissac]: http://aissac.ro
[0.9.8]: http://www.sphinxsearch.com/downloads.html
[sphinxsearch]: http://sphinxsearch.com/docs/current.html#installing
[usplugin]: http://github.com/fauna/ultrasphinx/tree/master
[wp]: http://github.com/mislav/will_paginate/tree/master
[evanweaver]: http://blog.evanweaver.com/files/doc/fauna/ultrasphinx/files/README.html
[insoshi]: http://blog.insoshi.com/2008/07/17/searching-a-ruby-on-rails-application-with-sphinx-and-ultrasphinx/