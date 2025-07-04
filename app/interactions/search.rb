class Search < ActiveInteraction::Base
  include Pagy::Backend

  DEFAULT_HASH_PREFIX = "0x".freeze

  string :key

  def execute
    stripped_key = key.start_with?(DEFAULT_HASH_PREFIX) ? key.delete_prefix(DEFAULT_HASH_PREFIX) : key
    normalized_key = key.downcase
    scope = GraphNode.
      where("LOWER(node_id) = ?", stripped_key.downcase).
      or(GraphNode.where("EXISTS (SELECT 1 FROM unnest(addresses) AS addr WHERE LOWER(addr) = ?)", normalized_key)).
      or(GraphNode.where("LOWER(node_name) LIKE ?", "%#{normalized_key}%"))

    GraphNodeSerializer.new(scope, params: { minimal: false }).serializable_hash
  end
end
