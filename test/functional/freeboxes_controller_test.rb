require 'test_helper'

class FreeboxesControllerTest < ActionController::TestCase
  test "should get attach" do
    get :attach
    assert_response :success
  end

  test "should get confirm" do
    get :confirm
    assert_response :success
  end

end
