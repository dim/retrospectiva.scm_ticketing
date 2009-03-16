require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Changeset do
  fixtures :all

  def new_changeset(options = {})
    options.reverse_merge!(:revision => 'ABCDEFGH', :author => 'agent', :log => '[#1] Fixed Problem (s:fixed u:agent)')
    repositories(:svn).changesets.create(options)
  end

  it 'should create a valid changeset' do
    changeset = new_changeset
    changeset.should_not be_new_record
    changeset.projects.should have(1).record     
  end
  
  describe 'after a new changeset was created' do
  
    it 'should update the tickets' do
      new_changeset
      tickets(:open).status.should == statuses(:fixed)
      tickets(:open).assigned_user.should == users(:agent)      
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