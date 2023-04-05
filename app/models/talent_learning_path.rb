# frozen_string_literal: true

class TalentLearningPath < ApplicationRecord
  belongs_to :talent, class_name: :User
  belongs_to :learning_path
  belongs_to :current_talent_course, class_name: :TalentCourse

  validates_uniqueness_of :talent_id, scope: :learning_path_id,
                                      message: I18n.t('errors.messages.user_already_assigned_to_this_learning_path')
end
