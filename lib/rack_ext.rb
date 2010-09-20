module Rack
  class Request
    def accept
      @env['HTTP_ACCEPT'].to_s.split(',').map { |a| a.strip }
    end
  end
end