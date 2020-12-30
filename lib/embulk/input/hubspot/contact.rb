require "hubspot-api-client"
require "date"
module Embulk
  module Input
    module HubspotApi
      class Contact
        class << self
          Hubspot::Crm::Contacts::ApiClient::VERSION = '7.0.0'
          Hubspot::Crm::Properties::ApiClient::VERSION = '7.0.0'
          def get_column_list(api_key)
            Hubspot.configure do |config|
              config.api_key["hapikey"] = api_key
            end
            ::Embulk.logger.info "Get columns information"
            ["id", "createdAt", "updatedAt", "archived"] + get_all_contact_property
          end

          def get_data(page_builder,task)
            Hubspot.configure do |config|
              config.api_key["hapikey"] = task["api_key"]
            end
            basic_api = Hubspot::Crm::Contacts::BasicApi.new
            all_contacts = basic_api.get_all(properties: get_all_contact_property, auth_names: "hapikey")
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

          def guess_contact(api_key)
            Hubspot.configure do |config|
              config.api_key["hapikey"] = api_key
            end
            basic_api = Hubspot::Crm::Contacts::BasicApi.new
            contact_data = basic_api.get_page(properties: get_all_contact_property, auth_names: "hapikey").results
            contact_data.map do |contact|
              { "id" => contact.id, "createdAt" => contact.created_at.to_time, "updatedAt" => contact.updated_at.to_time, "archived" => contact.archived }.merge(contact.properties)
            end
          end

          private
          def get_all_contact_property
            property_api = Hubspot::Crm::Properties::CoreApi.new
            all_contacts_property = property_api.get_all("contact", auth_names: "hapikey")
            all_contacts_property.results.map { |property| property.name}
          end

          def column_check(columns, contact)
            column_list = contact.to_hash.keys.push(contact.properties.keys).flatten
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
