class RadiantLinkRenderer < WillPaginate::LinkRenderer
  def initialize(tag, query)
    @tag = tag
    @query = query
  end
  
  def page_link(page, text, attributes = {})
    %Q{<a href="#{@tag.locals.page.url}?page=#{page}&query=#{@query}">#{text}</a>}
  end

  def page_span(page, text, attributes = {})
    "<span class=\"page\">#{text}</span>"
  end
end