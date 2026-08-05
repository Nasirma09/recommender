class RecommenderQueryController < ApplicationController
  def index
  end

  def find_product_recommendations
    binding.pry
    query = params[:query]
    render plain: "Success", status: :ok
  end
end
