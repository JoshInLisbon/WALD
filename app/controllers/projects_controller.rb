class ProjectsController < ApplicationController
  before_action :set_project, only: [:show]
  # before_action :check_if_user_is_owner?,  only: [:show]
  skip_before_action :authenticate_user!, only: [:template, :devise_template, :show]

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

  # def destroy
  #   @project = Project.find(params[:project_id])
  #   @project.user = current_user
  #   @project.destroy
  # end

  def template
    @project = Project.find(params[:project_id])
    xml_string = @project.xml_schema
    parse_xml(xml_string)
    send_data templating(@commands), filename: 'template.rb', disposition: 'attachment'
  end

  def devise_template
    @project = Project.find(params[:project_id])
    @devise_model = params[:devise_model]
    xml_string = @project.xml_schema
    devise_parse_xml(xml_string)
    send_data devise_templating(@commands), filename: "template-devise-#{params[:devise_model]}.rb", disposition: 'attachment'
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

    @tables_arr = order(tables_arr)
    @commands = commands
    @rails_commands = rails_commands
  end

  def model_names(tables)
    model_names = []

    tables.each do |table|
      if table[:table_name].length <= 1
        model_names << "#{table[:table_name]}".gsub(/\s+/m, '_').downcase
      elsif table[:table_name].chars.last(3).join == "ies"
        model_names << "#{table[:table_name][0..-4]}y".gsub(/\s+/m, '_').downcase
      elsif table[:table_name].chars.last == "s"
        model_names << "#{table[:table_name][0..-2]}".gsub(/\s+/m, '_').downcase
      else
        model_names << "#{table[:table_name]}".gsub(/\s+/m, '_').downcase
      end
    end

    model_names
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
        cmd.include?("id") ? cmd = "" : cmd + " "
      end
      @commands << splitted_commands.join("")


    end
    @commands
  end

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
      table_name = table[:table_name].gsub(/\s+/m, '_').downcase

      if table_name.length <= 1
        singular_table_name = "#{table_name}"
      elsif table_name.chars.last(3).join == "ies"
        singular_table_name = "#{table_name[0..-4]}y"
      elsif table_name.chars.last == "s"
        singular_table_name = "#{table_name[0..-2]}"
      else
        singular_table_name = "#{table_name}"
      end

      if singular_table_name == @devise_model
        command = "devise #{singular_table_name} "
      else
        command = "model #{singular_table_name} "
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
        cmd.include?("id") ? cmd = "" : cmd + " "
      end
      @commands << splitted_commands.join("")


    end
    @commands
  end

  def rails_commands
    @rails_commands = []

    @tables_arr.each do |table|
      table_name = table[:table_name].gsub(/\s+/m, '_').downcase

      if table_name.length <= 1
        command = "model #{table_name} "
      elsif table_name.chars.last(3).join == "ies"
        command = "model #{table_name[0..-4]}y "
      elsif table_name.chars.last == "s"
        command = "model #{table_name[0..-2]} "
      else
        command = "model #{table_name} "
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
        cmd.include?("id") ? cmd = "" : cmd + " "
      end
      @rails_commands << splitted_commands.join("")


    end
    @rails_commands
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

  def method(commands)
    array = commands.map do |command|
      "generate '#{command}'"
    end
    array.join("\n")
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
        <%= yield %>
        <%= javascript_include_tag 'application' %>
        <%= javascript_pack_tag 'application' %>
      </body>
    </html>
    HTML

    # README
    ########################################
    markdown_file_content = <<-MARKDOWN
    Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
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

      # Building your models
      #{ method(@rails_commands) }
      rails_command 'db:migrate'

      # Dotenv
      ########################################
      run 'touch .env'

      # Rubocop
      ########################################
      run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml'

      # Git
      ########################################
      git :init
      git add: '.'
      git commit: \"-m 'Initial commit with minimal template from https://github.com/lewagon/rails-templates'\"

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
        <%= yield %>
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

    run 'curl -L https://github.com/lewagon/awesome-navbars/raw/master/templates/_navbar_wagon.html.erb > app/views/shared/_navbar.html.erb'
    run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/logo.png > app/assets/images/logo.png'

    # README
    ########################################
    markdown_file_content = <<-MARKDOWN
    Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
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

      # Git
      ########################################
      git :init
      git add: '.'
      git commit: \"-m 'Initial commit with devise template from https://github.com/lewagon/rails-templates'\"

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

  def github_templat
    "heroku create #{@project.name.gsub(/\s+/m, '_').downcase} --region eu
    git push heroku master
    heroku run rails db:migrate
    heroku open"
  end

end
