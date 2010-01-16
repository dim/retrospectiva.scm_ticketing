require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Changeset do
  fixtures :all

  def changeset(options = {})
    options.reverse_merge!(:revision => 'ABCDEFGH', :author => 'agent', :log => "[##{tickets(:open).id}] Fixed Problem (s:fixed u:agent)")
    @changeset ||= repositories(:git).changesets.create(options)
  end

  it 'should create a valid changeset' do
    changeset.should_not be_new_record
    changeset.projects.should have(1).record     
  end

  it 'should retain the original log message' do
    message = "[##{tickets(:open).id}](status:Fixed user:agent) Added support for on the fly switching between output sample frequencies & the extra desired frequencies (48kHz, 32kHz, 24kHz, 12kHz, 8kHz)."
    changeset(:log => message).should_not be_new_record
    changeset.log.should == message     
  end

  describe 'after a new changeset was created' do
  
    it 'should update the tickets' do
      tickets(:open).status.should == statuses(:open)
      changeset.should_not be_new_record
      tickets(:open).reload.status.should == statuses(:fixed)
      tickets(:open).assigned_user.should == users(:agent)      
    end

    it 'should update tickets (with complex property names)' do
      message = %([##{tickets(:open).id}](status:"Under Development") Fixed a little bug)
      changeset(:log => message).should_not be_new_record
      tickets(:open).reload.status.should == statuses(:under_development)
    end

    it 'should NOT update tickets if author cannot be found' do
      changeset(:author => 'noone').should_not be_new_record
      tickets(:open).status.should == statuses(:open)
      tickets(:open).assigned_user.should be_nil
    end

    it 'should NOT update tickets if tickets cannot be found' do
      changeset(:log => '[#99] Fixed Problem (s:fixed u:agent)').should_not be_new_record
      tickets(:open).status.should == statuses(:open)
      tickets(:open).assigned_user.should be_nil      
    end

    it 'should NOT update tickets if user has no permission to do so' do
      groups(:Default).update_attribute(:permissions, {})
      changeset.should_not be_new_record
      tickets(:open).status.should == statuses(:open)
      tickets(:open).assigned_user.should be_nil      
    end
    
  end
  
  
end