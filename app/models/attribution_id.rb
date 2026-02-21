# frozen_string_literal: true

# == Schema Information
#
# Table name: attribution_ids
#
#  id           :bigint           not null, primary key
#  captured_at  :datetime         not null
#  fbclid       :string
#  gbraid       :string
#  gclid        :string
#  landing_page :string
#  referrer     :string
#  twclid       :string
#  utm_campaign :string
#  utm_content  :string
#  utm_medium   :string
#  utm_source   :string
#  utm_term     :string
#  wbraid       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_attribution_ids_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AttributionId < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
end
