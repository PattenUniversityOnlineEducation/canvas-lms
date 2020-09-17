class LinqDashboard < ApplicationRecord
  belongs_to :user
  belongs_to :learning_outcome
  before_save :infer_defaults
end
