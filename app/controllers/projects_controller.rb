class ProjectsController < ApplicationController
  before_action :set_project, only: [:show]
  before_action :check_if_user_is_owner?,  only: [:show]

  def index
    @projects = Project.where(user_id: current_user.id)
  end

  def new
    @project = Project.new
    @project.user = current_user
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    if @project.save
      redirect_to project_path(@project)
    else
      render :new
    end
  end

  def show
    @project.user = current_user
    xml_string = @project.xml_schema
    parse_xml(xml_string)
  end

  private

  def parse_xml(xml_string)
    doc = Nokogiri::XML(xml_string)

    tables_arr = []
    @show_tables_arr = []
    doc.root.search('table').each do |table|
      # find primary key
      primary_row_name = table.search('key/part').text
      columns_arr = []

      table.search('row').each do |row|
        column_name = row.attribute('name').value
        data_type = row.search('datatype').text
        relations = row.search('relation')
        relations_arr = []
        sorting_relations_arr = []
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
          sorting_relations_arr << relation_hash
        end

        columns_arr << {
          column_name: column_name,
          data_type: to_data_type(data_type),
          relations: relations_arr,
          pk: pk,
          fk: fk,
          # for sorting
          sorting_relations: sorting_relations_arr
        }
      end

      tables_arr << {
        table_name: table.attribute("name").value,
        columns: columns_arr
      }
    end

    @tables_arr = order(tables_arr) # Josh, temporary, to get to function from views
    @commands = commands
  end

  def commands
    @commands = []

    @tables_arr.each do |table|
      table_name = table[:table_name].gsub(/\s+/m, '_').downcase

      if table_name.length <= 1
        command = "rails g model #{table_name} "
      elsif table_name.chars.last(3).join == "ies"
        command = "rails g model #{table_name[0..-4]}y "
      elsif table_name.chars.last == "s"
        command = "rails g model #{table_name[0..-2]} "
      else
        command = "rails g model #{table_name} "
      end

      table[:columns].each do |column|
        next if column[:column_name] == "id"

        column_name = column[:column_name]
        data_type = column[:data_type]

        command += " #{column_name}:#{data_type}"

        if column[:fk] == true
          column[:relations].each do |relation|
            relation_table_name = relation[:relation_table].gsub(/\s+/m, '_').downcase

            if relation_table_name.length <= 1
              command += " #{relation_table_name}:references"
            elsif relation_table_name.chars.last(3).join == "ies"
              command += " #{relation_table_name[0..-4]}y:references"
            elsif relation_table_name.chars.last == "s"
              command += " #{relation_table_name[0..-2]}:references"
            else
              command += " #{relation_table_name}:references"
            end
          end
        end
      end

      splitted_commands = command.split(" ").map do |cmd|
        cmd.include?("id") ? cmd = " " : cmd + " "
      end
      @commands << splitted_commands.join("")


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

  def order(tables_arr)
    sorting_tables_arr = tables_arr
    ordered_tables_arr = []

    return_and_remove_fks(sorting_tables_arr, ordered_tables_arr)
  end

  def return_and_remove_fks(sorting_tables_arr, ordered_tables_arr)
    # if statement to stop infinate recurrsion
    if sorting_tables_arr.any?
      # check tables for no fks & set sorting_fk
      sorting_tables_arr.each do |table|
        no_fks_array = []
        table[:columns].each do |column|
          no_fks_array << column[:sorting_relations].empty?
        end
        # push table to ordered_tables_arr if no_fks, and remove it from sorting_table_arr
        unless no_fks_array.include?(false)
          ordered_tables_arr << table
          sorting_tables_arr.delete(table)
        end
      end

      # remove now sorted table from other tables sorting_relations
      ordered_tables_arr.each do |ord_table|
        # for every ordered table, go through the remaining tables
        sorting_tables_arr.each do |table|
          table[:columns].each do |column|
            column[:sorting_relations].each do |relation|
              # remove any relation from sorting_relations which has been sorted already
              if relation[:relation_table] == ord_table[:table_name]
                column[:sorting_relations].delete(relation)
              end # if
            end # relations loop
          end # column loop
        end # remaining tables loop
      end # already ordered tables loop
    else
      return ordered_tables_arr
    end
    return_and_remove_fks(sorting_tables_arr, ordered_tables_arr)
  end

  def project_params
    params.require(:project).permit(:name, :user_id, :xml_schema)
  end

  def check_if_user_is_owner?
    current_user.id == @project.user_id
  end

  def set_project
    @project = Project.find(params[:id])
  end


end
