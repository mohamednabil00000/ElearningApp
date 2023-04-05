# frozen_string_literal: true

# application record parent class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
