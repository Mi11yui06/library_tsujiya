require "test_helper"

class CountersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get counters_new_url
    assert_response :success
  end
end
