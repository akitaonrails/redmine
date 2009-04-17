require 'forwardable'
module Resources::SharedTestModule
  extend Forwardable
  def_delegators :@controller, :model_class, :object_node_hash_key

  [[:post, :create, :created, true], [:put, :update, :no_content, false]].each do |method, action_name, status, count_difference|
    define_method "test_#{action_name}_method_authorized_with_valid_attributes_should_#{action_name}_a_project" do
      with_admin_authentication_credentials do
        with_xml_request do
          send("with_#{action_name}_request_params") do |valid_attributes, invalid_attributes|
            send("assert_#{count_difference ? '': 'no_'}difference", "#{model_class}.count") do
              send(method, action_name, valid_attributes)
            end
          end
        end
      end
    end
    define_method "test_#{action_name}_method_authorized_with_valid_attributes_should_return_#{status}_status" do
      with_admin_authentication_credentials do
        with_xml_request do
          send("with_#{action_name}_request_params") do |valid_attributes, invalid_attributes|
            send(method, action_name, valid_attributes)
            assert_response status
          end
        end
      end
    end
    define_method "test_#{action_name}_method_authorized_with_valid_attributes_should_return_location_of_object" do
      with_admin_authentication_credentials do
        with_xml_request do
          send("with_#{action_name}_request_params") do |valid_attributes, invalid_attributes|
            send(method, action_name, valid_attributes)
            assert_match( /\/#{assigns(:object)[:id]}$/, @response.headers['Location'])
          end
        end
      end
    end
    define_method "test_#{action_name}_action_authorized_with_invalid_attributes_should_not_#{action_name}_a_object" do
      with_admin_authentication_credentials do
        with_xml_request do
          assert_no_difference "#{model_class}.count" do
            send("with_#{action_name}_request_params") do |valid_attributes, invalid_attributes|
              send(method, action_name, invalid_attributes)
            end
          end
        end
      end
    end

    define_method "test_#{action_name}_action_authorized_with_invalid_attributes_should_have_a_response_body_indicating_the_errors" do
      with_admin_authentication_credentials do
        with_xml_request do
          send("with_#{action_name}_request_params") do |valid_attributes, invalid_attributes|
            send(method, action_name, invalid_attributes)
            assert_select 'errors error', :minimum => 1
          end
        end
      end
    end

    define_method "test_#{action_name}_action_authorized_with_invalid_attributes_should_have_an_unprocessable_entity_response_status" do
      with_admin_authentication_credentials do
        with_xml_request do
          send("with_#{action_name}_request_params") do |valid_attributes, invalid_attributes|
            send(method, action_name, invalid_attributes)
            assert_response :unprocessable_entity
          end
        end
      end
    end

    define_method "test_#{action_name}_action_with_invalid_authentication_does_not_create_a_object" do
      with_invalid_authentication_credentials do
        with_xml_request do
          assert_no_difference "#{model_class}.count" do
            send("with_#{action_name}_request_params") do |valid_attributes, invalid_attributes|
              send(method, action_name, valid_attributes)
            end
          end
        end
      end
    end

    define_method "test_#{action_name}_with_invalid_authentication_returns_a_401_response" do
      with_invalid_authentication_credentials do
        with_xml_request do
          send("with_#{action_name}_request_params") do |valid_attributes, invalid_attributes|
            send(method, action_name, valid_attributes)
            assert_response 401
          end
        end
      end
    end

    define_method "test_#{action_name}_action_with_no_authorization_returns_a_403_response" do
      with_non_admin_authentication_credentials do
        with_xml_request do
          send("with_#{action_name}_request_params") do |valid_attributes, invalid_attributes|
            send(method, action_name, valid_attributes)
            assert_response 403
          end
        end
      end
    end

    define_method "test_#{action_name}_action_not_authenticated" do
      with_xml_request do
        send("with_#{action_name}_request_params") do |valid_attributes, invalid_attributes|
          send(method, action_name, valid_attributes)
          assert_response 401
        end
      end
    end
  end



  protected

  def with_update_request_params
    yield(valid_attributes.merge(:id => object[:id]), invalid_attributes.merge(:id => object[:id]))
  end

  def with_create_request_params
    yield(valid_attributes, invalid_attributes)
  end


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

end
