class Netguru::PeekGenerator < Rails::Generators::Base
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

      js_manifest = 'app/assets/javascripts/applications.coffee'

      if File.exist?(js_manifest)
        insert_into_file js_manifest, "#= require peek\n", :after => "jquery_ujs\n"
      end

      css_manifest = 'app/assets/stylesheets/application.scss'

      if File.exist?(css_manifest)
        content = File.read(css_manifest)
        if content.match(/require_tree\s+\.\s*$/)
          # Good enough - that'll includeto peek styles
        else
          style_require_block = " *= require peek\n"
          insert_into_file css_manifest, style_require_block, :after => "require_self\n"
        end
      end

    end

    def install_basics
      template 'peek.rb.erb', 'config/initializers/peek.rb'
    end

    def install_gemfile
      gemfile = 'Gemfile'
      puts "Adding group development to your Gemfile."
      #insert_into_file gemfile, "#= require peek\n", :after => "jquery_ujs\n"
      open('gemfile', 'w') { |f|
        f << "group :development do\n"
        f << "  #gem 'peek-mysql2' ['peek-mongo', 'peek-pg'] - choose right one\n"
        f << "  #gem 'peek-redis'\n"
        f << "  #gem 'peek-dalli'\n"
        f << "  #gem 'peek-rescque'\n"
        f << "end\n"
      }
    end
    
end

