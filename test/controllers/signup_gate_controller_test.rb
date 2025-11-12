require "test_helper"

class SignupGateControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_gate_new_url
    assert_response :success
  end

  test "should get create" do
    get signup_gate_create_url
    assert_response :success
  end
end
