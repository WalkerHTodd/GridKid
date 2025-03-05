class Token
    attr_reader :type, :value, :start_index, :end_index
  
    def initialize(type, value, start_index, end_index)
      @type = type
      @value = value
      @start_index = start_index
      @end_index = end_index
    end
  end
  