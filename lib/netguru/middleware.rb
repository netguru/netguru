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
    #TO DO: better way?
    Rails.application.class.to_s.split("::")[0].downcase
  end

  def secondcoder_response
    %{
      <div id='secondcoder'>
    #{open("http://secondcoder.com/api/netguru/#{application_name}/check").read}
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