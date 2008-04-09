require File.dirname(__FILE__) + '/../test_helper'
require 'timers_controller'

# Re-raise errors caught by the controller.
class TimersController; def rescue_action(e) raise e end; end

class TimersControllerTest < Test::Unit::TestCase
  class ValidTimer < Timer
    def with_authorization_scope(*args)
      yield if block_given?
    end
    def save
      true
    end
  end
  class InvalidTimer < Timer
    def with_authorization_scope(*args)
      yield if block_given?
    end
    def save
      false
    end
  end
  class UnauthorizedTimer < Timer
    def with_authorization_scope(*args)
      yield if block_given?
    end
    def save
      response = ActionController::TestResponse.new
      def response.code; 422;end
      raise ActiveResource::ConnectionError.new(response)
    end
  end
  fixtures :issues, :trackers, :users
  def setup
    @issue = issues(:issues_001)
    @controller = TimersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_create_without_login_redirects_to_signin_path
    with_valid_timer do
      @request.session[:user_id] = nil
      post :create, :id => @issue[:id]
      assert_redirected_to signin_path
    end
  end

  def test_create_with_login_assigns_issue_timer_started
    with_authorize_override do
      with_valid_timer do
        @request.session[:user_id] = users(:users_003).id
        xhr :post, :create, :id => @issue[:id]
        assert_response :created
      end
    end
  end

  def test_create_with_login_assigns_issue
    with_authorize_override do
      with_invalid_timer do
        @request.session[:user_id] = users(:users_003).id
        xhr :post, :create, :id => @issue[:id]
        assert_response :unprocessable_entity
      end
    end
  end

  def test_create_when_remote_resource_is_not_functioning
    def @controller.timer_class
      UnauthorizedTimer
    end
    
    with_authorize_override do
      @request.session[:user_id] = users(:users_003).id
      xhr :post, :create, :id => @issue[:id]
      assert_response :unprocessable_entity
    end

  end

  def with_invalid_timer
    def @controller.timer_class
      InvalidTimer
    end
    yield if block_given?
  end

  def with_valid_timer
    def @controller.timer_class
      ValidTimer
    end
    yield if block_given?
  end
  def with_authorize_override
    def @controller.authorize; true; end
    yield if block_given?
  end
end
