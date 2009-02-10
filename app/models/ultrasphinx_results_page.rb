class UltrasphinxResultsPage < Page
  include Radiant::Taggable
  
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
    
    @query = request.parameters[:query] # should it be safe? sanitize, maybe strip?
    
    page = Page.find_by_slug(request.parameters[:url])
    @config = configure(page)
    
    config_excerpting_options(@config) if excerpt?
    
    @search = Ultrasphinx::Search.new(
      :per_page => @config[:per_page],
      :query => @query,
      :class_names => "Page",
      :weights => {'title' => 10.0}
      )
    excerpt? ? @search.excerpt : @search.run
    @results = @search.results
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