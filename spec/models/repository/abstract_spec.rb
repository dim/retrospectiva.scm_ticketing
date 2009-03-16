require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Repository::Abstract do
  fixtures :all
  
  before do
    @repository = repositories(:svn)    
  end

  describe 'bulk synchronization' do
    
    it 'should update the tickets after the synchronisation' do
      @changeset = mock_model(Changeset)
      @repository.should_receive(:synchronize_without_log_parsing!).and_return([@changeset])
      @changeset.should_receive(:parse_log_and_update_tickets!)
      @repository.sync_changesets
    end
    
    it 'should perform correctly' do
      @repository.sync_changesets      
      @repository.changesets.should have(10).records
    end

  end
end