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
      { :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' } }
    ]
  end

  it 'should correctly parse split-commit lines' do
    parse("[#1234] fixed a little bug (status:fixed assigned:mabs)").should == [
      { :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' } }
    ]
  end

  it 'should correctly parse post-commit lines' do
    parse("fixed a little bug [#1234] (status:fixed assigned:mabs)").should == [
      { :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' } }
    ]
  end  

  it 'should correctly parse lines with lots of whitespaces' do
    parse("   [#1234]    fixed a little bug    (status:fixed assigned:mabs)   ").should == [
      { :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' } }
    ]    
  end

  it 'should correctly parse unusual property patterns' do
    parse("[#1234] fixed a little bug (status : \"fixed\" , assigned : mabs)").should == [
      { :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' } }
    ]    

    parse("fixed a little bug [#1234] (status :      \"fixed\" assigned :mabs)").should == [
      { :id => 1234, :content => '[REVABC] fixed a little bug', :properties => { 'status' => 'fixed', 'assigned' => 'mabs' } }
    ]
  end

  it 'should correctly parse quoted property values' do
    parse(%Q([#11](status:"Under Development") Fixed a little bug)).should == [
      { :id => 11, :content => '[REVABC] Fixed a little bug', :properties => { 'status' => 'Under Development' } }
    ]    
  end

  

  
  it 'should correctly parse multiple curly-bracket-blocks' do
    message = "[#16](status:Fixed user:schmidtw) Added support for on the fly switching between output sample frequencies & the extra desired frequencies (48kHz, 32kHz, 24kHz, 12kHz, 8kHz)."
    parse(message).should == [
      { :id => 16, :content => '[REVABC] Added support for on the fly switching between output sample frequencies & the extra desired frequencies (48kHz, 32kHz, 24kHz, 12kHz, 8kHz).', :properties => { 'status' => 'Fixed', 'user' => 'schmidtw' } }
    ]
  end
  
end