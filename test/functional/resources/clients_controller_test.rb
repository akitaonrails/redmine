require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/shared_test_module'
require 'resources/clients_controller'

# Re-raise errors caught by the controller.
class Resources::ClientsController; def rescue_action(e) raise e end; end

class Resources::ClientsControllerTest < Test::Unit::TestCase
  fixtures :users, :projects
  def setup
    @controller = Resources::ClientsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # All of the tests reside here.
  include Resources::SharedTestModule

  protected

  def valid_attributes(options = {})
    {object_node_hash_key => {:name => 'Client Name', :description => 'Client Description', :identifier => 'myclient'}.merge(options)}
  end

  def invalid_attributes
    valid_attributes(:identifier => '', :name => '')
  end
  
  def object
    @object ||= projects(:projects_001)
  end
end
