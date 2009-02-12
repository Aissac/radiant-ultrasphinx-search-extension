module UltrasphinxSearch
  module UltrasphinxSearchTags
    include Radiant::Taggable
    desc %{      
      Gives access to the search results.

      *Usage:*
      <pre><code><r:results>...</r:results></code></pre>
    }
    tag 'results' do |tag|
      tag.locals.results = tag.locals.page.results
      tag.expand
    end

    desc %{
      Cycles through each of the search results. Inside this tag the page attributes are mapped to the current result.

      *Usage:*
      <pre><code><r:results:each>...</r:results:each></code></pre>
    }

    tag 'results:each' do |tag|
      result = []
      @results.each do |r|
        tag.locals.page = r
        result << tag.expand
      end
      result
    end

    desc %{
      Presents the excerpted and highlighted content

      *Usage:*
      <pre><code><r:results:excerpt_content /></code></pre>
    }

    tag 'results:excerpt_content' do |tag|
      tag.locals.page.page_part_content
    end

    tag 'results:pagination' do |tag|
      renderer = RadiantLinkRenderer.new(tag, @query)

      options = {}
      [:class, :previous_label, :next_label, :inner_window, :outer_window, :separator].each do |a|
        options[a] = tag.attr[a.to_s] unless tag.attr[a.to_s].blank?
      end
      will_paginate @search, options.merge(:renderer => renderer, :container => false)
    end

    desc %{
      Renders only if there are results.

      *Usage:*
      <pre><code><r:if_results>...</r:if_results></code></pre>
    }

    tag 'if_results' do |tag|
      tag.expand if @results.size > 0
    end

    desc %{
      Renders if there are no results.

      *Usage:*
      <pre><code><r:unless_results>...</r:unless_results></code></pre>
    }

    tag 'unless_results' do |tag|
      tag.expand unless @results.size > 0
    end
  end
end