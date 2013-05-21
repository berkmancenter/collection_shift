require 'test_helper'

class ResultsControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get person_hours" do
    get :person_hours
    assert_response :success
  end

  test "should get linear_feet" do
    get :linear_feet
    assert_response :success
  end

end
