# frozen_string_literal: true

# It is a general success response json format
class ResultSuccess
  attr_reader :attributes, :status

  def initialize(attributes = {}, status = :success)
    @attributes = attributes
    @status = status
  end

  def successful?
    true
  end
end
