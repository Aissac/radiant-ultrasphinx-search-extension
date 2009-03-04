# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class UltrasphinxSearchExtension < Radiant::Extension
  version "0.5"
  description "Radiant Extension for the Sphinx full text search engine using the Ultrasphinx Plugin"
  url "http://blog.aissac.ro/radiant/ultrasphinx-search-extension/"
  
  # define_routes do |map|
  #   map.connect 'admin/ultrasphinx_search/:action', :controller => 'admin/ultrasphinx_search'
  # end
  
  def activate
    Page.send :include, UltrasphinxSearch::PageExtensions
    Page.send :include, UltrasphinxSearch::UltrasphinxSearchTags
    # PagePart.send :include, UltrasphinxSearch::PagePartExtensions
    # admin.tabs.add "Ultrasphinx Search", "/admin/ultrasphinx_search", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Ultrasphinx Search"
  end
  
end