require "hubspot-api-client"
require "date"
module Embulk
  module Input
    module HubspotApi
      class Deal
        class << self
          Hubspot::Crm::Deals::ApiClient::VERSION = '7.0.0'
          def get_column_list(api_key)
            Hubspot.configure do |config|
              config.api_key["hapikey"] = api_key
            end
            basic_api = Hubspot::Crm::Deals::BasicApi.new
            deal_data = basic_api.get_page(auth_names: "hapikey").results[0]
            ::Embulk.logger.info "Get columns information"
            column_list = deal_data.to_hash.keys.push(deal_data.properties.keys).flatten
            column_list.delete(:properties)
            column_list.map(&:to_s)
          end

          def get_data(page_builder,task)
            Hubspot.configure do |config|
              config.api_key["hapikey"] = task["api_key"]
            end
            basic_api = Hubspot::Crm::Deals::BasicApi.new
            all_deals = basic_api.get_all(auth_names: "hapikey")
            ::Embulk.logger.info "Get deals data"
            column_check(task["columns"], all_deals.first)
            all_deals.each do |deal|
              row = { "id" => deal.id, "createdAt" => deal.created_at.to_time, "updatedAt" => deal.updated_at.to_time, "archived" => deal.archived }.merge(deal.properties)
              page_builder.add(task["columns"].map do|column|
                if column["type"] == "timestamp"
                  if row[column["name"]].kind_of?(Time)
                    row[column["name"]]
                  else
                    Time.strptime(row[column["name"]],column["format"])
                  end
                elsif column["type"] == "long"
                  row[column["name"]].to_i
                elsif column["type"] == "double"
                  row[column["name"]].to_f
                else
                  row[column["name"]]
                end
              end)
            end
          end

          def guess_deal(api_key)
            Hubspot.configure do |config|
              config.api_key["hapikey"] = api_key
            end
            basic_api = Hubspot::Crm::Deals::BasicApi.new
            deal_data = basic_api.get_page(auth_names: "hapikey").results
            deal_data.map do |deal|
              { "id" => deal.id, "createdAt" => deal.created_at.to_time, "updatedAt" => deal.updated_at.to_time, "archived" => deal.archived }.merge(deal.properties)
            end
          end

          private

          def column_check(columns, deal)
            column_list = deal.to_hash.keys.push(deal.properties.keys).flatten
            column_list.delete(:properties)
            column_list.map!(&:to_s)
            columns.each do |column|
              raise ::Embulk::Input::HubspotApi::Error::InvalidColumnError, "#{column["name"]} is Invalid Column" unless column_list.include?(column["name"])
            end
          end
        end
      end
    end
  end
end
