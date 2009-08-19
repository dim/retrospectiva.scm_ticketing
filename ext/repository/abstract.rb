Repository::Abstract.class_eval do
  protected

    def synchronize_with_log_parsing!(revisions)
      bulk_mode = revisions.size > 5      
      returning(synchronize_without_log_parsing!(revisions)) do |changesets|
        changesets.each {|c| c.send :parse_log_and_update_tickets! } if bulk_mode
      end
    end
    alias_method_chain :synchronize!, :log_parsing
    
end