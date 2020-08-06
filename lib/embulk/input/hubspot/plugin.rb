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
        # def self.guess(config)
        #   sample_records = [
        #     {"example"=>"a", "column"=>1, "value"=>0.1},
        #     {"example"=>"a", "column"=>2, "value"=>0.2},
        #   ]
        #   columns = Guess::SchemaGuess.from_hash_records(sample_records)
        #   return {"columns" => columns}
        # end

        def init
        end

        def run
          case task["object_type"]
          when "contact"
            Contact.get_data(page_builder,task)
          end
          page_builder.finish

          task_report = {}
          return task_report
        end
      end
    end
  end
end
