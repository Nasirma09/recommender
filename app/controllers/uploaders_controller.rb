require 'open-uri'

class UploadersController < ApplicationController
  def index
    # @data = RecommendationInteractions.all    
  end
  
  def create 
    RecommendationInteractions.delete_all
    file = params[:file]
    output = File.foreach(file).filter_map do |line|
      next if line.strip.empty?
      record = JSON.parse(line)
      puts RecommendationInteractions.create(anonymous: record["anonymous"], interaction_type: record["type"], item_id: record["item_id"], occurred_at: record["timestamp"], user_key: record["user_key"])
      record
    end
    # binding.pry
  end
end

# RecommendationInteractions.create(anonymous: true, interaction_type: "view", item_id: "PRODUCT-50742", occurred_at
# : 1770200277.399436, user_key: "placeholder")

# to read file: params[:file].read

# to debug: binding.pry