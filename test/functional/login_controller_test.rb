require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  test "should get return" do
    get :return
    assert_response :success
  end

end
