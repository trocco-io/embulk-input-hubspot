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
            case task[:object_type]
            when "contact"
              task[:columns] = Contact.get_column_list(task[:api_key]).map { |name| {"name" => name} }
            when "deal"
              task[:columns] = Deal.get_column_list(task[:api_key]).map { |name| {"name" => name} }
            else
              raise ::Embulk::Input::HubspotApi::Error::InvalidObjectTypeError, "#{task[:object_type]} is Invalid Object Type"
            end
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
          case guess_config["object_type"]
          when "contact"
            sample_records = Contact.guess_contact(guess_config["api_key"])
          when "deal"
            sample_records = Deal.guess_deal(guess_config["api_key"])
          else
            raise ::Embulk::Input::HubspotApi::Error::InvalidObjectTypeError, "#{guess_config["object_type"]} is Invalid Object Type"
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
          when "deal"
            Deal.get_data(page_builder,task)
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
