# frozen_string_literal: true

module Api
  module V1
    class TalentLearningPathService
      def create(learning_path:, talent:)
        talent_learning_path = TalentLearningPath.new(learning_path_id: learning_path.id, talent_id: talent.id)

        talent_learning_path.current_talent_course_id = get_available_course(courses: learning_path.courses,
                                                                             talent_id: talent.id)
        if talent_learning_path.save
          ResultSuccess.new(
            talent_learning_path: talent_learning_path_presenter.present(talent_learning_path: talent_learning_path)
          )
        else
          ResultError.new(errors: talent_learning_path.errors.full_messages)
        end
      end

      def destroy(learning_path_id:, talent_id:)
        talent_learning_path = TalentLearningPath.find_by(learning_path_id: learning_path_id, talent_id: talent_id)
        talent_learning_path&.destroy
        ResultSuccess.new
      end

      def show(talent_learning_path:)
        ResultSuccess.new(
          talent_learning_path: talent_learning_path_presenter.present(
            talent_learning_path: talent_learning_path
          )
        )
      end

      def shift_to_next_course(talent_course:)
        # get all talent learning paths have this course
        talent_learning_paths = TalentLearningPath
                                .includes(learning_path: :courses)
                                .where(current_talent_course_id: talent_course.id)

        # then find the next available course
        talent_learning_paths.each do |talent_learning_path|
          learning_path_courses = talent_learning_path.learning_path.courses
          get_next_available_course = get_available_course(
            courses: learning_path_courses,
            talent_id: talent_course.talent_id,
            skip_until: talent_course.course_id
          )
          if get_next_available_course
            talent_learning_path.current_talent_course_id = get_next_available_course
            talent_learning_path.save
          end
        end
      end

      private

      def talent_learning_path_presenter
        @talent_learning_path_presenter ||= Api::V1::TalentLearningPathPresenter.new
      end

      def get_available_course(courses:, talent_id:, skip_until: nil)
        # TODO: Need to be optimized later
        available_talent_course = nil
        courses.each do |course|
          if skip_until
            skip_until = nil if course.id == skip_until
            next
          end
          talent_course = TalentCourse.find_by(course_id: course.id, talent_id: talent_id)
          talent_course = TalentCourse.create!(course_id: course.id, talent_id: talent_id) if talent_course.nil?

          if talent_course.status != 'Completed'
            available_talent_course = talent_course.id
            return available_talent_course
          end
          available_talent_course = talent_course.id
        end
        available_talent_course
      end
    end
  end
end
