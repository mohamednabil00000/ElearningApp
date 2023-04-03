# frozen_string_literal: true

class TalentCourse < ApplicationRecord
  belongs_to :course
  belongs_to :talent, class_name: :User

  validates_uniqueness_of :course_id, scope: :talent_id,
                                      message: I18n.t('errors.messages.course_already_taken_by_this_user')
  validates :status, inclusion: { in: %w[Not_started_yet In_progress Completed] }
end
