module Embulk
  module Input
    module HubspotApi
      class Plugin < InputPlugin
        ::Embulk::Plugin.register_input("hubspot", self)
        def self.transaction(config, &control)
          # configuration code:
          task = {
            :api_key => config.param("api_key", :string),
            :columns => config.param("columns", :array, default: []),
            :object_type => config.param("object_type", :string),
          }

          if task[:columns].empty?
            task[:columns] = MakeColumns.get_column_list(task[:api_key]).map { |name| {"name" => name} }
          end
          columns = task[:columns].map do |column|
            type = column["type"].nil? ? "string" : column["type"]
            ::Embulk::Column.new(nil, column["name"], type.to_sym)
          end

          resume(task, columns, 1, &control)
        end

        def self.resume(task, columns, count, &control)
          task_reports = yield(task, columns, count)

          next_config_diff = {}
          return next_config_diff
        end

        # TODO
        def self.guess(guess_config)
          unless guess_config["columns"].nil?
            Embulk.logger.warn "Don't needed to guess"
            return {}
          end
          sample_records = []
          Hubspot.configure do |config|
            config.api_key["hapikey"] = guess_config["api_key"]
          end
          basic_api = Hubspot::Crm::Contacts::BasicApi.new
          contact_data = basic_api.get_page(auth_names: "hapikey").results
          contact_data.each do |contact|
            sample_records.push({ "id" => contact.id, "createdAt" => contact.created_at.to_time, "updatedAt" => contact.updated_at.to_time, "archived" => contact.archived }.merge(contact.properties))
          end
          columns = Guess::SchemaGuess.from_hash_records(sample_records)
          return {"columns" => columns}
        end

        def init
        end

        def run
          case task["object_type"]
          when "contact"
            Contact.get_data(page_builder,task)
          else
            raise ::Embulk::Input::HubspotApi::Error::InvalidObjectTypeError, "#{task["object_type"]} is Invalid Object Type"
          end
          page_builder.finish

          task_report = {}
          return task_report
        end
      end
    end
  end
end
