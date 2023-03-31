# frozen_string_literal: true

# It is a general error response json format
class ResultError
  attr_reader :status

  def initialize(errors = {}, status = :error)
    @errors = errors
    @status = status
  end

  def attributes
    errors
  end

  def successful?
    false
  end

  private

  attr_reader :errors
end
