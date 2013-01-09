require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Bakeware
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :meaty, :type => :boolean, :aliases => '-M', :default => false,
      :desc => 'Add the Meaty Extra Goodness (more gems)'

    class_option :database, :type => :string, :aliases => '-d', :default => 'postgresql',
      :desc => "Preconfigure for selected database (options: #{DATABASES.join('/')})"

    class_option :heroku, :type => :boolean, :aliases => '-H', :default => false,
      :desc => 'Create staging and production Heroku apps'

    class_option :github, :type => :string, :aliases => '-G', :default => nil,
      :desc => 'Create Github repository and add remote origin pointed to repo'

    class_option :skip_test_unit, :type => :boolean, :aliases => '-T', :default => false,
      :desc => 'Skip Test::Unit files'

    def finish_template
      invoke :bakeware_customization
      super
    end

    def bakeware_customization
      invoke :remove_files_we_dont_need
      invoke :customize_gemfile
      invoke :setup_development_environment
      invoke :setup_test_environment
      invoke :setup_staging_environment
      invoke :create_bakeware_views
      invoke :create_common_javascripts
      invoke :add_jquery_ui
      invoke :setup_database
      invoke :configure_app
      invoke :setup_stylesheets
      invoke :copy_libraries
      invoke :copy_miscellaneous_files
      invoke :customize_error_pages
      invoke :remove_routes_comment_lines
      invoke :setup_git
      invoke :create_heroku_apps
      invoke :create_github_repo
      invoke :outro
    end

    def remove_files_we_dont_need
      build :remove_public_index
      build :remove_rails_logo_image
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build :raise_delivery_errors
      build :provide_setup_script
    end

    def setup_test_environment
      say 'Setting up the test environment'
      #still need some database cleaners in here
      build :setup_guard_spork
    end

    def setup_staging_environment
      say 'Setting up the staging environment'
      build :setup_staging_environment
      build :initialize_on_precompile
    end

    def create_bakeware_views
      say 'Creating bakeware views'
      build :create_partials_directory
      build :create_shared_flashes
      build :create_shared_javascripts
      build :create_application_layout
    end

    def create_common_javascripts
      say 'Pulling in some common javascripts'
      build :create_common_javascripts
    end

    def add_jquery_ui
      say 'Add jQuery ui to the standard application.js'
      build :add_jquery_ui
    end

    def customize_gemfile
      build :set_ruby_to_version_being_used
      build :add_custom_gems

      if options[:meaty]
        build :add_meaty_gems
        build :add_extra_config
      end
      say 'installing gems - BE PATIENT'
      
      bundle_command 'install --binstubs=bin/stubs'
    end

    def setup_database
      say 'Setting up database'

      if 'postgresql' == options[:database]
        build :use_postgres_config_template
      end

      build :create_database
    end

    def configure_app
      say 'Configuring app'
      build :configure_action_mailer
      build :configure_time_zone
      build :configure_time_formats

      build :add_email_validator
      build :setup_default_rake_task
      build :setup_foreman
    end

    def setup_stylesheets
      say 'Set up stylesheets'
      build :setup_stylesheets
    end

    def setup_git
      say 'Initializing git'
      invoke :setup_gitignore
      invoke :init_git
    end

    def create_heroku_apps
      if options[:heroku]
        say 'Creating Heroku apps'
        build :create_heroku_apps
      end
    end

    def create_github_repo
      if options[:github]
        say 'Creating Github repo'
        build :create_github_repo, options[:github]
      end
    end

    def setup_gitignore
      build :gitignore_files
    end

    def init_git
      build :init_git
    end

    def copy_libraries
      say 'Copying libraries'
      build :copy_libraries
    end

    def copy_miscellaneous_files
      say 'Copying miscellaneous support files'
      build :copy_miscellaneous_files
    end

    def customize_error_pages
      say 'Customizing the 500/404/422 pages'
      build :customize_error_pages
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def outro
      say 'Congratulations! You just baked up a project with bakeware.'
      say "Remember to run 'rails generate airbrake' with your API key."
    end

    def run_bundle
      # Let's not: We'll bundle manually at the right spot
    end

    protected

    def get_builder_class
      Bakeware::AppBuilder
    end

    def using_active_record?
      !options[:skip_active_record]
    end
  end
end
