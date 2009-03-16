#--
# Copyright (c) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
TicketChange.class_eval do

  def set_attributes_from_scm_reference(reference)
    set_attribute_if_present!(:content, reference[:content])
    reference[:properties].each do |name, value|
      set_attribute_from_scm_reference(name, value)
    end
  end
  
  protected
  
    def set_attribute_from_scm_reference(name, value)
      case name
      when /^assigned/, /^user/, 'u'
        set_attribute_if_present! :assigned_user, User.identify(value)
      when /^milestone/, 'm'
        set_attribute_if_present! :milestone, project.milestones.active_on(ticket.created_at).find(:first, :conditions => ['LOWER(name) LIKE ?', value.downcase])
      when /^status/, 's'
        set_attribute_if_present! :status, Status.find(:first, :conditions => ['LOWER(name) LIKE ?', value.downcase])
      when /^priority/, 'p'
        set_attribute_if_present! :priority, Priority.find(:first, :conditions => ['LOWER(name) LIKE ?', value.downcase])
      end
    end
  
    def set_attribute_if_present!(name, value)
      send("#{name}=", value) if value.present?
    end

end