defmodule Apax do
  alias Apax.ItemSearch
  alias Apax.ItemLookup

  def item_search(keywords) do
    ItemSearch.search_product(keywords)
  end

  def item_lookup(asin) do
    ItemLookup.find_product(asin)
  end
end
