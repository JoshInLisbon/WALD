class Project < ApplicationRecord
  belongs_to :user
  has_many :appFiles

  validates :name, presence: true
  validates :xml_schema, presence: true

  # def method(commands)
  #   commands.each do |commmand|
  #     "rails_command #{command}\n"
  #   end
  # end

  # def template(commands)
  #   "run 'pgrep spring | xargs kill -9'

  #   # GEMFILE
  #   ########################################
  #   run 'rm Gemfile'
  #   file 'Gemfile', <<-RUBY
  #   source 'https://rubygems.org'
  #   ruby '\#{RUBY_VERSION}'

  #   \#{\"gem 'bootsnap', require: false\" if Rails.version >= \"5.2\"}
  #   gem 'jbuilder', '~> 2.0'
  #   gem 'pg', '~> 0.21'
  #   gem 'puma'
  #   gem 'rails', '\#{Rails.version}'
  #   gem 'redis'

  #   gem 'autoprefixer-rails'
  #   gem 'font-awesome-sass', '~> 5.6.1'
  #   gem 'sassc-rails'
  #   gem 'simple_form'
  #   gem 'uglifier'
  #   gem 'webpacker'

  #   group :development do
  #     gem 'web-console', '>= 3.3.0'
  #   end

  #   group :development, :test do
  #     gem 'pry-byebug'
  #     gem 'pry-rails'
  #     gem 'listen', '~> 3.0.5'
  #     gem 'spring'
  #     gem 'spring-watcher-listen', '~> 2.0.0'
  #     gem 'dotenv-rails'
  #   end
  #   RUBY

  #   # Ruby version
  #   ########################################
  #   file '.ruby-version', RUBY_VERSION

  #   # Procfile
  #   ########################################
  #   file 'Procfile', <<-YAML
  #   web: bundle exec puma -C config/puma.rb
  #   YAML

  #   # Assets
  #   ########################################
  #   run 'rm -rf app/assets/stylesheets'
  #   run 'rm -rf vendor'
  #   run 'curl -L https://github.com/lewagon/stylesheets/archive/master.zip > stylesheets.zip'
  #   run 'unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets'

  #   run 'rm app/assets/javascripts/application.js'
  #   file 'app/assets/javascripts/application.js', <<-JS
  #   //= require rails-ujs
  #   //= require_tree .
  #   JS

  #   # Dev environment
  #   ########################################
  #   gsub_file('config/environments/development.rb', /config\\.assets\\.debug.*/, 'config.assets.debug = false')

  #   # Layout
  #   ########################################
  #   run 'rm app/views/layouts/application.html.erb'
  #   file 'app/views/layouts/application.html.erb', <<-HTML
  #   <!DOCTYPE html>
  #   <html>
  #     <head>
  #       <meta charset=\"UTF-8\">
  #       <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">
  #       <title>TODO</title>
  #       <%= csrf_meta_tags %>
  #       <%= action_cable_meta_tag %>
  #       <%= stylesheet_link_tag 'application', media: 'all' %>
  #       <%#= stylesheet_pack_tag 'application', media: 'all' %> <!-- Uncomment if you import CSS in app/javascript/packs/application.js -->
  #     </head>
  #     <body>
  #       <%= yield %>
  #       <%= javascript_include_tag 'application' %>
  #       <%= javascript_pack_tag 'application' %>
  #     </body>
  #   </html>
  #   HTML

  #   # README
  #   ########################################
  #   markdown_file_content = <<-MARKDOWN
  #   Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
  #   MARKDOWN
  #   file 'README.md', markdown_file_content, force: true

  #   # Generators
  #   ########################################
  #   generators = <<-RUBY
  #   config.generators do |generate|
  #         generate.assets false
  #         generate.helper false
  #         generate.test_framework  :test_unit, fixture: false
  #       end
  #   RUBY

  #   environment generators

  #   ########################################
  #   # AFTER BUNDLE
  #   ########################################
  #   after_bundle do
  #     # Generators: db + simple form + pages controller
  #     ########################################
  #     rails_command 'db:drop db:create db:migrate'
  #     generate('simple_form:install', '--bootstrap')
  #     generate(:controller, 'pages', 'home', '--skip-routes', '--no-test-framework')

  #     # Routes
  #     ########################################
  #     route \"root to: 'pages#home'\"

  #     # Git ignore
  #     ########################################
  #     append_file '.gitignore', <<-TXT

  #   # Ignore .env file containing credentials.
  #   .env*

  #   # Ignore Mac and Linux file system files
  #   *.swp
  #   .DS_Store
  #   TXT

  #     # Webpacker / Yarn
  #     ########################################
  #     run 'rm app/javascript/packs/application.js'
  #     run 'yarn add popper.js jquery bootstrap'
  #     file 'app/javascript/packs/application.js', <<-JS
  #   import \"bootstrap\";
  #   JS

  #     inject_into_file 'config/webpack/environment.js', before: 'module.exports' do
  #   <<-JS
  #   const webpack = require('webpack')

  #   // Preventing Babel from transpiling NodeModules packages
  #   environment.loaders.delete('nodeModules');

  #   // Bootstrap 4 has a dependency over jQuery & Popper.js:
  #   environment.plugins.prepend('Provide',
  #     new webpack.ProvidePlugin({
  #       $: 'jquery',
  #       jQuery: 'jquery',
  #       Popper: ['popper.js', 'default']
  #     })
  #   )

  #   JS
  #     end

  #     # Building your models
  #     #{method(@commands)}

  #     # Dotenv
  #     ########################################
  #     run 'touch .env'

  #     # Rubocop
  #     ########################################
  #     run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml'

  #     # Git
  #     ########################################
  #     git :init
  #     git add: '.'
  #     git commit: \"-m 'Initial commit with minimal template from https://github.com/lewagon/rails-templates'\"
  #   end"
  # end
end
