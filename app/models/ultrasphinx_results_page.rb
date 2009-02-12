class UltrasphinxResultsPage < Page
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
    @results = []
    
    page = Page.find_by_slug(request.parameters[:url])
    @config = configure(page)
    
    config_excerpting_options(@config) if excerpt?
    
    if !@query.blank?
      @search = Ultrasphinx::Search.new(
        :per_page => @config[:per_page],
        :page => @page,
        :query => @query,
        :class_names => "Page",
        :weights => {'title' => 10.0}
        )
      excerpt? ? @search.excerpt : @search.run
      @results = @search.results
    end
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