# Apax

Amazon Product Advertising Client for Elixir

## Installation

Add `apax` to your list of dependencies in `mix.exs`:

```elixir
  def deps do
    [{:apax, "~> 0.1.0"}]
  end
```

## Config

Add these 3 environment variables to you system:

AWS_LOCALE
AWS_ASSOCIATE
AWS_KEY
AWS_SECRET

## Usage

### ItemSearch 

Find a product by keywords
```elixir
  Apax.item_search("keywords")
```
### ItemLookup

Only returns title and image:
```elixir
  Apax.item_lookup(asin)
```
