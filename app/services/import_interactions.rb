require "json"

# Loads the Recombee interaction dump into recommendation_interactions.
#
# ImportInteractions.new(path: "~/Documents/Coding/recommender/app/assets/json/interactions.jsonl").call
#
# The file is JSON Lines — one interaction per line — and is read a line at a
# time, so its size on disk does not matter.
class ImportInteractions
  # insert_all sends one bind parameter per column per row, and SQLite caps a
  # statement at 32,766 of them. Five columns leaves room for far more than
  # this, but larger batches stop paying for themselves.
  BATCH_SIZE = 2_000

  COLUMNS = %i[user_key item_id interaction_type anonymous occurred_at].freeze

  def all_interactions
    @data = RecommendationInteractions.all    
  end

  def initialize(path:, truncate: true, output: $stdout)
    @path = File.expand_path(path)
    @truncate = truncate
    @output = output
    @imported = 0
    @skipped = 0
  end
  
  def call
    raise ArgumentError, "no such file: #{path}" unless File.exist?(path)

    RecommendationInteractions.delete_all if truncate

    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    with_bulk_load_pragmas { import }
    report(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started)

    imported
  end

  attr_reader :imported, :skipped

  private

  attr_reader :path, :truncate, :output

  def import
    batch = []

    File.foreach(path) do |line|
      row = row_for(line)
      next @skipped += 1 if row.nil?

      batch << row
      next if batch.size < BATCH_SIZE

      insert(batch)
      batch = []
    end

    insert(batch) if batch.any?
  end

  def insert(batch)
    RecommendationInteractions.insert_all(batch)
    @imported += batch.size

    log("  #{imported} rows...") if (imported % 1_000_000).zero?
  end

  # A malformed line loses one interaction out of millions, which matters far
  # less than an import that dies two thirds of the way through.
  def row_for(line)
    parsed = JSON.parse(line)

    {
      user_key: parsed.fetch("user_key"),
      item_id: parsed.fetch("item_id"),
      interaction_type: parsed.fetch("type"),
      anonymous: parsed.fetch("anonymous"),
      occurred_at: parsed.fetch("timestamp").to_i
    }
  rescue JSON::ParserError, KeyError
    nil
  end

  # Durability guarantees are what make row-by-row inserts slow, and they buy
  # nothing here: if the import dies it gets run again from the top.
  def with_bulk_load_pragmas
    connection = RecommendationInteractions.connection
    # SQLite refuses to change durability mid-transaction, which is where this
    # runs under test. The speed only matters for the millions-of-rows case.
    return yield if connection.transaction_open?

    previous = connection.select_value("PRAGMA synchronous")
    connection.execute("PRAGMA synchronous = OFF")

    yield
  ensure
    connection.execute("PRAGMA synchronous = #{previous}") if previous
  end

  def report(elapsed)
    log(format("imported %d rows in %.1fs (%d rows/sec)", imported, elapsed, imported / elapsed))
    log("skipped #{skipped} unreadable lines") if skipped.positive?
  end

  def log(message)
    output.puts(message)
  end
end