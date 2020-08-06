require "hubspot-api-client"
module Embulk
  module Input
    module HubspotApi
      class GetAllContacts
        class << self
          def get_data(page_builder,task)
            column_check(task["columns"])
            Hubspot.configure do |config|
              config.api_key["hapikey"] = task["api_key"]
            end
            basic_api = Hubspot::Crm::Contacts::BasicApi.new
            all_contacts = basic_api.get_all(auth_names: "hapikey")
            ::Embulk.logger.info "Get contacts data"
            all_contacts.each do |contact|
              row = { "id" => contact.id, "createdAt" => contact.created_at, "updatedAt" => contact.updated_at, "archived" => contact.archived }.merge(contact.properties)
              page_builder.add(task["columns"].map do|column|
                if column["type"] == "timestamp"
                  Time.strptime(row[column["name"]],column["format"])
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

          def column_check(columns)
            columns.each do |column|
              raise ::Embulk::Input::HubspotApi::Error::InvalidColumnError, "#{column["name"]} is Invalid Column" until column_list.include?(column["name"])
            end
          end

          def column_list
            [
              "id", "createdAt","updatedAt","archived","createdate","email","firstname","hs_object_id","lastmodifieddate","lastname"
            ]
          end
        end
      end
    end
  end
end
