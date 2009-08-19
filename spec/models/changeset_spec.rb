require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Changeset do
  fixtures :all

  def new_changeset(options = {})
    options.reverse_merge!(:revision => 'ABCDEFGH', :author => 'agent', :log => "[##{tickets(:open).id}] Fixed Problem (s:fixed u:agent)")
    repositories(:git).changesets.create(options)
  end

  it 'should create a valid changeset' do
    changeset = new_changeset
    changeset.should_not be_new_record
    changeset.projects.should have(1).record     
  end

  it 'should retain the original log message' do
    message = "[##{tickets(:open).id}](status:Fixed user:agent) Added support for on the fly switching between output sample frequencies & the extra desired frequencies (48kHz, 32kHz, 24kHz, 12kHz, 8kHz)."
    changeset = new_changeset(:log => message)
    changeset.should_not be_new_record
    changeset.log.should == message     
  end
  
  describe 'after a new changeset was created' do
  
    it 'should update the tickets' do
      ticket = tickets(:open)
      ticket.status.should == statuses(:open)
      new_changeset
      ticket.reload.status.should == statuses(:fixed)
      ticket.assigned_user.should == users(:agent)      
    end

    it 'should NOT update tickets if author cannot be found' do
      new_changeset(:author => 'noone')
      tickets(:open).status.should == statuses(:open)
      tickets(:open).assigned_user.should be_nil      
    end

    it 'should NOT update tickets if tickets cannot be found' do
      new_changeset(:log => '[#99] Fixed Problem (s:fixed u:agent)')
      tickets(:open).status.should == statuses(:open)
      tickets(:open).assigned_user.should be_nil      
    end

    it 'should NOT update tickets if user has no permission to do so' do
      groups(:Default).update_attribute(:permissions, {})
      tickets(:open).status.should == statuses(:open)
      tickets(:open).assigned_user.should be_nil      
    end
    
  end
  
  
end