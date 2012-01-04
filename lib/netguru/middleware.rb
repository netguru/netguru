require 'open-uri'
class Netguru::Middleware
  def initialize(app)
    @app = app
  end
  
  def call(env)
    status, headers, response = @app.call(env)
    [status, headers, [response.body.gsub("</body>", "#{secondcoder_response}</body>")]]
  end

  def application_name
    Rails.application.class.parent_name.downcase
  end

  def secondcoder_response
    response = (timeout(0.5){ open("http://secondcoder.com/api/netguru/#{application_name}/check").read } rescue "To slow to access secondcoder.")
    %{
      <div id='secondcoder'>
      #{response}
      </div>
    #{styles}
    }
   end

  def styles
    %{  
      <style>
      #secondcoder {
        position: fixed;
        top: 10px;
        right: 10px;
        color: #990000;
        background-color: white;
        padding: 2px 5px;
        font-size: 12px;
        border-radius: 5px;
        font-face: "Helvetica Neue",Helvetica,Arial,sans-serif";
        border: 2px solid #990000;
      }
      </style>
    }
  end


end