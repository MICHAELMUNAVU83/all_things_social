defmodule AllThingsSocialWeb.AllInfluencersLive.Index do
  use AllThingsSocialWeb, :brand_live_view
  alias AllThingsSocial.Influencers

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
