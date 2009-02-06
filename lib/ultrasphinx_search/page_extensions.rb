module UltrasphinxSearch
  module PageExtensions
    def self.included(base)
      base.class_eval do
        is_indexed :fields => ["title"]
      end
   end
  end
end