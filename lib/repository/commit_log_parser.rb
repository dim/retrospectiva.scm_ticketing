#--
# Copyright (c) 2009 
# Please read LICENSE document for more information.
#++
class Repository::CommitLogParser
  TICKET_REF     = /\[\#(\d+)\]/
  
  PROPERTY_KEY   = /\w+/
  QUOTED_VALUE   = /['"][^'"]+['"]/
  UNQUOTED_VALUE = /\w+/
  SEPARATOR      = / *: */  
  PROPERTY_ITEM  = /(#{PROPERTY_KEY})#{SEPARATOR}(#{QUOTED_VALUE}|#{UNQUOTED_VALUE})/  
  PROPERTY_BLOCK = /\(#{PROPERTY_ITEM}(?:[ ,]+#{PROPERTY_ITEM})*\)/
 
  attr_reader :commit_id, :log
  
  def initialize(commit_id, log)
    @commit_id = commit_id
    @log = log.to_s
  end
  
  # Yields a hash for each line which has a ticket reference
  def each(&block)
    log.each_line do |line|
      parsed = parse_line(line)
      yield parsed if parsed
    end
  end
      
  # Returns a hash of the id, properties and content (comment)
  def parse_line(line)    
    line = line.gsub(TICKET_REF, '')
    
    ticket_id = $1.to_i        
    return nil if ticket_id.zero?
    
    properties = format_properties(line.scan(PROPERTY_BLOCK))
    return nil if properties.blank?
    
    { :id => ticket_id, :content => content(line.gsub(PROPERTY_BLOCK, '').squish), :properties => properties }
  end

  protected

    def format_properties(properties)
      properties = properties.flatten.map do |value|
        value.gsub(/^['"]/, '').gsub(/['"]$/, '')
      end
      Hash[*properties]
    end

    def content(content)
      "[#{commit_id}] #{content.lstrip}".strip
    end

end
