class LinqDashboardController < ApplicationController
  before_action :require_user

  def home
    @greeting =  "Hello ethan, I'm home"
    # linqDashboard = LinqDashboard.first
    # print linqDashboard

    @content = ""
  end
end
