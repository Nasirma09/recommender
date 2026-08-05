class BuildItemSimilarities 
  def call
    ItemSimilarities.delete_all
    score_pairs
  end

  private

  def all_interactions
    RecommendationInteractions.all
  end

  def items_by_user
    collected = Hash.new{|hash, user_key| hash[user_key] = []}
    puts "Total interactions: #{all_interactions.count}"

    all_interactions.each_with_index do |act, index|
      user_key = act.user_key
      item_id = act.item_id
      collected[user_key] << item_id
    end
    collected.each_value(&:uniq!)
    return collected
  end

  def count_users_per_item
    users_per_item = Hash.new(0)
    items_by_user.each do |user_key, items|
      items.each do |item|
        users_per_item[item] += 1
      end
    end
    return users_per_item
  end

  def count_shared_users
    shared_users = Hash.new(0)
    items_by_user.each do |user_key, items|
      items.sort.combination(2) do |pair|
        shared_users[pair] += 1
      end
    end
    return shared_users
  end

  def product_pairs
    count_users_per_item.keys.permutation(2).to_a
  end

  def score_pairs
    product_pairs.each do |(item_a, item_b)|
      # shared_users / (|users(A)| + |users(B)| - shared_users)
      shared_users = count_shared_users[[item_a, item_b]]
      puts shared_users
      num_a = count_users_per_item[item_a]
      num_b = count_users_per_item[item_b]
      score = shared_users / (num_a + num_b - shared_users)
      puts score
    end
  end
end