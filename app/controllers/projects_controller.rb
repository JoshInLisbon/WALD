class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :destroy, :update]
  # before_action :check_if_user_is_owner?,  only: [:show]
  skip_before_action :authenticate_user!, only: [:template, :template_params, :devise_template, :devise_template_params, :show]

  def index
    @projects = Project.where(user_id: current_user.id).order(created_at: :desc)
  end

  def new
    @project = Project.new
    @project.user = current_user
  end

  def create
    @project = Project.new(project_params)
    parse_xml(params[:project][:xml_schema])
    @project.tables = @tables_arr
    @project.models = model_names(@tables_arr)
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

  def destroy
    @project.user = current_user

    @project.destroy

    respond_to do |format|
      format.js
    end
  end

  def update
    @project.update(project_params)

    redirect_to project_path(@project)
  end


  def template
    @project = Project.find(params[:project_id])
    xml_string = @project.xml_schema
    parse_xml(xml_string)
    send_data templating(@commands), filename: "template-#{@project.name.gsub(/\s+/m, '-').downcase}.rb", disposition: 'attachment'
  end

  def template_params
    @project = Project.find(params[:project_id])
    xml_string = @project.xml_schema
    check_devise(params[:all_params])
    check_github(params[:all_params])
    check_heroku(params[:all_params])
    check_scaffold(params[:all_params])
    check_seed(params[:all_params])
    if @devise == true
      @devise_model = "user"
      devise_parse_xml(xml_string)
      send_data devise_templating(@commands), filename: "template-#{@project.name.gsub(/\s+/m, '-').downcase}.rb", disposition: 'attachment'
    else
      parse_xml(xml_string)
      send_data templating(@commands), filename: "template-#{@project.name.gsub(/\s+/m, '-').downcase}.rb", disposition: 'attachment'
    end
  end

  private

  ##########################################
  # basic controller methods :
  ##########################################

  def project_params
    params.require(:project).permit(:name, :user_id, :xml_schema)
  end

  def check_if_user_is_owner?
    current_user.id == @project.user_id
  end

  def set_project
    @project = Project.find(params[:id])
  end

  ##########################################
  # parsing XML methods :
  ##########################################

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

    @tables_arr = order(tables_arr)
    @commands = commands
    @rails_commands = rails_commands
  end

  def model_names(tables)
    model_names = []

    tables.each do |table|
      # if table[:table_name].length <= 1
      #   model_names << "#{table[:table_name]}".gsub(/\s+/m, '_').downcase
      # elsif table[:table_name].chars.last(3).join == "ies"
      #   model_names << "#{table[:table_name][0..-4]}y".gsub(/\s+/m, '_').downcase
      # elsif table[:table_name].chars.last == "s"
      #   model_names << "#{table[:table_name][0..-2]}".gsub(/\s+/m, '_').downcase
      # else
      #   model_names << "#{table[:table_name]}".gsub(/\s+/m, '_').downcase
      # end

      model_names << "#{table[:table_name].singularize}".gsub(/\s+/m, '_').downcase
    end

    model_names
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


  ##########################################
  # creating the commands methods :
  ##########################################

  def commands
    @commands = []

    @tables_arr.each do |table|
      table_name = table[:table_name].singularize.gsub(/\s+/m, '_').downcase

      # if table_name.length <= 1
      #   command = "rails g model #{table_name} "
      # elsif table_name.chars.last(3).join == "ies"
      #   command = "rails g model #{table_name[0..-4]}y "
      # elsif table_name.chars.last == "s"
      #   command = "rails g model #{table_name[0..-2]} "
      # else
      #   command = "rails g model #{table_name} "
      # end

      command = "rails g model #{table_name} "

      table[:columns].each do |column|
        next if column[:column_name] == "id"

        column_name = column[:column_name]
        data_type = column[:data_type]

        command += " #{column_name}:#{data_type}"

        if column[:fk] == true
          column[:relations].each do |relation|
            relation_table_name = relation[:relation_table].singularize.gsub(/\s+/m, '_').downcase

            # if relation_table_name.length <= 1
            #   command += " #{relation_table_name}:references"
            # elsif relation_table_name.chars.last(3).join == "ies"
            #   command += " #{relation_table_name[0..-4]}y:references"
            # elsif relation_table_name.chars.last == "s"
            #   command += " #{relation_table_name[0..-2]}:references"
            # else
            #   command += " #{relation_table_name}:references"
            # end

            command += " #{relation_table_name}:references"

          end
        end
      end

      splitted_commands = command.split(" ").map do |cmd|
        cmd.include?("id") ? cmd = "" : cmd + " "
      end
      @commands << splitted_commands.join("")
    end
    @commands
  end


  def rails_commands

    @rails_commands = []

    @tables_arr.each do |table|
      singular_table_name = table[:table_name].singularize.gsub(/\s+/m, '_').downcase

      # if table_name.length <= 1
      #   singular_table_name = "#{table_name}"
      # elsif table_name.chars.last(3).join == "ies"
      #   singular_table_name = "#{table_name[0..-4]}y"
      # elsif table_name.chars.last == "s"
      #   singular_table_name = "#{table_name[0..-2]}"
      # else
      #   singular_table_name = "#{table_name}"
      # end

      if @scaffold_models.present?
        if @scaffold_models.include?(singular_table_name)
          command = "scaffold #{singular_table_name} "
        else
          command = "model #{singular_table_name} "
        end
      else
        command = "model #{singular_table_name} "
      end

      table[:columns].each do |column|
        next if column[:column_name] == "id"

        column_name = column[:column_name]
        data_type = column[:data_type]

        command += " #{column_name}:#{data_type}"

        if column[:fk] == true
          column[:relations].each do |relation|

            relation_table_name = relation[:relation_table].singularize.gsub(/\s+/m, '_').downcase

            # if relation_table_name.length <= 1
            #   command += " #{relation_table_name}:references"
            # elsif relation_table_name.chars.last(3).join == "ies"
            #   command += " #{relation_table_name[0..-4]}y:references"
            # elsif relation_table_name.chars.last == "s"
            #   command += " #{relation_table_name[0..-2]}:references"
            # else
            #   command += " #{relation_table_name}:references"
            # end

            command += " #{relation_table_name}:references"

            # relation_table_name = relation[:relation_table].gsub(/\s+/m, '_').downcase

            # if relation_table_name.length <= 1
            #   command += " #{relation_table_name}:references"
            # elsif relation_table_name.chars.last(3).join == "ies"
            #   command += " #{relation_table_name[0..-4]}y:references"
            # elsif relation_table_name.chars.last == "s"
            #   command += " #{relation_table_name[0..-2]}:references"
            # else
            #   command += " #{relation_table_name}:references"
            # end
          end
        end
      end

      splitted_commands = command.split(" ").map do |cmd|
        cmd.include?("id") ? cmd = "" : cmd + " "
      end
      @rails_commands << splitted_commands.join("")

    end
    @rails_commands
  end

  def method(commands)
    array = commands.map do |command|
      "generate '#{command}'"
    end
    array.join("\n")

  end

  def check_devise(params)
    if params.match("&devise")
      @devise = true
    else
      @devise = false
    end
  end

  def check_heroku(params)
    if params.match("&heroku")
      @heroku = true
    else
      @heroku = false
    end
  end

  def check_github(params)
    if params.match("&github")
      @github = true
    else
      @github = false
    end
  end

  def check_seed(params)
    if params.match("&seed")
      @seed = true
    else
      @seed = false
    end
  end


  ##########################################
  # creating Devise commands:
  ##########################################

  def devise_parse_xml(xml_string)
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

    @tables_arr = order(tables_arr)
    @devise_rails_commands = devise_rails_commands
  end

  def devise_rails_commands
    @commands = []

    @tables_arr.each do |table|
      singular_table_name = table[:table_name].singularize.gsub(/\s+/m, '_').downcase

      # if table_name.length <= 1
      #   singular_table_name = "#{table_name}"
      # elsif table_name.chars.last(3).join == "ies"
      #   singular_table_name = "#{table_name[0..-4]}y"
      # elsif table_name.chars.last == "s"
      #   singular_table_name = "#{table_name[0..-2]}"
      # else
      #   singular_table_name = "#{table_name}"
      # end

      if singular_table_name == @devise_model
        command = "devise #{singular_table_name} "
      else
        if @scaffold_models.include?(singular_table_name)
          command = "scaffold #{singular_table_name} "
        else
          command = "model #{singular_table_name} "
        end
      end

      table[:columns].each do |column|
        if singular_table_name == @devise_model
          next if ["email", "password"].include? column[:column_name]
        end
        next if column[:column_name] == "id"

        column_name = column[:column_name]
        data_type = column[:data_type]

        command += " #{column_name}:#{data_type}"

        if column[:fk] == true
          column[:relations].each do |relation|
            # relation_table_name = relation[:relation_table].gsub(/\s+/m, '_').downcase

            # if relation_table_name.length <= 1
            #   command += " #{relation_table_name}:references"
            # elsif relation_table_name.chars.last(3).join == "ies"
            #   command += " #{relation_table_name[0..-4]}y:references"
            # elsif relation_table_name.chars.last == "s"
            #   command += " #{relation_table_name[0..-2]}:references"
            # else
            #   command += " #{relation_table_name}:references"
            # end

            relation_table_name = relation[:relation_table].singularize.gsub(/\s+/m, '_').downcase

            # if relation_table_name.length <= 1
            #   command += " #{relation_table_name}:references"
            # elsif relation_table_name.chars.last(3).join == "ies"
            #   command += " #{relation_table_name[0..-4]}y:references"
            # elsif relation_table_name.chars.last == "s"
            #   command += " #{relation_table_name[0..-2]}:references"
            # else
            #   command += " #{relation_table_name}:references"
            # end

            command += " #{relation_table_name}:references"
          end
        end
      end

      splitted_commands = command.split(" ").map do |cmd|
        cmd.include?("id") ? cmd = "" : cmd + " "
      end
      @commands << splitted_commands.join("")
    end
    @commands << "devise user" if @project.models.exclude?("user")

    @commands
  end

  ##########################################
  # templates
  ##########################################

  def check_scaffold(params)
    @scaffold_models = params.scan(/&s-([^&]+)/).flatten.compact
  end

  def heroku_commands
    if @heroku == true

      "run 'heroku create #{@project.name.gsub(/\s+/m, '-').downcase}#{rand(10000..99999)} --region eu' \n
      git push: 'heroku master' \n
      run 'heroku run rails db:migrate' \n
      run 'heroku open'"
    else
      ""
    end
  end

  def github_commands
    if @github == true
      "run 'hub create' \n
      git add: '.' \n
      git commit: \"-m 'first commit to new app repository'\" \n
      git push: 'origin master' "
    else
      ""
    end
  end

  def templating(commands)
    "run 'pgrep spring | xargs kill -9'

    # GEMFILE
    ########################################
    run 'rm Gemfile'
    file 'Gemfile', <<-RUBY
    source 'https://rubygems.org'
    ruby '\#{RUBY_VERSION}'

    \#{\"gem 'bootsnap', require: false\" if Rails.version >= \"5.2\"}
    gem 'jbuilder', '~> 2.0'
    gem 'pg', '~> 0.21'
    gem 'puma'
    gem 'rails', '\#{Rails.version}'
    gem 'redis'

    gem 'autoprefixer-rails'
    gem 'font-awesome-sass', '~> 5.6.1'
    gem 'sassc-rails'
    gem 'simple_form'
    gem 'uglifier'
    gem 'webpacker'
    gem 'faker'

    group :development do
      gem 'web-console', '>= 3.3.0'
    end

    group :development, :test do
      gem 'pry-byebug'
      gem 'pry-rails'
      gem 'listen', '~> 3.0.5'
      gem 'spring'
      gem 'spring-watcher-listen', '~> 2.0.0'
      gem 'dotenv-rails'
    end
    RUBY

    # Ruby version
    ########################################
    file '.ruby-version', RUBY_VERSION

    # Procfile
    ########################################
    file 'Procfile', <<-YAML
    web: bundle exec puma -C config/puma.rb
    YAML

    # Assets
    ########################################
    run 'rm -rf app/assets/stylesheets'
    run 'rm -rf vendor'
    run 'curl -L https://github.com/lewagon/stylesheets/archive/master.zip > stylesheets.zip'
    run 'unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets'

    run 'rm app/assets/javascripts/application.js'
    file 'app/assets/javascripts/application.js', <<-JS
    //= require rails-ujs
    //= require_tree .
    JS

    # Dev environment
    ########################################
    gsub_file('config/environments/development.rb', /config\\.assets\\.debug.*/, 'config.assets.debug = false')

    # Layout
    ########################################
    run 'rm app/views/layouts/application.html.erb'
    file 'app/views/layouts/application.html.erb', <<-HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset=\"UTF-8\">
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">
        <title>TODO</title>
        <%= csrf_meta_tags %>
        <%= action_cable_meta_tag %>
        <%= stylesheet_link_tag 'application', media: 'all' %>
        <%#= stylesheet_pack_tag 'application', media: 'all' %> <!-- Uncomment if you import CSS in app/javascript/packs/application.js -->
      </head>
      <body>
        <div class=\"container\">
        <%= yield %>
        </div>
        <%= javascript_include_tag 'application' %>
        <%= javascript_pack_tag 'application' %>
      </body>
    </html>
    HTML

    # README
    ########################################
    markdown_file_content = <<-MARKDOWN
    Rails app generated by WALD team (https://waldevelopers.herokuapp.com).
    MARKDOWN
    file 'README.md', markdown_file_content, force: true

    # Generators
    ########################################
    generators = <<-RUBY
    config.generators do |generate|
          generate.assets false
          generate.helper false
          generate.test_framework  :test_unit, fixture: false
        end
    RUBY

    environment generators

    ########################################
    # AFTER BUNDLE
    ########################################
    after_bundle do
      # Generators: db + simple form + pages controller
      ########################################
      rails_command 'db:drop db:create db:migrate'
      generate('simple_form:install', '--bootstrap')
      generate(:controller, 'pages', 'home', '--skip-routes', '--no-test-framework')

      # Routes
      ########################################
      route \"root to: 'pages#home'\"

      # Git ignore
      ########################################
      append_file '.gitignore', <<-TXT

    # Ignore .env file containing credentials.
    .env*

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
    TXT

      # Webpacker / Yarn
      ########################################
      run 'rm app/javascript/packs/application.js'
      run 'yarn add popper.js jquery bootstrap'
      file 'app/javascript/packs/application.js', <<-JS
    import \"bootstrap\";
    JS

      inject_into_file 'config/webpack/environment.js', before: 'module.exports' do
    <<-JS
    const webpack = require('webpack')

    // Preventing Babel from transpiling NodeModules packages
    environment.loaders.delete('nodeModules');

    // Bootstrap 4 has a dependency over jQuery & Popper.js:
    environment.plugins.prepend('Provide',
      new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        Popper: ['popper.js', 'default']
      })
    )

    JS
      end

      # Building _index.html.erb if Scaffold
      ########################################
      #{alter_scaffold if @scaffole_models.present? && @scaffold_models.any?}

      # Building your models
      #{ method(@rails_commands) }
      rails_command 'db:migrate'

      # Dotenv
      ########################################
      run 'touch .env'

      # Rubocop
      ########################################
      run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml'

      # Homepage
      ########################################
      run 'rm app/views/pages/home.html.erb'
      file 'app/views/pages/home.html.erb', <<-HTML

      <img src=\"https://raw.githubusercontent.com/JoshInLisbon/WALD/master/for_WALD_apps/logo.png\" style=\"max-width: 250px; />
      <h1>🍻 Welcome to your WALD app</h1>
      #{pages_in_your_app}
      #{models_without_pages}
      HTML

      # Seeds
      ########################################
      run 'rm db/seeds.rb'
      file 'db/seeds.rb', <<-RUBY

      # This file should contain all the record creation needed to seed the database with its default values.
      # The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
      #
      # The seeds below were created by WALD (We Are Lazy Developers)
      #{seed_models}
      RUBY
      #{"rails_command 'db:seed'" if @seed == true}

      # Git
      ########################################
      git :init
      git add: '.'
      git commit: \"-m 'Initial commit with minimal template from https://github.com/lewagon/rails-templates'\"

      #{heroku_commands}
      #{github_commands}

      puts '$$\\      $$\\  $$$$$$\\  $$\\      $$$$$$$\\         '
      puts '$$ | $\\  $$ |$$  __$$\\ $$ |     $$  __$$\\        '
      puts '$$ |$$$\\ $$ |$$ /  $$ |$$ |     $$ |  $$ |       '
      puts '$$ $$ $$\\$$ |$$$$$$$$ |$$ |     $$ |  $$ |       '
      puts '$$$$  _$$$$ |$$  __$$ |$$ |     $$ |  $$ |       '
      puts '$$$  / \\$$$ |$$ |  $$ |$$ |     $$ |  $$ |       '
      puts '$$  /| |\\$$ |$$ |  $$ |$$$$$$$$\\$$$$$$$  |       '
      puts '\\__/ | | \\__|\\__|  \\__|\\________\\_______/        '
      puts '| |  | |                                         '
      puts '| |  | | ___                                     '
      puts '| |/\\| |/ _ \\                                    '
      puts '\\  /\\  /  __/                                    '
      puts ' \\/__\\/ \\___|                                    '
      puts ' / _ \\                                           '
      puts '/ /_\\ \\_ __ ___                                  '
      puts '|  _  |  __/ _ \\                                 '
      puts '| | | | | |  __/                                 '
      puts '\\_| |_/_|  \\___|                                 '
      puts '| |                                              '
      puts '| |     __ _ _____   _                           '
      puts '| |    / _` |_  / | | |                          '
      puts '| |___| (_| |/ /| |_| |                          '
      puts '\\_____/\\__,_/___|\\__, |                          '
      puts '                  __/ |                          '
      puts '______           |___/                           '
      puts '|  _  \\             | |                          '
      puts '| | | |_____   _____| | ___  _ __   ___ _ __ ___ '
      puts '| | | / _ \\ \\ / / _ \\ |/ _ \\|  _ \\ / _ \\  __/ __|'
      puts '| |/ /  __/\\ V /  __/ | (_) | |_) |  __/ |  \\__ \\\\'
      puts '|___/ \\___| \\_/ \\___|_|\\___/| .__/ \\___|_|  |___/'
      puts '                            | |                  '
      puts '                            |_|                  '
      puts 'Made by:'
      puts 'Josh, Lucas, Pedro & Sapir'
      puts '☎️ - Hire us: waldevelopers@gmail.com'
    end"
  end

  def devise_templating(commands)
    "run 'pgrep spring | xargs kill -9'

    # GEMFILE
    ########################################
    run 'rm Gemfile'
    file 'Gemfile', <<-RUBY
    source 'https://rubygems.org'
    ruby '\#{RUBY_VERSION}'

    \#{\"gem 'bootsnap', require: false\" if Rails.version >= \"5.2\"}
    gem 'devise'
    gem 'jbuilder', '~> 2.0'
    gem 'pg', '~> 0.21'
    gem 'puma'
    gem 'rails', '\#{Rails.version}'
    gem 'redis'

    gem 'autoprefixer-rails'
    gem 'font-awesome-sass', '~> 5.6.1'
    gem 'sassc-rails'
    gem 'simple_form'
    gem 'uglifier'
    gem 'webpacker'
    gem 'faker'

    group :development do
      gem 'web-console', '>= 3.3.0'
    end

    group :development, :test do
      gem 'pry-byebug'
      gem 'pry-rails'
      gem 'listen', '~> 3.0.5'
      gem 'spring'
      gem 'spring-watcher-listen', '~> 2.0.0'
      gem 'dotenv-rails'
    end
    RUBY

    # Ruby version
    ########################################
    file '.ruby-version', RUBY_VERSION

    # Procfile
    ########################################
    file 'Procfile', <<-YAML
    web: bundle exec puma -C config/puma.rb
    YAML

    # Assets
    ########################################
    run 'rm -rf app/assets/stylesheets'
    run 'rm -rf vendor'
    run 'curl -L https://github.com/lewagon/stylesheets/archive/master.zip > stylesheets.zip'
    run 'unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets'

    run 'rm app/assets/javascripts/application.js'
    file 'app/assets/javascripts/application.js', <<-JS
    //= require rails-ujs
    //= require_tree .
    JS

    # Dev environment
    ########################################
    gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

    # Layout
    ########################################
    run 'rm app/views/layouts/application.html.erb'
    file 'app/views/layouts/application.html.erb', <<-HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset=\"UTF-8\">
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">
        <title>TODO</title>
        <%= csrf_meta_tags %>
        <%= action_cable_meta_tag %>
        <%= stylesheet_link_tag 'application', media: 'all' %>
        <%#= stylesheet_pack_tag 'application', media: 'all' %> <!-- Uncomment if you import CSS in app/javascript/packs/application.js -->
      </head>
      <body>
        <%= render 'shared/navbar' %>
        <%= render 'shared/flashes' %>
        <div class=\"container\">
        <%= yield %>
        </div>
        <%= javascript_include_tag 'application' %>
        <%= javascript_pack_tag 'application' %>
      </body>
    </html>
    HTML

    file 'app/views/shared/_flashes.html.erb', <<-HTML
    <\% if notice %>
      <div class=\"alert alert-info alert-dismissible fade show m-1\" role=\"alert\">
        <%= notice %>
        <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\">
          <span aria-hidden=\"true\">&times;</span>
        </button>
      </div>
    <\% end %>
    <\% if alert %>
      <div class=\"alert alert-warning alert-dismissible fade show m-1\" role=\"alert\">
        <%= alert %>
        <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\">
          <span aria-hidden=\"true\">&times;</span>
        </button>
      </div>
    <\% end %>
    HTML

    run 'curl -L https://raw.githubusercontent.com/JoshInLisbon/WALD/master/for_WALD_apps/_navbar_wald.html.erb > app/views/shared/_navbar.html.erb'
    run 'curl -L https://raw.githubusercontent.com/JoshInLisbon/WALD/master/for_WALD_apps/logo.png > app/assets/images/logo.png'

    # README
    ########################################
    markdown_file_content = <<-MARKDOWN
    Rails app generated by WALD team (https://waldevelopers.herokuapp.com).
    MARKDOWN
    file 'README.md', markdown_file_content, force: true

    # Generators
    ########################################
    generators = <<-RUBY
    config.generators do |generate|
          generate.assets false
          generate.helper false
          generate.test_framework  :test_unit, fixture: false
        end
    RUBY

    environment generators

    ########################################
    # AFTER BUNDLE
    ########################################
    after_bundle do
      # Generators: db + simple form + pages controller
      ########################################
      rails_command 'db:drop db:create db:migrate'
      generate('simple_form:install', '--bootstrap')
      generate(:controller, 'pages', 'home', '--skip-routes', '--no-test-framework')

      # Routes
      ########################################
      route \"root to: 'pages#home'\"

      # Git ignore
      ########################################
      append_file '.gitignore', <<-TXT

    # Ignore .env file containing credentials.
    .env*

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
    TXT

    # Building _index.html.erb if Scaffold
    ########################################
    #{alter_scaffold if @scaffole_models.present? && @scaffold_models.any?}

    # Building your models (including devise model)
      # Devise install + user
      ########################################
      generate('devise:install')

      #{ method(@devise_rails_commands) }

      # App controller
      ########################################
      run 'rm app/controllers/application_controller.rb'
      file 'app/controllers/application_controller.rb', <<-RUBY
    class ApplicationController < ActionController::Base
    \#{\"  protect_from_forgery with: :exception\n\" if Rails.version < \"5.2\"}  before_action :authenticate_user!
    end
    RUBY

      # migrate + devise views
      ########################################
      rails_command 'db:migrate'
      generate('devise:views')

      # Pages Controller
      ########################################
      run 'rm app/controllers/pages_controller.rb'
      file 'app/controllers/pages_controller.rb', <<-RUBY
    class PagesController < ApplicationController
      skip_before_action :authenticate_user!, only: [:home]

      def home
      end
    end
    RUBY

      # Environments
      ########################################
      environment 'config.action_mailer.default_url_options = { host: \"http://localhost:3000\" }', env: 'development'
      environment 'config.action_mailer.default_url_options = { host: \"http://TODO_PUT_YOUR_DOMAIN_HERE\" }', env: 'production'

      # Webpacker / Yarn
      ########################################
      run 'rm app/javascript/packs/application.js'
      run 'yarn add popper.js jquery bootstrap'
      file 'app/javascript/packs/application.js', <<-JS
    import \"bootstrap\";
    JS

      inject_into_file 'config/webpack/environment.js', before: 'module.exports' do
    <<-JS
    const webpack = require('webpack')

    // Preventing Babel from transpiling NodeModules packages
    environment.loaders.delete('nodeModules');

    // Bootstrap 4 has a dependency over jQuery & Popper.js:
    environment.plugins.prepend('Provide',
      new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        Popper: ['popper.js', 'default']
      })
    )

    JS
      end

      # Dotenv
      ########################################
      run 'touch .env'

      # Rubocop
      ########################################
      run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml'

      # Homepage
      ########################################
      run 'rm app/views/pages/home.html.erb'
      file 'app/views/pages/home.html.erb', <<-HTML

      <img src=\"https://raw.githubusercontent.com/JoshInLisbon/WALD/master/for_WALD_apps/logo.png\" style=\"max-width: 250px;\" />
      <h1>🍻 Welcome to your WALD app</h1>
      #{pages_in_your_app}
      #{models_without_pages}
      HTML

      # Seeds
      ########################################
      run 'rm db/seeds.rb'
      file 'db/seeds.rb', <<-RUBY

      # This file should contain all the record creation needed to seed the database with its default values.
      # The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
      #
      # The seeds below were created by WALD (We Are Lazy Developers)
      #{seed_models}
      RUBY
      #{"rails_command 'db:seed'" if @seed == true}

      # Git
      ########################################
      git :init
      git add: '.'
      git commit: \"-m 'Initial commit with devise template from https://github.com/lewagon/rails-templates'\"

      #{heroku_commands}
      #{github_commands}

      puts '$$\\      $$\\  $$$$$$\\  $$\\      $$$$$$$\\         '
      puts '$$ | $\\  $$ |$$  __$$\\ $$ |     $$  __$$\\        '
      puts '$$ |$$$\\ $$ |$$ /  $$ |$$ |     $$ |  $$ |       '
      puts '$$ $$ $$\\$$ |$$$$$$$$ |$$ |     $$ |  $$ |       '
      puts '$$$$  _$$$$ |$$  __$$ |$$ |     $$ |  $$ |       '
      puts '$$$  / \\$$$ |$$ |  $$ |$$ |     $$ |  $$ |       '
      puts '$$  /| |\\$$ |$$ |  $$ |$$$$$$$$\\$$$$$$$  |       '
      puts '\\__/ | | \\__|\\__|  \\__|\\________\\_______/        '
      puts '| |  | |                                         '
      puts '| |  | | ___                                     '
      puts '| |/\\| |/ _ \\                                    '
      puts '\\  /\\  /  __/                                    '
      puts ' \\/__\\/ \\___|                                    '
      puts ' / _ \\                                           '
      puts '/ /_\\ \\_ __ ___                                  '
      puts '|  _  |  __/ _ \\                                 '
      puts '| | | | | |  __/                                 '
      puts '\\_| |_/_|  \\___|                                 '
      puts '| |                                              '
      puts '| |     __ _ _____   _                           '
      puts '| |    / _` |_  / | | |                          '
      puts '| |___| (_| |/ /| |_| |                          '
      puts '\\_____/\\__,_/___|\\__, |                          '
      puts '                  __/ |                          '
      puts '______           |___/                           '
      puts '|  _  \\             | |                          '
      puts '| | | |_____   _____| | ___  _ __   ___ _ __ ___ '
      puts '| | | / _ \\ \\ / / _ \\ |/ _ \\|  _ \\ / _ \\  __/ __|'
      puts '| |/ /  __/\\ V /  __/ | (_) | |_) |  __/ |  \\__ \\\\'
      puts '|___/ \\___| \\_/ \\___|_|\\___/| .__/ \\___|_|  |___/'
      puts '                            | |                  '
      puts '                            |_|                  '
      puts 'Made by:'
      puts 'Josh, Lucas, Pedro & Sapir'
      puts '☎️ - Hire us: waldevelopers@gmail.com'
      #{"puts 'Seed emails: 1@email.com, 2@email.com, ... , 10@email.com'" if @seed == true && @devise == true}
      #{"puts 'Password for all users: \"password\"'" if @seed == true && @devise == true}
    end"
  end

  #################################
# method to generate Scaffold
  #################################

  def pages_in_your_app
    indexes_array = []
    if @scaffold_models.present?
      indexes_array << "<h3>Models with views</h3>"
      @scaffold_models.each do |s_model|
        indexes_array << "
          <p><%= link_to '#{s_model.pluralize} Index', #{s_model.pluralize}_path %></p>
        "
      end
    end
    indexes_array.join("\n")
  end

  def models_without_pages
    if @scaffold_models.present?
      models_without_pages_array = @project.models - @scaffold_models
      no_indexes_array = []
      if models_without_pages_array.any?
        no_indexes_array << "<h3>Models without views</h3>"
        models_without_pages_array.each do |model|
          no_indexes_array << "
            <p>#{model.pluralize}</p>
          "
        end
      end
      no_indexes_array.join("\n")
    end
  end

  ##########################################
  # seeds
  ##########################################

  def seed_models
    # @tables_arr
    if @seed = true
      no_space_model_names
      seeds_array = []
      @tables_arr.each do |table|
        table_seeds_array = []
        seeds_array << "10.times { |index|"
        table_seeds_array << "10.times { |index|"
        seeds_array << "#{table[:table_name].singularize.gsub(/_/m, ' ').split.map(&:capitalize).join('')}.create("
        table_seeds_array << "#{table[:table_name].singularize.gsub(/_/m, ' ').split.map(&:capitalize).join('')}.create("
        table[:columns].each_with_index do |column, i|
          unless column[:column_name] == "id"
            if column[:column_name].match(/(.+)_id/i)
              @no_space_model_names_arr.each do |n_s_col|
                if n_s_col.casecmp(column[:column_name].match(/(.+)_id/i)[1].singularize) == 0
                  string_arr = []
                  n_s_col.scan(/([A-Z][a-z]*)/).each do |word|
                    string_arr << word
                  end
                  string_arr << 'id'
                  @adjusted_col_name = string_arr.flatten.join('_').downcase
                end
              end
            elsif column[:column_name].match(/id_(.+)/i)
              @no_space_model_names_arr.each do |n_s_col|
                if n_s_col.casecmp(column[:column_name].match(/id_(.+)/i)[1].singularize) == 0
                  string_arr = []
                  n_s_col.scan(/([A-Z][a-z]*)/).each do |word|
                    string_arr << word
                  end
                  string_arr << 'id'
                  @adjusted_col_name = string_arr.flatten.join('_').downcase
                end
              end
            else
              @adjusted_col_name = column[:column_name]
            end
            seeds_array << "#{@adjusted_col_name}: #{seed_data_type(column[:data_type], column[:column_name])} #{i + 1 < table[:columns].length ? ',' : ''}"
            table_seeds_array << "#{@adjusted_col_name}: #{seed_data_type(column[:data_type], column[:column_name])} #{i + 1 < table[:columns].length ? ',' : ''}"
          end
        end
        seeds_array << ')'
        table_seeds_array << ')'
        seeds_array << "} \n"
        table_seeds_array << "} \n"
        if table[:table_name].singularize.downcase == "user" && @devise == true
          email_and_pw_check = seeds_array.join(" ").scan(/(email)|(password)/).flatten.compact
          if table_seeds_array.length < 5
            seeds_array.insert(-3, 'email: \"\\#{index}@email.com\",')
            seeds_array.insert(-3, "password: 'password'")
          else
            seeds_array.insert(-3, ', email: \"\\#{index}@email.com\"') unless email_and_pw_check.include?("email")
            seeds_array.insert(-3, ", password: 'password'") unless email_and_pw_check.include?("password")
          end
        end
      end
    end
    seeds_array.join(" ")
  end

  def no_space_model_names
    @no_space_model_names_arr = []
    @project.models.each do |model|
      @no_space_model_names_arr << model.gsub(/_/m, ' ').split.map(&:capitalize).join('')
    end
    @no_space_model_names_arr
  end

  def seed_data_type(data_type, column_name)
    case data_type
    when :integer
      'rand(1..10)'
    when :decimal
      'rand()'
    when :string
      if column_name == "image" || column_name == "photo"
        'Faker::LoremPixel.image(size: "500x500")'
      elsif column_name == "password"
        "'password'"
      elsif column_name == "email"
        '\"\\#{index}@email.com\"'
      elsif column_name == "name"
        'Faker::Name.unique.name'
      elsif column_name == "address"
        'Faker::Address.full_address'
      else
        'Faker::Lorem.sentence(word_count: #{rand(2..8)})'
      end
    when :text
      'Faker::Lorem.paragraph(sentence_count: 8)'
    when :binary
      '[0, 1].sample'
    when :boolean
      '[true, false].sample'
    when :date
      'rand(Time.now.to_date..(Time.now.to_date + 365))'
    when :time
      'rand(Time.now..(Time.now + 60 * 60 * 24))'
    when :timestamp
      'rand(Time.now..(Time.now + 60 * 60 * 24))'
    when :datetime
      'rand(Time.now..(Time.now + 60 * 60 * 24))'
    end
  end

  def alter_scaffold
    "file 'lib/templates/erb/scaffold/index.html.erb', <<-HTML



    <p id=\"notice\"><%%= notice %></p>

    <h1><%= plural_table_name.downcase %></h1>

    <table>
      <thead>
        <tr>
          <% attributes.reject(&:password_digest?).each do |attribute| -%>
            <th><%= attribute.human_name %></th>
          <% end -%>
          <th colspan=\"3\"></th>
        </tr>
      </thead>

      <tbody>
        <%% @<%= plural_table_name %>.each do |<%= singular_table_name %>| %>
          <tr>
            <% attributes.reject(&:password_digest?).each do |attribute| -%>
              <% if attribute.type == :references %>
                <%% if '<%= attribute.human_name.downcase %>' == 'user' %>
                  <td><%= attribute.name %>_<%%= \"\\\#{<%= singular_table_name %>.<%= attribute.column_name %>}\" %></td>
                <%% else %>
                  <td><%%= link_to \"<%= attribute.name %>_\\\#{<%= singular_table_name %>.<%= attribute.column_name %>}\", <%= singular_table_name %>.<%= attribute.name %> %></td>
                <%% end %>
              <% else %>
                <td><%%= <%= singular_table_name %>.<%= attribute.column_name %> %></td>
              <% end %>
            <% end -%>
            <td><%%= link_to 'Show', <%= model_resource_name %> %></td>
            <td><%%= link_to 'Edit', edit_<%= singular_route_name %>_path(<%= singular_table_name %>) %></td>
            <td><%%= link_to 'Destroy', <%= model_resource_name %>, method: :delete, data: { confirm: 'Are you sure?' } %></td>
          </tr>
        <%% end %>
      </tbody>
    </table>

    <br>

    <%%= link_to 'New <%= singular_table_name.titleize %>', new_<%= singular_route_name %>_path %>




    HTML

    file 'lib/templates/erb/scaffold/show.html.erb', <<-HTML


    <p id=\"notice\"><%%= notice %></p>

    <% attributes.reject(&:password_digest?).each do |attribute| -%>
    <p>
      <strong><%= attribute.human_name %>:</strong>
    <% if attribute.reference? -%>
      <%% if '<%= attribute.human_name.downcase %>' == 'user' %>
        <%= attribute.name %>_<%%= \"\\\#{@<%= singular_table_name %>.<%= attribute.column_name %>}\" %>
      <%% else %>
        <%%= link_to \"<%= attribute.name %>_\\\#{@<%= singular_table_name %>.<%= attribute.column_name %>}\", @<%= singular_table_name %>.<%= attribute.name %> %>
      <%% end %>
    <% else -%>
      <%%= @<%= singular_table_name %>.<%= attribute.column_name %> %>
    <% end -%>
    </p>

    <% end -%>
    <%%= link_to 'Edit', edit_<%= singular_table_name %>_path(@<%= singular_table_name %>) %> |
    <%%= link_to 'Back', <%= index_helper %>_path %>





    HTML
    "
  end

  # def alter_scaffold # old
  #   "file 'lib/templates/erb/scaffold/index.html.erb', <<-HTML

  #   <p id=\"notice\"><%%= notice %></p>

  #   <h1><%= plural_table_name.downcase %></h1>

  #   <table>
  #     <thead>
  #       <tr>
  #         <% attributes.reject(&:password_digest?).each do |attribute| -%>
  #           <th><%= attribute.human_name %></th>
  #         <% end -%>
  #         <th colspan=\"3\"></th>
  #       </tr>
  #     </thead>

  #     <tbody>
  #       <%% @<%= plural_table_name %>.each do |<%= singular_table_name %>| %>
  #         <tr>
  #           <% attributes.reject(&:password_digest?).each do |attribute| -%>
  #             <% if attribute.type == :references %>
  #               <td><%%= link_to \"<%= attribute.name %>_\\\#{<%= singular_table_name %>.<%= attribute.column_name %>}\", <%= singular_table_name %>.<%= attribute.name %> %></td>
  #             <% else %>
  #               <td><%%= <%= singular_table_name %>.<%= attribute.column_name %> %></td>
  #             <% end %>
  #           <% end -%>
  #           <td><%%= link_to 'Show', <%= model_resource_name %> %></td>
  #           <td><%%= link_to 'Edit', edit_<%= singular_route_name %>_path(<%= singular_table_name %>) %></td>
  #           <td><%%= link_to 'Destroy', <%= model_resource_name %>, method: :delete, data: { confirm: 'Are you sure?' } %></td>
  #         </tr>
  #       <%% end %>
  #     </tbody>
  #   </table>

  #   <br>

  #   <%%= link_to 'New <%= singular_table_name.titleize %>', new_<%= singular_route_name %>_path %>



  #   HTML

  #   file 'lib/templates/erb/scaffold/show.html.erb', <<-HTML
  #   <p id=\"notice\"><%%= notice %></p>

  #   <% attributes.reject(&:password_digest?).each do |attribute| -%>
  #   <p>
  #     <strong><%= attribute.human_name %>:</strong>
  #   <% if attribute.reference? -%>
  #     <%%= link_to \"<%= attribute.name %>_\\\#{@<%= singular_table_name %>.<%= attribute.column_name %>}\", @<%= singular_table_name %>.<%= attribute.name %> %>
  #   <% else -%>
  #     <%%= @<%= singular_table_name %>.<%= attribute.column_name %> %>
  #   <% end -%>
  #   </p>

  #   <% end -%>
  #   <%%= link_to 'Edit', edit_<%= singular_table_name %>_path(@<%= singular_table_name %>) %> |
  #   <%%= link_to 'Back', <%= index_helper %>_path %>

  #   HTML
  #   "
  # end
end
