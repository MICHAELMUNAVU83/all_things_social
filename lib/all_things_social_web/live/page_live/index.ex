defmodule AllThingsSocialWeb.PageLive.Index do
  use AllThingsSocialWeb, :live_view

  alias AllThingsSocial.Brands
  alias AllThingsSocial.Influencers

  def mount(_params, session, socket) do
    logged_in_brand =
      if is_nil(session["brand_token"]) do
        false
      else
        true
      end

    {:ok,
     socket
     |> assign(:logged_in_brand, logged_in_brand)}
  end
end
