module Netguru
  class RemoteLogger

    def initialize(application, stage)
      @application = application
      @stage = stage
      @counter = 0
    end

    def puts(message)

      data = {
        stage: @stage,
        message: message,
        project_id: @application
      }

      if @external_id
        data.merge!('_method' => 'put')
        Thread.new{ Netguru::Api.post("/external_deployments/#{@external_id}", payload: data.to_json) }
      else
        @external_id = Netguru::Api.post('/external_deployments', payload: data.to_json)
      end

      $stderr.puts message
    end

    def method_missing(method_name, *args)
      $stderr.send method_name, *args
    end
  end

end
