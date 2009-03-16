#--
# Copyright (c) 2009 Mathew Abonyi, Dimitrij Denissenko
# Please read LICENSE document for more information.
#++

# This extension to the Changeset model translates SCM ticket
# updates into actual changes on each referenced ticket.
Changeset.class_eval do
  after_create :parse_log_and_update_tickets!

  protected
  
    def parse_log_and_update_tickets!
      return true if bulk_synchronization || user.blank?

      Repository::CommitLogParser.new(revision, log).each do |reference|
        logger.info "\n\n[SCM Ticket Update] ------------------------------"
        logger.info "Detected reference: #{reference.inspect}"

        ticket = Ticket.find :first,
          :conditions => ['id = ? AND project_id IN (?)', reference[:id], projects.active.map(&:id)]
        
        if ticket && user.permitted?(:tickets, :update, :project => ticket.project)
          logger.debug "Updating ticket: #{ticket.id}"
          
          ticket_change = ticket.changes.new do |record|
            record.user = user
            record.set_attributes_from_scm_reference(reference)
          end
          
          if ticket_change.save
            logger.info "Successfully updated ticket: #{ticket.id}"
          else
            logger.info "Failed to update ticket: #{ticket.id}. #{ticket_change.errors.full_messages.inspect}"            
          end
        end        
      end      
    end

end
