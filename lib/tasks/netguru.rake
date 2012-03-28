namespace :netguru do
  namespace :install do
    desc 'install pre-commit hook for current git project to prevent commiting invalid files or binding.pry'
    task :"pre-commit-hook" do
      require 'open-uri'

      gist_url = "https://raw.github.com/gist/2225907/8cfa3c60928153522717090c76be10ef97388485/pre-commit-hook"
      puts "Fetching script from #{gist_url}"
      script = open(gist_url).read

      hooks_dir = "#{Dir.pwd}/.git/hooks/"

      if File.exist?(hooks_dir + "pre-commit")
        puts "File pre-commit already exists, make a backup?"
        answer = ""
        until ['yes', 'no'].include?(answer)
          puts "'yes' or 'no'? "
          answer = STDIN.gets.chomp
        end
        if answer == "yes"
          puts "Executing: cp \"#{hooks_dir}pre-commit\" \"#{hooks_dir}pre-commit-#{Time.now.to_s}\""
          system("cp \"#{hooks_dir}pre-commit\" \"#{hooks_dir}pre-commit-#{Time.now.to_s}\"")
        end
      end
      f = File.open(hooks_dir + "pre-commit", "w")
      f.write(script)
      f.flush
      f.close
      system("chmod +x #{hooks_dir}pre-commit")
      puts "Script sucessfully installed"
    end
  end
end