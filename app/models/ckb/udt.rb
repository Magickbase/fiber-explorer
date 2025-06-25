module Ckb
  class Udt < ApplicationRecord
  end
end

# == Schema Information
#
# Table name: ckb_udts
#
#  id         :bigint           not null, primary key
#  decimal    :integer
#  full_name  :string
#  icon       :text
#  symbol     :string
#  type_hash  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_ckb_udts_on_type_hash  (type_hash) UNIQUE
#
