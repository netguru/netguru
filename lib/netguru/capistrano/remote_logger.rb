module Netguru
  module Capistrano
    class RemoteLogger

      def initialize(application, stage)
        @application = application
        @stage = stage
        @counter = 0
        @messages = {}
      end

      def puts(message)
        @counter += 1
        enqueue_message @counter, message
        flush_messages if (@counter % 10 == 0)
        $stderr.puts message
      end

      def enqueue_message(line_nr, message)
        @messages[line_nr] = message
      end

      def data
        data = {
          stage: @stage,
          messages: @messages,
          project_id: @application
        }
        data.merge!(state: 'running') unless @external_id
        data
      end

      def flush_messages
        payload = data.to_json
        if @external_id
          Thread.new{ Netguru::Api.post("external_deployments/#{@external_id}", _method: :put, payload: payload) }
        else
          @external_id = Netguru::Api.post('external_deployments', payload: payload)
        end
        @messages = {}
      end

      def finish
        payload = data.to_json
        if @external_id
          Netguru::Api.post("external_deployments/#{@external_id}", _method: :put, payload: payload)
        else
          @external_id = Netguru::Api.post('external_deployments', payload: payload)
        end
        @messages = {}
      end

      def log_success
        payload = { state: 'finished' }.to_json
        Netguru::Api.post("external_deployments/#{@external_id}", _method: :put, payload: payload)
      end

      def log_failure
        payload = { state: 'failed' }.to_json
        Netguru::Api.post("external_deployments/#{@external_id}", _method: :put, payload: payload)
      end

      def method_missing(method_name, *args)
        $stderr.send method_name, *args
      end
    end

  end
end
