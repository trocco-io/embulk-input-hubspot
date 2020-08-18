require "hubspot-api-client"
module Embulk
  module Input
    module HubspotApi
      class MakeColumns
        class << self
          def get_column_list(api_key)
            Hubspot.configure do |config|
              config.api_key["hapikey"] = api_key
            end
            basic_api = Hubspot::Crm::Contacts::BasicApi.new
            contact_data = basic_api.get_page(auth_names: "hapikey").results[0]
            ::Embulk.logger.info "Get columns information"
            column_list = contact_data.to_hash.keys.push(contact_data.properties.keys).flatten
            column_list.delete(:properties)
            column_list.map(&:to_s)
          end
        end
      end
    end
  end
end
