defmodule Apax.ItemLookup do
  import SweetXml
  alias Apax.Utils

  @protocol "http://"
  @host "webservices.amazon.com.mx"
  @path "/onca/xml"
  @base_url @protocol <> @host <> @path

  def find_product(asin) do
    html = api_call(asin)

    html.body
    |> xpath(~x"//ItemLookupResponse/Items/Item",
         title: ~x"./ItemAttributes/Title/text()" |> transform_by(&to_string/1),
         image: ~x"./LargeImage/URL/text()" |> transform_by(&to_string/1))
  end

  def api_call(asin) do
    HTTPoison.start
    html = HTTPoison.get! generate_query(asin)
  end

  def generate_query(asin) do
    params_string = Utils.combine_params(generate_params(asin))

    signature = Utils.sign_request(Enum.join([
          "GET",
          @host,
          @path,
          params_string
        ], "\n"))

    encoded_signature = Utils.encode_signature(signature)

    full_url = @base_url <> "?" <> params_string <> "&Signature=" <> encoded_signature

  end

  def generate_params(asin) do
    %{
      "AWSAccessKeyId" => System.get_env("AWS_KEY"),
      "AssociateTag" => System.get_env("AWS_ASSOCIATE"),
      "ItemId" => asin,
      "Operation" => "ItemLookup",
      "ResponseGroup" => "Medium",
      "Service" => "AWSECommerceService",
      "Timestamp" => Apax.Utils.generate_timestamp,
      "Version" => "2013-08-01"
    }

  end
end
