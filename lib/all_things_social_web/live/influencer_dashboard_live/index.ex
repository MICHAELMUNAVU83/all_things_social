defmodule AllThingsSocialWeb.InfluencerDashboardLive.Index do
  use AllThingsSocialWeb, :live_view
  alias AllThingsSocial.Influencers
  alias AllThingsSocial.Brands
  alias AllThingsSocial.Brands.Brand
  alias AllThingsSocial.SocialMediaAccounts
  alias AllThingsSocial.SocialMediaAccounts.SocialMediaAccount
  alias AllThingsSocial.Rates
  alias AllThingsSocial.Rates.Rate
  alias AllThingsSocial.Niches
  alias AllThingsSocial.Niches.Niche
  alias AllThingsSocial.Tasks
  alias AllThingsSocial.InfluencerAccounts
  alias AllThingsSocial.InfluencerAccounts.InfluencerAccount
  alias AllThingsSocial.Chats
  alias AllThingsSocial.Chats.Chat
  alias AllThingsSocial.Mpesas
  alias AllThingsSocial.Payments

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

    influencer_accounts =
      InfluencerAccounts.list_influencer_accounts()
      |> Enum.filter(fn influencer_account ->
        influencer_account.influencer_id == logged_in_influencer.id
      end)

    payments =
      Payments.list_payments()
      |> Enum.filter(fn payment ->
        payment.influencer_id == logged_in_influencer.id
      end)

    {:ok,
     socket
     |> assign(:tasks, tasks)
     |> assign(:state, "tasks")
     |> assign(:influencer_accounts, influencer_accounts)
     |> assign(:rates, rates)
     |> assign(:niches, niches)
     |> assign(:n, false)
     |> assign(:payments, payments)
     |> assign(:success_modal, false)
     |> assign(:error_message, "")
     |> assign(:error_modal, false)
     |> assign(:social_media_accounts, social_media_accounts)
     |> assign(:logged_in_influencer, logged_in_influencer)}
  end

  def handle_event("pay", %{"id" => id}, socket) do
    IO.inspect(id)

    case Mpesas.make_request(
           1,
           "254740769596",
           "reference",
           "description"
         ) do
      {:error, %HTTPoison.Error{reason: :timeout, id: nil}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Session timed out")}

      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:info, "An error occured #{error}")}

      {:ok, mpesa} ->
        {:noreply,
         socket
         |> assign(:checkoutId, mpesa["CheckoutRequestID"])
         |> factorial(socket.assigns.n, "Initiated", id)}

      _ ->
        {:noreply, socket}
    end
  end

  def factorial(socket, n, string, id) when n == false do
    case IO.inspect(Mpesas.make_query(socket.assigns.checkoutId)) do
      {:ok, mpesa} ->
        case mpesa["ResultCode"] do
          "0" ->
            factorial(socket, true, "Paid", id)

          "1" ->
            socket
            |> factorial("error", "Balance is insufficient", id)

          "17" ->
            socket
            |> factorial("error", "Check if you entered details correctly", id)

          "26" ->
            socket
            |> factorial("error", "System busy, Try again in a short while", id)

          "2001" ->
            socket
            |> factorial("error", "Wrong Pin entered", id)

          "1001" ->
            socket
            |> factorial("error", "Unable to lock subscriber", id)

          "1019" ->
            socket
            |> factorial("error", "Transaction expired. No MO has been received", id)

          "9999" ->
            socket
            |> factorial("error", "Request cancelled by user", id)

          "1032" ->
            factorial(socket, "error", "Request cancelled by user", id)

          "1036" ->
            socket
            |> factorial("error", "SMSC ACK timeout", id)

          "1037" ->
            socket
            |> factorial("error", "Payment timeout", id)

          "SFC_IC0003" ->
            socket
            |> factorial("error", "Payment timeout", id)

          _ ->
            socket
            |> put_flash("error", "Error processing payment ")
        end

      {:error, params} ->
        IO.inspect("i am here")

        factorial(socket, false, "Payment has started", id)
    end
  end

  def factorial(socket, n, string, id) when n == true do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.update_task(task, %{status: "paid"})

    payment_params = %{
      "brand_id" => task.brand_id,
      "influencer_id" => task.influencer_id,
      "task_id" => task.id,
      "content_board_id" => task.content_board_id,
      "price" => task.price,
      "status" => "received"
    }

    {:ok, _} = Payments.create_payment(payment_params)

    tasks =
      Tasks.list_tasks()
      |> Enum.filter(fn task -> task.influencer_id == socket.assigns.logged_in_influencer.id end)

    socket
    |> assign(:success_modal, true)
    |> assign(:tasks, tasks)
    |> put_flash(:info, "Succesfully Paid")
  end

  def factorial(socket, n, string, id) when n == "error" do
    socket
    |> assign(:error_message, string)
    |> assign(:error_modal, true)
    |> put_flash(:info, string)
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

    influencer_account =
      if params["influencer_account"] do
        InfluencerAccounts.get_influencer_account!(params["influencer_account"])
      else
        %InfluencerAccount{}
      end

    brand =
      if influencer_account != %InfluencerAccount{} do
        Brands.get_brand!(influencer_account.brand_id)
      else
        %Brand{}
      end

    chats =
      if influencer_account != %InfluencerAccount{} do
        Chats.list_chats_for_a_brand_and_influencer(
          influencer_account.brand_id,
          influencer_account.influencer_id
        )
      else
        []
      end

    IO.inspect(InfluencerAccounts.list_influencer_accounts())

    {:noreply,
     socket
     |> assign(:social_media_account, social_media_account)
     |> assign(:rate, rate)
     |> assign(:niche, niche)
     |> assign(:chat, %Chat{})
     |> assign(:brand, brand)
     |> assign(:influencer_account, influencer_account)
     |> assign(:chats, chats)
     |> assign(:changeset, Chats.change_chat(%Chat{}))
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

  def handle_event("save", %{"chat" => chat_params}, socket) do
    changeset = Chats.change_chat(%Chat{})

    brand_id = socket.assigns.brand.id
    influencer_id = socket.assigns.logged_in_influencer.id
    content_board_id = socket.assigns.influencer_account.content_board_id

    new_chat_params =
      Map.put(chat_params, "brand_id", brand_id)
      |> Map.put("influencer_id", influencer_id)
      |> Map.put("content_board_id", content_board_id)
      |> Map.put("sender", "influencer")

    if new_chat_params["message"] != "" do
      case Chats.create_chat(new_chat_params) do
        {:ok, _chat} ->
          {:noreply,
           socket
           |> assign(:chats, Chats.list_chats_for_a_brand_and_influencer(brand_id, influencer_id))
           |> assign(:changeset, changeset)}
      end
    else
      {:noreply,
       socket
       |> put_flash(:info, "Message cannot be empty")}
    end
  end

  def handle_event("close_success_modal", %{}, socket) do
    {:noreply,
     socket
     |> assign(:success_modal, false)}
  end

  def handle_event("close_error_modal", %{}, socket) do
    {:noreply,
     socket
     |> assign(:error_modal, false)}
  end

  defp page_title(:add_social_media_account), do: "Add Social media account"

  defp page_title(:edit_social_media_account), do: "Edit Social media account"
  defp page_title(:index), do: "Index"
  defp page_title(:add_rate), do: "Add Rate"
  defp page_title(:edit_rate), do: "Edit Rate"
  defp page_title(:add_niche), do: "Add Niche"
  defp page_title(:edit_niche), do: "Edit Niche"
  defp page_title(:chat), do: "Chat"
end
