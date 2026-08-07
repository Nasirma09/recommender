require "test_helper"

class RecommenderQueryControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get recommender_query_index_url
    assert_response :success
  end
end
