class ProjectsController < ApplicationController
  def show
    # file = File.open('example.xml')
    xml_string = Project.first.xml_schema
    doc = Nokogiri::XML(xml_string)

    @tables_arr = []
    doc.root.search('table').each do |table|
      # find primary key
      primary_row_name = table.search('key/part').text
      columns_arr = []

      table.search('row').each do |row|
        column_name = row.attribute('name').value
        # add Sapir's method below
        data_type = row.search('datatype').text
        relations = row.search('relation')
        relations_arr = []
        fk = relations.count > 0
        pk = column_name == primary_row_name

        relations.each do |relation|
          relation_table = relation.attribute('table').value
          relation_row = relation.attribute('row').value
          relation_hash = {
            relation_table: relation_table,
            relation_row: relation_row
          }
          relations_arr << relation_hash
        end

        columns_arr << {
          column_name: column_name,
          data_type: to_data_type(data_type),
          relations: relations_arr,
          pk: pk,
          fk: fk
        }
      end

      @tables_arr << {
        table_name: table.attribute("name").value,
        columns: columns_arr
      }
    end
      @commands = commands
  end

  private
    def commands
      @commands = []
      @tables_arr.each do |table|
        command = "rails g model #{table[:table_name].downcase[0..-2]} "
          table[:columns].each do |column|
          next if column[:column_name] == "id"

            column_name = column[:column_name]
            data_type = column[:data_type]

              command += " #{column_name}:#{data_type}"

            if column[:fk] == true
              column[:relations].each do |e|
              relation_table_name = e[:relation_table].downcase[0..-2]

              command += " #{relation_table_name}:refrences"
            end
          end
        end
      @commands << command
      end

      @commands
    end

    def to_data_type(schema_data_type)
      case schema_data_type.downcase
      when "integer", "tinyint", "smallint", "mediumint", "int", "bigint", "single precision", "double precision"
        :integer
      when "decimal"
        :decimal
      when "char", "varchar", "varbinary"
        :string
      when "text"
        :text
      when "binary", "bit"
        :binary
      when "boolean"
        :boolean
      when "date", "year"
        :date
      when "time"
        :time
      when "timestamp", "timestamp w/ tz", "timestamp wo/ tz"
        :timestamp
      when "datetime"
        :datetime
      end
    end
end
