class Netguru::PeekGenerator < Rails::Generators::Base
  require 'peek'

  source_root File.expand_path('../templates', __FILE__)
  desc "This generator installs peek into your project"

  def install
    install_basics
    install_gemfile
    install_assets
    puts "Peek magic by the fastest weasel."
    puts "You need to verify your Gemfile, uncomment necessary options in peek initializer and run bundle install."
    puts "Restart your app and enjoy!"
  end

  private

    def install_assets

      js_manifest = 'app/assets/javascripts/application.coffee'

      if File.exist?(js_manifest)
        insert_into_file js_manifest, "#= require netguru\n", :after => "jquery_ujs\n"
      else
        puts "application.coffe is missing"
        puts "add 'require netguru' manually"
      end

      css_manifest = 'app/assets/stylesheets/application.scss'

      if File.exist?(css_manifest)
        content = File.read(css_manifest)
        if content.match(/netguru\s+\.\s*$/)
          # Good enough
        else
          style_require_block = "*= require netguru\n"
          insert_into_file css_manifest, style_require_block, :after => "require_self\n"
        end
      else
        puts "application.scss is missing"
        puts "add 'require netguru' manually"
      end

    end

    def install_basics
      template 'peek.rb.erb', 'config/initializers/peek.rb'
      template '_netguru_bar.haml', 'app/views/application/_netguru_bar.haml'
      template '_netguru_results.haml', 'app/views/application/_netguru_results.haml'
      template '_netguru_performance.haml', 'app/views/application/_netguru_performance.haml'
      template 'netguru.scss', 'app/assets/stylesheets/netguru.scss'
      template 'netguru.coffee', 'app/assets/javascripts/netguru.coffee'
      puts "You have to add 'netguru_bar' partial after %body statement in application layout"
      puts "and 'netguru_results' in footer section of your layout"
    end

    def install_gemfile
      gemfile = 'Gemfile'
      content = File.read(gemfile)
      unless content.match(/peek-performance_bar\s+\.\s*$/)
        puts "Adding group development to your Gemfile."
        open('gemfile', 'a') { |f|
          f << "group :development do\n"
          f << "  gem 'peek'\n"
          f << "  gem 'peek-git'\n"
          f << "  gem 'peek-performance_bar'\n"
          f << "  gem 'peek-gc'\n"
          f << "  #gem 'peek-mysql2' ['peek-mongo', 'peek-pg'] - choose right one\n"
          f << "  #gem 'peek-redis'\n"
          f << "  #gem 'peek-dalli'\n"
          f << "  #gem 'peek-rescque'\n"
          f << "end\n"
        }
      end
    end
    
end

