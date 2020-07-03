require 'rest-client'
module Embulk
  module Input
    module Hubspot
      class Plugin < InputPlugin
        ::Embulk::Plugin.register_input("hubspot", self)

        def self.transaction(config, &control)
          # configuration code:
          task = {
            :api_key => config.param("api_key", :string),
            :columns => config.param("columns", :array),
            :report_type => config.param("report_type", :string),
          }

          columns = task[:columns].map do |column|
            ::Embulk::Column.new(nil, column["name"], column["type"].to_sym)
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
          case task["report_type"]
          when "get_all_contacts"
            GetAllContacts.get_data(page_builder,task)
          end
          page_builder.finish

          task_report = {}
          return task_report
        end
      end
    end
  end
end
