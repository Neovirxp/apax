defmodule Apax do
  alias Apax.ItemSearch
  alias Apax.ItemLookup
  alias Apax.BrowseNodeLookup

  def item_search(keywords) do
    ItemSearch.search_product(keywords)
  end

  def item_lookup(asin) do
    ItemLookup.find_product(asin)
  end

  def best_sellers(index, node) do
    BrowseNodeLookup.browse_node(index, node)
  end
end

