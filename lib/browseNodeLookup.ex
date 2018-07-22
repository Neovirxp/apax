defmodule Apax.BrowseNodeLookup do
  import SweetXml
  alias Process

  alias Apax.Utils
  alias Apax.ItemLookup

  @protocol "http://"
  @host "webservices.amazon.com.mx"
  @path "/onca/xml"
  @base_url @protocol <> @host <> @path

  def browse_node(index, node) do
    html = api_call(index, node)
    products = html.body
    |> xpath(~x"//ItemSearchResponse/Items/Item"l,
         asin: ~x"./ASIN/text()" |> transform_by(&to_string/1),
         link: ~x"./DetailPageURL/text()" |> transform_by(&to_string/1))

    for product <- products do
      ItemLookup.find_product(product.asin)
      |> Map.merge(product)
    end
  end

  def api_call(index, node, page \\ 1) do
    HTTPoison.start
    HTTPoison.get! generate_query(index, node, page)
  end

  def generate_query(index, node, page) do
    params_string = Utils.combine_params(generate_params(index, node, page))
    signature = Utils.sign_request(Enum.join([
          "GET",
          @host,
          @path,
          params_string
        ], "\n"))

    encoded_signature = Utils.encode_signature(signature)

    full_url =
      @base_url
      <> "?"
      <> params_string
      <> "&Signature="
      <> encoded_signature
  end

  def generate_params(index, node, page) do
    %{
      "AWSAccessKeyId" => System.get_env("AWS_KEY"),
      "AssociateTag" => System.get_env("AWS_ASSOCIATE"),
      "BrowseNode" => node,
      "Condition" => "New",
      "Operation" => "ItemSearch",
      "SearchIndex" => index,
      "Service" => "AWSECommerceService",
      "Sort" => "popularityrank",
      # "ItemPage" => to_string(page),
      "Timestamp" => Apax.Utils.generate_timestamp,
      "Version" => "2013-08-01"
    }
  end
end
