class Api::RecommendationsController < ApplicationController
  def index
    scores = ItemSimilarities.where(item_id: params["product_id"]).order(score: :desc).limit(8)
    # binding.pry
    render json: {
      recommendations: scores
    }
  end
end
