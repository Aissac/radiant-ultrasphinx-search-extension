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
    
    @query = "post"
    
    Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
    :before_match => '<span style="background-color: yellow;">',
    :after_match => '</span>',
    :chunk_separator => "...",
    :limit => 256,
    :around => 3,
    :content_methods => ['title', 'content']
    })
    
    @search = Ultrasphinx::Search.new(:query => @query)
    # @search.run
    @search.excerpt
    @results = @search.results
  end
  
  tag 'results' do |tag|
    tag.locals.results = tag.locals.page.results
    tag.expand
  end
  
  tag 'results:each' do |tag|
    result = []
    @results.each do |r|
      tag.locals.page = r
      result << tag.expand
    end
    result
  end  
end