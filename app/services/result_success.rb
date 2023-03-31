# frozen_string_literal: true

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
