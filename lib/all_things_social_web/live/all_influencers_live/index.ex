defmodule AllThingsSocialWeb.AllInfluencersLive.Index do
  use AllThingsSocialWeb, :brand_live_view
  alias AllThingsSocial.Influencers
  alias AllThingsSocial.Boards

  def mount(_params, _session, socket) do
    influencers = Influencers.list_influencers()
    {:ok, assign(socket, influencers: influencers)}
  end
end
