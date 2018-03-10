# ::Exceptions
module Exceptions
  BAD_REQUEST = 400
  RATE_LIMIT = 429
  API_INPUT = 400
  API_ERROR = 500
  API_STATUS_UNKNOWN = 504

  class BaseError < StandardError
    attr_reader :status
    #
    def initialize(message = 'Bad Request', status = BAD_REQUEST) # string, integer
      @status = status
      super(message)
    end

    private

    # {"code"=>-2014, "msg"=>"API-key format invalid."}
    def binance_error_message(error_hash) # hash
      "Binance Error // Code #{error_hash['code']}: #{error_hash['msg']}"
    end

    # {"success"=>false, "message"=>"APIKEY_INVALID", "result"=>nil}
    def bittrex_error_message(response_hash) # hash
      "Bittrex Error // Message: #{response_hash['message']}"
    end

    # #<Coinbase::Wallet::AuthenticationError: invalid signature>
    def coinbase_error_message(error_object) # error_object
      "Coinbase Error // #{error_object.class.to_s}: #{error_object.message}"
    end

    # {"code"=>3,"message"=>"Error: invalid request"}
    def gateio_error_message(response_hash) # hash
      "Gate.io Error // Code: #{response_hash['code']}, Message: #{response_hash['message']}"
    end

    # #<Coinbase::Exchange::NotAuthorizedError: invalid signature>
    def gdax_error_message(error_object) # error_object
      "GDAX Error // #{error_object.class.to_s}: #{error_object.message}"
    end

    # {
    #   "result":"error",
    #   "reason":"Bad Request",
    #   "message":"Supplied value 'btcusdz' is not a valid symbol.  Please correct your API request to use one of the supported symbols: [btcusd, ethbtc, ethusd]"
    # }
    def gemini_error_message(response_hash)
      "Gemini Error // #{response_hash['reason']}: #{response_hash['message']}"
    end

    # {"error":["EQuery:Unknown asset pair"]}
    def kraken_error_message(response_hash)
      "Kraken Error // Message: #{response_hash['error'].join(', ')}"
    end

  end

  class InvalidInputError < BaseError
    def initialize(message = 'Invalid input; check your API credentials', status = API_INPUT) # string, integer
      super(message, status)
    end
  end

  class OutdatedError < BaseError
    def initialize(message = 'Outdated trick; API needs to be re-examined', status = API_ERROR) # string, integer
      super(message, status)
    end
  end

  # 3rd party API exceptions/errors
  # base errors, 4 of them
  # input / rate_limit / server / unknown
  class ApiInputError < BaseError
    def initialize(message = 'API Input Invalid', status = API_INPUT) # string, integer
      super(message, status)
    end
  end

  class ApiRateLimitError < BaseError
    def initialize(message = 'API Rate Limit Reached', status = RATE_LIMIT) # string, integer
      super(message, status)
    end
  end

  class ApiServerError < BaseError
    def initialize(message = 'API Server Error', status = API_ERROR) # string, integer
      super(message, status)
    end
  end

  class ApiUnknownError < BaseError
    def initialize(message = 'API Response Status Unknown', status = API_STATUS_UNKNOWN) # string, integer
      super(message, status)
    end
  end

  # input errors

  # binance
  class BinanceApiInputError < ApiInputError
    def initialize(error_hash, error_code = API_INPUT) # hash, integer
      super(binance_error_message(error_hash), error_code)
    end
  end

  # bittrex
  class BittrexApiInputError < ApiInputError
    def initialize(error_hash, error_code = API_INPUT) # hash, integer
      super(bittrex_error_message(error_hash), error_code)
    end
  end

  # coinbase
  class CoinbaseApiInputError < ApiInputError
    def initialize(error_object) # error_object
      super(coinbase_error_message(error_object))
    end
  end

  # gateio
  class GateioApiInputError < ApiInputError
    def initialize(error_hash, error_code = API_INPUT) # hash, integer
      super(gateio_error_message(error_hash), error_code)
    end
  end

  # gdax
  class GdaxApiInputError < ApiInputError
    def initialize(error_object) # error_object
      super(gdax_error_message(error_object))
    end
  end

  # gemini
  class GeminiApiInputError < ApiInputError
    def initialize(error_hash, error_code = API_INPUT) # hash, integer
      super(gemini_error_message(error_hash), error_code)
    end
  end

  # kraken
  class KrakenApiInputError < ApiInputError
    def initialize(error_hash, error_code = API_INPUT) # hash, integer
      super(kraken_error_message(error_hash), error_code)
    end
  end

  # rate limit errors

  # binance
  class BinanceApiRateLimitError < ApiRateLimitError
    def initialize(error_hash, error_code = RATE_LIMIT)  # hash, integer
      super(binance_error_message(error_hash), error_code)
    end
  end

  # bittrex
  class BittrexApiRateLimitError < ApiRateLimitError
    def initialize(error_hash, error_code = RATE_LIMIT)  # hash, integer
      super(bittrex_error_message(error_hash), error_code)
    end
  end

  # coinbase
  class CoinbaseApiRateLimitError < ApiRateLimitError
    def initialize(error_object) # error_object
      super(coinbase_error_message(error_object))
    end
  end

  # gateio
  class GateioApiRateLimitError < ApiRateLimitError
    def initialize(error_hash, error_code = RATE_LIMIT)  # hash, integer
      super(gateio_error_message(error_hash), error_code)
    end
  end

  # gdax
  class GdaxApiRateLimitError < ApiRateLimitError
    def initialize(error_object) # error_object
      super(gdax_error_message(error_object))
    end
  end

  # gemini
  class GeminiApiRateLimitError < ApiRateLimitError
    def initialize(error_hash, error_code = RATE_LIMIT)  # hash, integer
      super(gemini_error_message(error_hash), error_code)
    end
  end

  # kraken
  class KrakenApiRateLimitError < ApiRateLimitError
    def initialize(error_hash, error_code = RATE_LIMIT)  # hash, integer
      super(kraken_error_message(error_hash), error_code)
    end
  end

  # api server errors

  # binance
  class BinanceApiServerError < ApiServerError
    def initialize(error_hash, error_code = API_ERROR) # hash, integer
      super(binance_error_message(error_hash), error_code)
    end
  end

  # bittrex
  class BittrexApiServerError < ApiServerError
    def initialize(error_hash, error_code = API_ERROR) # hash, integer
      super(bittrex_error_message(error_hash), error_code)
    end
  end

  # coinbase
  class CoinbaseApiServerError < ApiServerError
    def initialize(error_object) # error_object
      super(coinbase_error_message(error_object))
    end
  end

  # gateio
  class GateioApiServerError < ApiServerError
    def initialize(error_hash, error_code = API_ERROR) # hash, integer
      super(gateio_error_message(error_hash), error_code)
    end
  end

  # gdax
  class GdaxApiServerError < ApiServerError
    def initialize(error_object) # error_object
      super(gdax_error_message(error_object))
    end
  end

  # gemini
  class GeminiApiServerError < ApiServerError
    def initialize(error_hash, error_code = API_ERROR) # hash, integer
      super(gemini_error_message(error_hash), error_code)
    end
  end

  # kraken
  class KrakenApiServerError < ApiServerError
    def initialize(error_hash, error_code = API_ERROR) # hash, integer
      super(kraken_error_message(error_hash), error_code)
    end
  end

  # status unknown errors

  # binance
  class BinanceApiUnknownError < ApiUnknownError
    def initialize(error_hash, error_code = API_STATUS_UNKNOWN) # hash, integer
      super(binance_error_message(error_hash), error_code)
    end
  end

end
