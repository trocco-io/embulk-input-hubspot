module Embulk
  module Input
    module Hubspot
      class GetAllContacts
        class << self
          def get_data(page_builder,task)
            column_check(task["columns"])
            has_more = true
            vid_offset = nil
            url = 'https://api.hubapi.com/contacts/v1/lists/all/contacts/all'
            while has_more do
              params = { params: { hapikey: task["api_key"], vidOffset: vid_offset } }
              ::Embulk.logger.info "Access URL: #{url}"
              response = RestClient.get(url, params)
              res = JSON.parse(response.body)
              has_more = res["has-more"]
              vid_offset = res["vid-offset"]
              res["contacts"].each do |row|
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
          end

          private

          def column_check(columns)
            columns.each do |column|
              raise ::Embulk::Input::Hubspot::Error::InvalidColumnError, "#{column["name"]} is Invalid Column" until column_list.include?(column["name"])
            end
          end

          def column_list
            [
              "addedAt", "vid","canonical-vid","merged-vids","portal-id","is-contact","profile-token","profile-url","properties","form-submissions","list-memberships","identity-profiles","merge-audits"
            ]
          end
        end
      end
    end
  end
end
