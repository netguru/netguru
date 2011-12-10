# Defines netguru custom task to deploy project.

Capistrano::Configuration.instance(:must_exist).load do

  set(:ng_conf) { fetch(:netguru_use) || [:secondcoder, :notify_airbrake] }  

  #check secondcoder
  before "deploy:update_code" do
    if ng_conf.include?(:secondcoder)
      standup_response = open("http://secondcoder.com/api/netguru/#{application}/check").read
      raise "Computer says no!\n#{standup_response}" unless standup_response == "OK"
    end
  end


  after "deploy:restart" do
    if ng_conf.include?(:notify_airbrake)
      run "cd #{current_path} && #{runner} rake airbrake:deploy TO=#{stage} REVISION=#{current_revision} REPO=#{repository}"
    end
  end

end
