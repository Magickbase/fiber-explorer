class GraphTopologySerializer
  include JSONAPI::Serializer

  attributes :node_id, :addresses, :connected_node_ids
end
