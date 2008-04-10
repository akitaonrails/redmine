require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/shared_test_module'
require 'resources/exhibits_controller'

# Re-raise errors caught by the controller.
class Resources::ExhibitsController; def rescue_action(e) raise e end; end

class Resources::ExhibitsControllerTest < Test::Unit::TestCase
  fixtures :users, :projects
  def setup
    @controller = Resources::ExhibitsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @parent_project = projects(:projects_001)
  end

  # All of the tests reside here.
  include Resources::SharedTestModule

  def test_create_action_authorized_with_parent_id_should_create_a_child_project
    with_admin_authentication_credentials do
      with_xml_request do
        assert_difference "@parent_project.children.count" do
          post 'create', valid_attributes
        end
      end
    end
  end

  def test_create_action_authorized_without_parent_id_should_not_create_a_project
    with_admin_authentication_credentials do
      with_xml_request do
        assert_no_difference "#{@controller.send(:model_class)}.count" do
          post 'create', valid_attributes(:parent_id => nil)
        end
      end
    end
  end

  def test_create_action_authorized_without_parent_id_should_have_an_errors_error_xml_node
    with_admin_authentication_credentials do
      with_xml_request do
        post 'create', valid_attributes(:parent_id => nil)
        assert_select 'errors error', /parent_id/
      end
    end
  end

  protected
  def valid_attributes(options = {})
    {object_node_hash_key => {:parent_id => @parent_project[:id], :name => 'Client Name', :description => 'Client Description', :identifier => 'myclient'}.merge(options)}
  end

  def invalid_attributes
    valid_attributes(:identifier => '', :name => '')
  end
  
  def object
    @object ||= projects(:projects_003)
  end
  
end
