# frozen_string_literal: true

class User < ApplicationRecord
  require 'securerandom'

  has_secure_password

  has_many :courses, foreign_key: :author_id
  has_many :learning_paths, foreign_key: :author_id
  has_many :talent_courses, dependent: :delete_all, foreign_key: :talent_id
  has_many :courses, through: :talent_courses
  has_many :talent_learning_paths, dependent: :delete_all, foreign_key: :talent_id
  has_many :learning_paths, through: :talent_learning_paths

  validates :password, length: { minimum: 8, maximum: 16, too_short: 'should be more than 7 chars',
                                 too_long: 'should be less than 17 chars' }, if: :password_required?
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: /\A.+@.+\.\w{2,6}\Z/, message: 'invalid format' }, if: :email_required?
  validates :username, presence: true
  validates_presence_of :password_confirmation, if: :password_digest_changed?

  private

  def password_required?
    password.present?
  end

  def email_required?
    email.present?
  end
end
