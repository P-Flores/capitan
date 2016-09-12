# == Schema Information
#
# Table name: sprints
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  group_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Sprint < ActiveRecord::Base
  has_and_belongs_to_many :lessons
  has_many :badges, through: :sprint_badges
  has_many :sprint_badges
  belongs_to :group
  has_many :pages, through: :lessons
  has_many :submissions, through: :pages
  has_many :soft_skill_submissions
  validates :group_id, presence: true

  def total_points
    pages.with_points.group(:page_type).pluck(:page_type, 'sum(pages.points)')
  end

  def student_points user
    pages.with_points.includes(:submissions).
          where('submissions.user_id = ?', user.id).
          references(:submissions).group(:page_type).
          pluck(:page_type, 'sum(submissions.points)')
  end

  def avg_classroom_points
    pages.with_points.joins(:submissions).
      includes(:submissions).
      group(:user_id).
      pluck('sum(submissions.points)').
      reduce [ 0.0, 0 ] do |(s, c), e| [ s + e, c + 1 ] end.reduce :/      
  end
end