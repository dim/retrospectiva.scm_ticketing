require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketChange do
  fixtures :all
  
  before do
    @ticket = tickets(:open)
    @change = @ticket.changes.new
  end
  
  describe 'updating content' do
    
    it 'should update' do
      @change.set_attributes_from_scm_reference(:properties => {}, :content => 'Fixed Bug')
      @change.content.should == 'Fixed Bug'
    end

    it 'should not update if not present' do
      @change.set_attributes_from_scm_reference(:properties => {}, :content => '')
      @change.content.should be_nil
    end
    
  end

  describe 'updating assigned user' do
    
    it 'should update by username' do
      @change.set_attributes_from_scm_reference(:properties => { 'user' => 'agent' })
      @change.assigned_user.should == users(:agent)
    end

    it 'should update by email' do
      @change.set_attributes_from_scm_reference(:properties => { 'user' => 'agent@somedomain.com' })
      @change.assigned_user.should == users(:agent)
    end

    it 'should update by alternative key' do
      @change.set_attributes_from_scm_reference(:properties => { 'assigned' => 'agent' })
      @change.assigned_user.should == users(:agent)
    end

    it 'should update by short key' do
      @change.set_attributes_from_scm_reference(:properties => { 'u' => 'agent' })
      @change.assigned_user.should == users(:agent)
    end

    it 'should not update if user cannot be found' do
      @change.set_attributes_from_scm_reference(:properties => { 'user' => 'me' })
      @change.assigned_user.should be_nil
    end

  end

   describe 'updating milestone' do
    
    it 'should update by name' do
      @change.set_attributes_from_scm_reference(:properties => { 'milestone' => 'next release' })
      @change.milestone.should == milestones(:next_release)
    end

    it 'should update by name (case insensitive)' do
      @change.set_attributes_from_scm_reference(:properties => { 'milestone' => 'Next Release' })
      @change.milestone.should == milestones(:next_release)
    end

    it 'should update via shortcut' do
      @change.set_attributes_from_scm_reference(:properties => { 'm' => 'Next Release' })
      @change.milestone.should == milestones(:next_release)
    end

    it 'should not update if milestone cannot be found' do
      @change.set_attributes_from_scm_reference(:properties => { 'milestone' => 'invalid' })
      @change.milestone.should be_nil
    end

  end

   describe 'updating status' do
    
    it 'should update by name' do
      @change.set_attributes_from_scm_reference(:properties => { 'status' => 'fixed' })
      @change.status.should == statuses(:fixed)
    end

    it 'should update by name (case insensitive)' do
      @change.set_attributes_from_scm_reference(:properties => { 'status' => 'FIXED' })
      @change.status.should == statuses(:fixed)
    end

    it 'should update via shortcut' do
      @change.set_attributes_from_scm_reference(:properties => { 's' => 'fixed' })
      @change.status.should == statuses(:fixed)
    end

    it 'should not update if status cannot be found' do
      @change.set_attributes_from_scm_reference(:properties => { 'status' => 'accomplished' })
      @change.status.should == statuses(:open)
    end

  end
  
  describe 'updating priority' do
    
    it 'should update by name' do
      @change.set_attributes_from_scm_reference(:properties => { 'priority' => 'major' })
      @change.priority.should == priorities(:major)
    end

    it 'should update by name (case insensitive)' do
      @change.set_attributes_from_scm_reference(:properties => { 'priority' => 'MAJOR' })
      @change.priority.should == priorities(:major)
    end

    it 'should update via shortcut' do
      @change.set_attributes_from_scm_reference(:properties => { 'p' => 'major' })
      @change.priority.should == priorities(:major)
    end

    it 'should not update if priority cannot be found' do
      @change.set_attributes_from_scm_reference(:properties => { 'priority' => 'invalid' })
      @change.priority.should == priorities(:normal)
    end

  end
  
  describe 'multiple updates' do
    
    it 'should update all attributes' do
      @change.set_attributes_from_scm_reference( :properties => { 'status' => 'Fixed', 'user' => 'agent' } )      
      @change.status.should == statuses(:fixed)
      @change.assigned_user.should == users(:agent)
    end
    
  end

end