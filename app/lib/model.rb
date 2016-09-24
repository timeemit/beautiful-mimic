module Model
  def errors
    @errors ||= {}
    @errors
  end

  def valid?
    validate!
    errors.all? do |field, errors|
      errors.empty?
    end
  end

  private

  def validate!
    nil # To be overwrriten
  end

  def add_error(field, value)
    if errors[field]
      errors[field] << value
    else
      errors[field] = [ value ]
    end
  end

end
