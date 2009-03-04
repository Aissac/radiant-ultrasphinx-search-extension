Ultrasphinx Search Radiant Extension
===

About
---

An extension by [Aissac][aissac] that adds Sphinx support to [Radiant CMS][radiant].

[Ultrasphinx search][uss] extension indexes the title and content of every page with a field boost applied to title. Note that your database is never changed by anything this extension does.

Instalation
---

### Installing Sphinx

First, obviously you need to install the Sphinx Engine itself. You can get it [here][0.9.8]. We used the [0.9.8][0.9.8] version. Unpack the run:

    ./configure --with-mysql
    make
    sudo make install

### Installing Ultrasphinx Rails plugin

Ultrasphinx has one gem dependency, the chronic gem

    sudo gem install chronic
    
Then proceed to install the [ultrasphinx plugin][usplugin] into your radiant project. We're using git submodules to install plugins:

    git submodule add git://github.com/fauna/ultrasphinx.git vendor/plugins/ultrasphinx</pre>
    
Ultrasphinx features out-of-the-box compatibility with [will_paginate][wp] which can be used as gem or git submodule. You need to either:

    sudo gem install mislav-will_paginate --source http://gems.github.com
    
or

    git submodule add git://github.com/mislav/will_paginate.git vendor/plugins/will_paginate

### Installing the Ultrasphinx Search Radiant Extension

At last, you need the [Ultrasphinxsearch][uss] Extension

    git submodule add git://github.com/aissac/ultrasphinx_search.git vendor/extensions/ultrasphinx_search
    
Now, the tricky part, configuring ultrasphinx. First, copy the `vendor/plugins/ultrasphinx/examples/default.base` file to `config/ultrasphinx/default.base`. This file sets up the Sphinx daemon options such as port, host, and index location.

    mkdir config/ultrasphinx
    cp vendor/plugins/ultrasphinx/examples/default.base config/ultrasphinx/default.base
    
You need to edit `config/ultrasphinx/default.base` and make two changes:


1. edit the line `<% path = "/opt/local/var/db/sphinx/"%>` and change it to the path where you want ultrasphinx to store the index and log files.
2. find the line that says `html_strip=0` and change it to `html_strip=1` because you wouldn't want Sphinx to index the HTML or Radius tags.

The [Ultrasphinx search][uss] Extension indexes the title and content of every page, so you don't need to worry about setting up indexes. It also gives a higher weight to the page title.

In your project root you need to create an `app/models` folder.

    mkdir -p app/models
    
Now, you're ready to start using Sphinx on your Radiant project. Run:
    rake ultrasphinx:configure    # rebuild the configuration file
    rake ultrasphinx:index        # reindexe and rotate all indexes
    rake ultrasphinx:daemon:start # start the search daemon
    
Further documentation on getting ultrasphinx working can be found [here][evanweaver] or [here][insoshi].

Usage
===

Configuration
---

You must define a page with the page type of `Ultrasphinx Results`. On this page you need to create a page part, named `sphinx` where you can configure the Sphinx results. The options are:

    excerpt: true
    before_match: '<strong>'
    after_match: '</strong>'
    chunk_separator: '...'
    limit: 256
    around: 3
    per_page: 10
    
### Available Tags

* See the “available tags” documentation built into the Radiant page admin for more details.
* Use `<r:if_results/>` and `<r:unless_results/>` to render only if there are results.
* Use `<r:results:each/>` to iterate over the results.
* Use `<r:excerpt_content/>` to display the highlighted results.
* Use `<r:results:pagination/>` to display the will_paginate pagination links.

### Example

Build the search form like this, where the action points to the Ultrasphinx Results page. The text field must have the name attribute set to `query`:

    <form action="/results">
      <input name="query" type="text" />
      <input type="submit" value="Search" />
    </form>
    
Note that you must set the `action` of the form to match the URL of the `Ultrasphinx Results` page defined earlier.

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

Known issues
===

A problem with Ultrasphinx is that it does not support delta indexing as it should be, meaning that there is no indexing on the after_save callback, so you need to manually (or using Cron job) index after the content has been updated.

Contributors
===


[radiant]: http://radiantcms.org/
[aissac]: http://aissac.ro
[uss]: http:/github/aissac/ultrasphinx_search
[0.9.8]: http://www.sphinxsearch.com/downloads.html
[sphinxsearch]: http://sphinxsearch.com/docs/current.html#installing
[usplugin]: http://github.com/fauna/ultrasphinx/tree/master
[wp]: http://github.com/mislav/will_paginate/tree/master
[evanweaver]: http://blog.evanweaver.com/files/doc/fauna/ultrasphinx/files/README.html
[insoshi]: http://blog.insoshi.com/2008/07/17/searching-a-ruby-on-rails-application-with-sphinx-and-ultrasphinx/