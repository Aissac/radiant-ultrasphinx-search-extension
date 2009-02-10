module UltrasphinxSearch
  module PageExtensions
    def self.included(base)
      base.class_eval do
        is_indexed :fields => ["title"],
                   :concatenate => [{:association_name => 'parts', :field => 'content', :as => 'page_part_content'}],
                   :delta => true
      end
      
      base.send(:include, InstanceMethods)
   end
   
   module InstanceMethods
     def page_part_content
       @page_part_content ||= parts.map { |part|
         part.filter.filter(part.content)
       }.join(' ')
     end
   end
  end
end