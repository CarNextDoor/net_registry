# NetRegistry
[![Build
Status](https://travis-ci.org/CarNextDoor/net_registry.svg?branch=master)](https://travis-ci.org/CarNextDoor/net_registry)
[![Gem Version](https://badge.fury.io/rb/net_registry.svg)](http://badge.fury.io/rb/net_registry)

This gem serves as a Ruby wrapper for the NetRegistry Payment Gateway's
API. Official documentation can be found [http://www.netregistry.com.au/ee-images/uploads/support/NR-ecom-gateway8.pdf](here)

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'net_registry'
```

And then execute:

``` BASH
$ bundle
```

Or install it yourself as:

``` BASH
$ gem install net_registry
```

## Quick start

``` ruby
client   = NetRegistry::Client.new(merchant_id: 1234, password: 1234)
response = client.purchase(AMOUNT: 100, CCNUM: "111111111111", CCEXP: "10/15")
```

## Usage

This gem currently support "purchase", "refund", "status", "preauth",
and each of these methods take a `hash` parameter. The required keys
are specified in the following:

#### Purchase

Input:

``` ruby
{
  AMOUNT: "(Integer, Float, or String). The amount you would like to
  charge. Don't add "$", just the numerical amount.",

  CCNUM: "(Integer, String). The credit card number. NO SPACES OR
  DASH",

  CCEXP: "(String). Credit card expiry date. Must be in the format of
  "mm/yy"."
}
```

Returns: NetRegistry::Response object.

#### Refund

Input:
``` ruby
{
  AMOUNT: "(Integer, Float, or String). The amount you would like to
  charge. Don't add "$", just the numerical amount.",

  TXNREF: "(String). Transaction reference number"
}
```

Returns: NetRegistry::Response object.

#### Preauth

Input:

``` ruby
{
  AMOUNT: "(Integer, Float, or String). The amount you would like to
  charge. Don't add "$", just the numerical amount.",

  CCNUM: "(Integer, String). The credit card number. NO SPACES OR
  DASH",

  CCEXP: "(String). Credit card expiry date. Must be in the format of
  \"mm/yy\"".
}
```

Returns: NetRegistry::Response object.

#### Status

Input:
``` ruby
{
  TXNREF: "(String). Transaction reference number"
}
```

Returns: NetRegistry::Response object.

## Contributing

1. Fork it ( https://github.com/carnextdoor/net_registry/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
