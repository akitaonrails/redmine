require 'forwardable'
module Resources::SharedTestModule
  extend Forwardable
  def_delegators :@controller, :model_class, :object_node_hash_key
  
  def test_create_action_authorized_with_valid_attributes_should_create_a_project
    with_admin_authentication_credentials do
      with_xml_request do
        assert_difference "#{model_class}.count" do
          post 'create', valid_attributes
        end
      end
    end
  end

  def test_create_action_authorized_with_valid_attributes_should_return_created_status
    with_admin_authentication_credentials do
      with_xml_request do
        post 'create', valid_attributes
        assert_response :created
      end
    end
  end

  def test_create_action_authorized_with_valid_attributes_should_return_location_of_project
    with_admin_authentication_credentials do
      with_xml_request do
        post 'create', valid_attributes
        assert_match( /\/#{assigns(:object)[:id]}$/, @response.headers['Location'])
      end
    end
  end

  def test_create_action_authorized_with_invalid_attributes_should_not_create_a_project
    with_admin_authentication_credentials do
      with_xml_request do
        assert_no_difference "#{model_class}.count" do
          post 'create', invalid_attributes
        end
      end
    end
  end

  def test_create_action_authorized_with_invalid_attributes_should_have_a_response_body_indicating_the_errors
    with_admin_authentication_credentials do
      with_xml_request do
        post 'create', invalid_attributes
        assert_select 'errors error', :minimum => 1
      end
    end
  end

  def test_create_action_authorized_with_invalid_attributes_should_have_a_response_status
    with_admin_authentication_credentials do
      with_xml_request do
        post 'create', invalid_attributes
        assert_response :unprocessable_entity
      end
    end
  end

  def test_create_action_with_invalid_authentication_does_not_create_a_project
    with_invalid_authentication_credentials do
      with_xml_request do
        assert_no_difference "#{model_class}.count" do
          post 'create', valid_attributes
        end
      end
    end
  end

  def test_create_action_with_invalid_authentication_returns_a_401_response
    with_invalid_authentication_credentials do
      with_xml_request do
        post 'create', valid_attributes
        assert_response 401
      end
    end
  end

  def test_create_action_with_no_authorization_returns_a_403_response
    with_non_admin_authentication_credentials do
      with_xml_request do
        post 'create', valid_attributes
        assert_response 403
      end
    end
  end

  def test_create_action_not_authenticated
    with_xml_request do
      post 'create', valid_attributes
      assert_response 401
    end
  end

  protected
  
  
  def with_non_admin_authentication_credentials
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('jsmith', 'jsmith')
    yield if block_given?
  end
  def with_admin_authentication_credentials
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'admin')
    yield if block_given?
  end

  def with_invalid_authentication_credentials
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('alberto', 'gonzalez')
    yield if block_given?
  end

  def with_xml_request
    @request.env["HTTP_ACCEPT"] = "application/xml"
    yield if block_given?
  end

  
end