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
    IO.inspect(params)

    logged_in_influencer =
      Influencers.get_influencer_by_session_token(session["influencer_token"])

    tasks =
      Tasks.list_tasks()
      |> Enum.filter(fn task -> task.influencer_id == logged_in_influencer.id end)

    social_media_accounts =
      SocialMediaAccounts.list_social_media_accounts()
      |> Enum.filter(fn social_media_account ->
        social_media_account.influencer_id == logged_in_influencer.id
      end)

    rates =
      Rates.list_rates()
      |> Enum.filter(fn rate ->
        rate.influencer_id == logged_in_influencer.id
      end)

    niches =
      Niches.list_niches()
      |> Enum.filter(fn niche ->
        niche.influencer_id == logged_in_influencer.id
      end)

    {:ok,
     socket
     |> assign(:tasks, tasks)
     |> assign(:state, "social_media_accounts")
     |> assign(:rates, rates)
     |> assign(:niches, niches)
     |> assign(:social_media_accounts, social_media_accounts)
     |> assign(:logged_in_influencer, logged_in_influencer)}
  end

  def handle_params(params, _url, socket) do
    niche =
      if params["niche_id"] do
        Niches.get_niche!(params["niche_id"])
      else
        %Niche{}
      end

    social_media_account =
      if params["social_media_account_id"] do
        SocialMediaAccounts.get_social_media_account!(params["social_media_account_id"])
      else
        %SocialMediaAccount{}
      end

    rate =
      if params["rate_id"] do
        Rates.get_rate!(params["rate_id"])
      else
        %Rate{}
      end

    {:noreply,
     socket
     |> assign(:social_media_account, social_media_account)
     |> assign(:rate, rate)
     |> assign(:niche, niche)
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

  def handle_event("delete_niche", %{"id" => id}, socket) do
    niche = Niches.get_niche!(id)
    {:ok, _} = Niches.delete_niche(niche)

    niches =
      Niches.list_niches()
      |> Enum.filter(fn niche ->
        niche.influencer_id == socket.assigns.logged_in_influencer.id
      end)

    {:noreply,
     socket
     |> assign(:niches, niches)}
  end

  def handle_event("delete_rate", %{"id" => id}, socket) do
    rate = Rates.get_rate!(id)
    {:ok, _} = Rates.delete_rate(rate)

    rates =
      Rates.list_rates()
      |> Enum.filter(fn rate ->
        rate.influencer_id == socket.assigns.logged_in_influencer.id
      end)

    {:noreply,
     socket
     |> assign(:rates, rates)}
  end

  def handle_event("delete_social_media_account", %{"id" => id}, socket) do
    social_media_account = SocialMediaAccounts.get_social_media_account!(id)
    {:ok, _} = SocialMediaAccounts.delete_social_media_account(social_media_account)

    social_media_accounts =
      SocialMediaAccounts.list_social_media_accounts()
      |> Enum.filter(fn social_media_account ->
        social_media_account.influencer_id == socket.assigns.logged_in_influencer.id
      end)

    {:noreply,
     socket
     |> assign(:social_media_accounts, social_media_accounts)}
  end

  defp page_title(:add_social_media_account), do: "Add Social media account"

  defp page_title(:edit_social_media_account), do: "Edit Social media account"
  defp page_title(:index), do: "Index"
  defp page_title(:add_rate), do: "Add Rate"
  defp page_title(:edit_rate), do: "Edit Rate"
  defp page_title(:add_niche), do: "Add Niche"
  defp page_title(:edit_niche), do: "Edit Niche"
end
