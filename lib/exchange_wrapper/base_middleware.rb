module ExchangeWrapper
  # Public: Instruments requests using Active Support.
  #
  # Measures time spent only for synchronous requests.
  #
  # Examples
  #
  #   ActiveSupport::Notifications.subscribe('request.faraday') do |name, starts, ends, _, env|
  #     url = env[:url]
  #     http_method = env[:method].to_s.upcase
  #     duration = ends - starts
  #     $stderr.puts '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
  #   end
  class BaseMiddleware < Faraday::Middleware

    def call(env)
      raise ::NotImplementedError, 'implement this in your subclass'
    end

    # Internal: Append key-value pair to REST query string
    #
    # query - The String of the existing request query url.
    #
    # key   - The String that represents the param type.
    #
    # value - The String that represents the param value.
    def add_query_param(query, key, value)
      query = query.to_s
      query << '&' unless query.empty?
      query << "#{Faraday::Utils.escape key}=#{Faraday::Utils.escape value}"
    end

  end
end
