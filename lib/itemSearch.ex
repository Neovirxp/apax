defmodule Apax.ItemSearch do
  import SweetXml
  alias Process

  alias Apax.Utils
  alias Apax.ItemLookup

  @protocol "http://"
  @host "webservices.amazon.com.mx"
  @path "/onca/xml"
  @base_url @protocol <> @host <> @path

  def find_position(asin, keywords, max_pages \\ 10, wait_call \\ 1100, page \\ 1, position \\ 0) do
    if(page <= max_pages) do
      unless(page == 1) do
        Process.sleep(wait_call)
      end

      html = api_call(keywords, page)
      asins = html.body
      |> xpath(~x"//ItemSearchResponse/Items/Item"l,
           asin: ~x"./ASIN/text()" |> transform_by(&to_string/1))

      found = Enum.find_index(asins, fn(x) -> to_string(x.asin) == asin end)

      if(found == nil) do
        position = page * 10
        page = page + 1
        find_position(asin, keywords, max_pages, wait_call, page, position)
      else
        position = ((page - 1) * 10) + found + 1
      end
    else
      ">100"
    end
  end

  def search_product(keyword) do
    html = api_call(keyword)
    products = html.body
    |> xpath(~x"//ItemSearchResponse/Items/Item"l,
         asin: ~x"./ASIN/text()" |> transform_by(&to_string/1),
         link: ~x"./DetailPageURL/text()" |> transform_by(&to_string/1))

    for product <- products do
      ItemLookup.find_product(product.asin)
      |> Map.merge(product)
    end
  end

  def api_call(keywords, page \\ 1) do
    HTTPoison.start
    HTTPoison.get! generate_query(keywords, page)
  end

  def generate_query(keywords, page) do
    params_string = Utils.combine_params(generate_params(keywords, page))
    signature = Utils.sign_request(Enum.join([
          "GET",
          @host,
          @path,
          params_string
        ], "\n"))

    encoded_signature = Utils.encode_signature(signature)

    full_url = @base_url <> "?" <> params_string <> "&Signature=" <> encoded_signature
  end

  def generate_params(keywords, page) do
    %{
      "AWSAccessKeyId" => System.get_env("AWS_KEY"),
      "AssociateTag" => System.get_env("AWS_ASSOCIATE"),
      "Condition" => "New",
      "Keywords" => keywords,
      "Operation" => "ItemSearch",
      "SearchIndex" => "All",
      "Service" => "AWSECommerceService",
      # "Sort" => "popularityrank",
      # "ItemPage" => to_string(page),
      "Timestamp" => Apax.Utils.generate_timestamp,
      "Version" => "2013-08-01"
    }
  end
end
