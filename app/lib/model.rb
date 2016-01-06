class Model
  attr_reader :errors

  def initialize
    @errors = Hash.new([])
  end

  def valid?
    validate!
    @errors.all? do |field, errors|
      errors.empty?
    end
  end

  private

  def validate!
    nil # To be overwrriten
  end

  def add_error(field, value)
    if @errors[field].empty?
      @errors[field] = [ value ]
    else
      @errors[field] << value
    end
  end

end
