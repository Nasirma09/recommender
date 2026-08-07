class RecommenderQueryController < ApplicationController
  def index
  end

  # binding.pry
  def find_product_recommendations
    queries = params[:queries]
    @result = result(queries)
    @original_product_information = original_product_info(queries)
    @product_details = product_details(@result)
    render :index, status: :ok
    # binding.pry
  end

  def clear_search
    puts "reached"
  end

  private

  def result(queries)
    ItemSimilarities.where(item_id: queries["product_id"]).order(score: :desc).limit(8)
  end

  def original_product_info(queries)
    response = HTTParty.get(
        "https://app-api-v1.preview.papier-staging.com/api/v1/listings/#{queries["product_id"]}",
        headers: {
          'X-Store-Code' => 'gb',
          'Accept' => 'application/json'
        }
      ).parsed_response
  end
  
  def product_details(result)
    result.map do |product|
      response = HTTParty.get(
        "https://app-api-v1.preview.papier-staging.com/api/v1/listings/#{product.neighbour_item_id}",
        headers: {
          'X-Store-Code' => 'gb',
          'Accept' => 'application/json'
        }
      ).parsed_response
    end
  end
end

# https://app-api-v1.preview.papier-staging.com/api/v1/listings/PRODUCT-50742
