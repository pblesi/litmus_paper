# inlined from sinatra-synchrony
require 'sinatra/base'
require 'rack/fiber_pool'
require 'eventmachine'
require 'em-http-request'
require 'em-synchrony'
require 'em-resolv-replace'

module Sinatra
  module Synchrony
    def self.registered(app)
      app.disable :threaded
    end

    def setup_sessions(builder)
      builder.use Rack::FiberPool, {:rescue_exception => handle_exception } unless test?
      super
    end

    def handle_exception
      Proc.new do |env, e|
        if settings.show_exceptions?
          request = Sinatra::Request.new(env)
          printer = Sinatra::ShowExceptions.new(proc{ raise e })
          s, h, b = printer.call(env)
          [s, h, b]
        else
          LitmusPaper.logger.info(e)
          [500, {}, ""]
        end
      end
    end

    class << self
      def overload_tcpsocket!
        require 'sinatra/synchrony/tcpsocket'
      end
    end
  end
  register Synchrony
end
