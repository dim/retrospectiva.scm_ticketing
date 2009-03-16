require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Repository::CommitLogParser do  
  def parse(line)
    result = []
    Repository::CommitLogParser.new('REVABC', line).each do |parsed|
      result << parsed
    end
    result
  end

  it 'should ignore lines without a ticket reference' do
    parse("(status:fixed assigned:mabs) fixed a little bug").should == []
  end

  it 'should ignore lines without property changes' do
    parse("[#1234] fixed a little bug").should == []
  end

  it 'should correctly parse pre-commit lines' do
    parse("[#1234](status:fixed assigned:mabs) fixed a little bug").should == [
      :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' }
    ]
  end

  it 'should correctly parse split-commit lines' do
    parse("[#1234] fixed a little bug (status:fixed assigned:mabs)").should == [
      :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' }
    ]
  end

  it 'should correctly parse post-commit lines' do
    parse("fixed a little bug [#1234] (status:fixed assigned:mabs)").should == [
      :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' }
    ]
  end  

  it 'should correctly parse lines with lots of whitespaces' do
    parse("   [#1234]    fixed a little bug    (status:fixed assigned:mabs)   ").should == [
      :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' }
    ]    
  end

  it 'should correctly parse unusual property patterns' do
    parse("[#1234] fixed a little bug (status : \"fixed\" , assigned : mabs)").should == [
      :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' }
    ]    

    parse("fixed a little bug [#1234] (status :      \"fixed\" assigned :mabs)").should == [
      :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' }
    ]    
  end
  
end