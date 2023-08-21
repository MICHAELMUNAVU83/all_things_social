defmodule AllThingsSocialWeb.InfluencerDashboardLive.Index do
  use AllThingsSocialWeb, :live_view
  alias AllThingsSocial.Influencers
  alias AllThingsSocial.SocialMediaAccounts
  alias AllThingsSocial.SocialMediaAccounts.SocialMediaAccount
  alias AllThingsSocial.Rates
  alias AllThingsSocial.Rates.Rate
  alias AllThingsSocial.Niches
  alias AllThingsSocial.Niches.Niche
  alias AllThingsSocial.Tasks

  def mount(params, session, socket) do
    logged_in_influencer =
      Influencers.get_influencer_by_session_token(session["influencer_token"])

    tasks =
      Tasks.list_tasks()
      |> Enum.filter(fn task -> task.influencer_id == logged_in_influencer.id end)

    {:ok,
     socket
     |> assign(:social_media_account, %SocialMediaAccount{})
     |> assign(:rate, %Rate{})
     |> assign(:niche, %Niche{})
     |> assign(:tasks, tasks)
     |> assign(:state, "tasks")
     |> assign(:logged_in_influencer, logged_in_influencer)}
  end

  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))}
  end

  def handle_event("change_state", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:state, id)}
  end

  def handle_event("accept", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.update_task(task, %{status: "accepted"})

    tasks =
      Tasks.list_tasks()
      |> Enum.filter(fn task -> task.influencer_id == socket.assigns.logged_in_influencer.id end)

    {:noreply,
     socket
     |> assign(:tasks, tasks)}
  end

  def handle_event("ask_for_review", %{"id" => id, "value" => value}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.update_task(task, %{status: "in_review"})

    tasks =
      Tasks.list_tasks()
      |> Enum.filter(fn task -> task.influencer_id == socket.assigns.logged_in_influencer.id end)

    {:noreply,
     socket
     |> assign(:tasks, tasks)}
  end

  defp page_title(:add_social_media_account), do: "Add Social media account"
  defp page_title(:index), do: "Index"
  defp page_title(:add_rate), do: "Add Rate"
  defp page_title(:add_niche), do: "Add Niche"
end
