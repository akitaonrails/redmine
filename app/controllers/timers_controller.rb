class TimersController < ApplicationController
  before_filter :find_project, :authorize
  def create
    respond_to do |format|
      begin
        timer_class.with_authorization_scope(User.current) do
          if timer.save
            format.js  { render :text => "Timer Started", :status => :created }
          else
            format.js  { render :json => timer.errors, :status => :unprocessable_entity }
          end
        end
      rescue ActiveResource::ConnectionError => e
        format.js { render :text => e, :status => e.response.code}
      end
    end
  end

  protected
  def find_project
    @issue = Issue.find(params[:id])
    @project = @issue.project
  end

  def timer
    @timer ||= timer_class.new(:task_code => @issue.task_code, :redmine_exhibit_id => @issue.project_id)
  end
  def timer_class
    Timer
  end
end
