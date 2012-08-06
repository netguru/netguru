namespace :mongo_backup do
  desc "Run a backup and save locally"
  task :default do
    system("backup perform --trigger mongo_backup --data-path db/mongodumps/ --log-path log/ --tmp-path tmp/ --config-file config/backup.rb")
  end
end

