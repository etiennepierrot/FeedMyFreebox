require 'test_helper'

class EpisodeControllerTest < ActionController::TestCase
  test "should get update" do
    get :update
    assert_response :success
  end

  test "should get pick_torrent" do
    get :pick_torrent
    assert_response :success
  end

  test "should get send" do
    get :send
    assert_response :success
  end

end
