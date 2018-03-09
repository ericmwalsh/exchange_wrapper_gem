# ExchangeWrapper

**ExchangeWrapper** is a Ruby Gem that attempts to come up with a standardized set of methods that can be used to obtain data from Cryptocurrency exchanges.

Refer to the **Methods** section below for a list of the methods, example usage, and example return format.

If you have any issues or if you'd like to contribute please visit the **Contributing** section below.


## Exchange Progress Table

This table shows the methods that are supported per exchange.


|  Exchange                                   | #holdings | #symbols | #trading_pairs | #prices | #metadata | #backfill | #orders
|  :------:                                   | :-------: | :------: | :------------: | :-----: | :-------: | :-------: | :-----:
|  [Binance](https://www.binance.com/)        |     ✔     |     ✔    |        ✔       |     ✔   |     ✔     |    Hard   |    ?
|  [Bitstamp](https://www.bitstamp.net/)      |     ?     |     ✔    |        ✔       |     ✔   |     ✔     |     ✘     |    ?
|  [Bittrex](https://bittrex.com/)            |     ✔     |     ✔    |        ✔       |     ✔   |     ✔     |    Hard   |    ?
|  [CEX.io](https://cex.io/)                  |     ?     |     ?    |        ?       |     ?   |     ?     |     ?     |    ?
|  [Coinbase](https://www.coinbase.com/)      |     ✔     |     ✘    |        ✘       |     ✘   |     ✘     |     ✘     |    ?
|  [Cryptopia](https://www.cryptopia.co.nz/)  |     ?     |     ✔    |        ✔       |     ✔   |     ✔     |     ✘     |    ?
|  [GDAX](https://www.gdax.com/)              |     ✔     |     ✔    |        ✔       |     ✔   |     ✔     |    Easy   |    ?
|  [Gemini](https://gemini.com/)              |     ✔     |     ✔    |        ✔       |     ✔   |     ✔     |    Easy   |    ?
|  [Kraken](https://www.kraken.com/)          |     ?     |     ✔    |        ✔       |     ✔   |     ✔     |    Easy   |    ?
|  [KuCoin](https://www.kucoin.com/)          |     ?     |     ?    |        ?       |     ?   |     ?     |     ?     |    ?
|  [Poloniex](https://poloniex.com/)          |     ?     |     ?    |        ?       |     ?   |     ?     |     ?     |    ?


### Notes
1. Coinbase doesn't support methods outside of `#holdings` (get the data via GDAX) and even then `#holdings` *should* be converted to utilize OAuth instead of API Key/Secret.
2. `#backfill` isn't implemented yet so it is an estimation (Easy/Hard) of the difficulty needed in order to support it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exchange_wrapper'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install exchange_wrapper


## Methods

### `#holdings(key, secret)`
* ```ruby
    ::ExchangeWrapper::Coinbase::Utils.holdings(key, secret)
  ```
* ```ruby
    {
      'BTC': 4.311689,
      'ETH': 0.877610923,
      'LTC': 25.10899999
    }
  ```
* Symbols cannot be `nil` values and amounts cannot be `0` values (returns only symbols with non-zero amount values)
* Does not account for locked funds
* *GDAX requires a passphrase in addition to a key and secret*

### `#symbols`
* ```ruby
    ::ExchangeWrapper::Bittrex::Utils.symbols
  ```
* ```ruby
    [
      'BTC',
      'ETH',
      'LTC',
      'NANO',
      'TRX'
    ]
  ```
* Alphabetically ordered, no `nil` values returned
* *GDAX requires a key, secret, and passphrase*

### `#trading_pairs`
* ```ruby
    ::ExchangeWrapper::Binance::Utils.trading_pairs
  ```
* ```ruby
    [
      ['ADA/BTC', 'ADA', 'BTC'],
      ['AST/ETH', 'AST', 'ETH'],
      ['ENJ/BTC', 'ENJ', 'BTC'],
      ['NULS/BNB', 'NULS', 'BNB'],
      ['ZIL/ETH', 'ZIL', 'ETH']
    ]
  ```
* Alphabetically ordered by trading pair, no `nil` values returned
* *GDAX requires a key, secret, and passphrase*

### `#prices`
* ```ruby
    ::ExchangeWrapper::Bittrex::Utils.prices
  ```
* ```ruby
    [
      {"symbol":"BCH/BTC","price":"0.11030000"},
      {"symbol":"EVX/BTC","price":"0.00018065"},
      {"symbol":"QSP/BNB","price":"0.02124000"},
      {"symbol":"SUB/ETH","price":"0.00053616"}
    ]
  ```
* Symbol and price must be non `nil` values returned
* *GDAX requires a yield_md param and a key, secret, and passphrase*

### `#metadata`
* ```ruby
    ::ExchangeWrapper::Binance::Utils.metadata
  ```
* ```ruby
    [
      {"symbol":"BCH/BTC",...},
      {"symbol":"BTC/USD",...},
      {"symbol":"ETH/EUR",...},
      {"symbol":"ETH/USD",...},
      {"symbol":"LTC/BTC",...}
    ]
  ```
* Symbol must be non `nil`, all other values are subject to the API
* This data structure is **NOT** uniform between APIs/across exchanges
* This may be split into a sub-method for capturing `volume` in the future
* *GDAX requires a key, secret, and passphrase*

### `#backfill`
* *coming soon*
* Might be impossible for... Bitstamp and Cryptopia

### `#orders`
* *coming soon*


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ChalupaIO/exchange_wrapper. *Please fork the gem, make your changes in your fork, then create a PR to this repo.*

If you'd like to contact me about something I am reachable at eric@chalupa.io.


## Development

* After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

* To install this gem onto your local machine, run `bundle exec rake install`.

* *(Admin only)* To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
