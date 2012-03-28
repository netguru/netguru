def exe(command)
  puts "Executing: #{command}"
  system command
end

def backup_current(hooks_dir)
  exe("cp \"#{hooks_dir}pre-commit\" \"#{hooks_dir}pre-commit-backup-#{Time.now.to_s}\"")
end

namespace :netguru do
  namespace :install do
    desc 'install pre-commit hook for current git project to prevent commiting invalid files or binding.pry'
    task :precommit do
      require 'open-uri'

      gist_url = "https://raw.github.com/gist/2225907/pre-commit-hook"
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
          backup_current(hooks_dir)
        end
      end
      puts "Writing to file #{hooks_dir + "pre-commit"}"
      f = File.open(hooks_dir + "pre-commit", "w")
      f.write(script)
      f.flush
      f.close
      exe("chmod +x #{hooks_dir}pre-commit")
      puts "Script sucessfully installed"
    end
  end

  namespace :uninstall do
    desc 'uninstalls pre-commit hook from current git project (backuping this file and restoring last backup)'
    task :precommit do
      hooks_dir = "#{Dir.pwd}/.git/hooks/"

      ## check if pre-commit hook has the script
      if File.exist?(hooks_dir + "pre-commit") 
        hook = IO.read(hooks_dir + "pre-commit")
        unless hook.include?("## START PRECOMMIT HOOK") && hook.include?("## END PRECOMMIT HOOK")
          puts "Nothing to uninstall, exiting"
        else
          file_to_restore = Dir[hooks_dir + "pre-commit-backup*"].sort.first
          if file_to_restore.nil?
            puts "There is no last backup file! Will only backup & remove current pre-commit hook file"
          end

          puts "Backuping current pre-commit hook..."
          backup_current(hooks_dir)
          puts "Removing current file"
          exe("rm #{hooks_dir}pre-commit")
          if file_to_restore
            exe("mv \"#{file_to_restore}\" \"#{hooks_dir}pre-commit\"")
            exe("chmod +x #{hooks_dir}pre-commit")
          end
          puts "Script was uninstalled"
        end
      else
        puts "File #{hooks_dir + "pre-commit"} was not found, cancelling uninstallation"
      end
    end
  end
end