class UltrasphinxResultsPage < Page
  include Radiant::Taggable
  include WillPaginate::ViewHelpers
  
  attr_reader :results
  
  def process_with_search(request, response)
    ultrasphinx_get_results(request, response)
    process_without_search(request, response)
  end
  alias_method_chain :process, :search
  
  def cache?
    false
  end
  
  def ultrasphinx_get_results(request, response)
      
    @query = request.parameters[:query] # is it safe? sanitize, maybe strip?
    @page = request.parameters[:page].blank? ? 1 : request.parameters[:page].to_i
    
    page = Page.find_by_slug(request.parameters[:url])
    @config = configure(page)
    
    config_excerpting_options(@config) if excerpt?
    
    @search = Ultrasphinx::Search.new(
      :per_page => @config[:per_page],
      :page => @page,
      :query => @query,
      :class_names => "Page",
      :weights => {'title' => 10.0}
      )
    excerpt? ? @search.excerpt : @search.run
    @results = @search.results
    logger.debug(">>>>>>>>>>>> #{@results.size}")
  end
  
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
    Renders the message if there are no results.
    
    *Usage:*
    <pre><code><r:unless_results>...</r:unless_results></code></pre>
  }
  
  tag 'unless_results' do |tag|
    message = tag.attr['message'] || %{<p>We are sorry but there are no results for this query!</p>}
    message unless @results.size > 0
  end
  
  private
    def configure(page)
      string = page.render_part(:sphinx)
      string.empty? ? {} : YAML::load(string).symbolize_keys
    end
    
    def excerpt?
      @config[:excerpt] || @config[:excerpt].nil?
    end
    
    def config_excerpting_options(config)
      Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
        :before_match => config[:before_match],
        :after_match => config[:after_match],
        :chunk_separator => config[:chunk_separator],
        :limit => config[:limit],
        :around => config[:around],
        :content_methods => [['page_part_content'], ['title']]
      })
    end
end