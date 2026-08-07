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
    return @items_by_user if @items_by_user
    collected = Hash.new{|hash, user_key| hash[user_key] = []}
    puts "Total interactions: #{all_interactions.count}"

    all_interactions.in_batches(of: 50_000) do |batch|
      batch.pluck(:user_key, :item_id).each do |user_key, item_id|
        collected[user_key] << item_id
      end
    end

    collected.each_value(&:uniq!)
    puts "items_by_user completed"
    return  @items_by_user = collected
  end

  def count_users_per_item
    return @count_users_per_item if @count_users_per_item
    users_per_item = Hash.new(0)
    items_by_user.each do |user_key, items|
      items.each do |item|
        users_per_item[item] += 1
      end
    end
    puts "count_users_per_item completed"
    return @count_users_per_item = users_per_item
  end

  def count_shared_users
    return @count_shared_users if @count_shared_users
    shared_users = Hash.new(0)
    items_by_user.each do |user_key, items|
      items.sort.combination(2) do |pair|
        shared_users[pair] += 1
      end
    end
    puts "count_shared_users completed"
    return @count_shared_users = shared_users
  end

  def product_pairs
    count_users_per_item.keys.permutation(2).to_a
  end

  def score_pairs
    scored = []
    product_pairs.each do |(item_a, item_b)|
      # shared_users / (|users(A)| + |users(B)| - shared_users)
      shared_users = count_shared_users[[item_a, item_b].sort]
      # next if shared_users.zero?
      puts shared_users
      num_a = count_users_per_item[item_a]
      num_b = count_users_per_item[item_b]
      score = shared_users.to_f / (num_a + num_b - shared_users).to_f
      scored << { item_id: item_a, neighbour_item_id: item_b, score: score, shared_user_count: shared_users}
    end
    puts scored.count
    scored.each_slice(2000) do |slice|
      ItemSimilarities.insert_all(slice)
    end
  end
end