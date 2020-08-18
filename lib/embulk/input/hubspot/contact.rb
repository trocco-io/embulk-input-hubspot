require "hubspot-api-client"
require "date"
module Embulk
  module Input
    module HubspotApi
      class Contact
        class << self
          Hubspot::Crm::Contacts::ApiClient::VERSION = '7.0.0'
          def get_data(page_builder,task)
            Hubspot.configure do |config|
              config.api_key["hapikey"] = task["api_key"]
            end
            basic_api = Hubspot::Crm::Contacts::BasicApi.new
            all_contacts = basic_api.get_all(auth_names: "hapikey")
            ::Embulk.logger.info "Get contacts data"
            column_check(task["columns"], all_contacts.first)
            all_contacts.each do |contact|
              row = { "id" => contact.id, "createdAt" => contact.created_at.to_time, "updatedAt" => contact.updated_at.to_time, "archived" => contact.archived }.merge(contact.properties)
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

          private

          def column_check(columns, contact)
            column_list = contact.to_hash.keys.push(contact.properties.keys).flatten
            column_list.delete(:properties)
            column_list.map!(&:to_s)
            columns.each do |column|
              raise ::Embulk::Input::HubspotApi::Error::InvalidColumnError, "#{column["name"]} is Invalid Column" until column_list.include?(column["name"])
            end
          end
        end
      end
    end
  end
end
