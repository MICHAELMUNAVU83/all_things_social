defmodule AllThingsSocialWeb.MyInfluencersLive.Show do
  use AllThingsSocialWeb, :brand_live_view
  alias AllThingsSocial.InfluencerAccounts
  alias AllThingsSocial.Brands
  alias AllThingsSocial.Chats
  alias AllThingsSocial.Chats.Chat
  alias AllThingsSocial.Tasks
  alias AllThingsSocial.Tasks.Task
  alias AllThingsSocial.SocialMediaAccounts
  alias AllThingsSocial.Rates
  alias AllThingsSocial.Niches
  alias AllThingsSocial.Payments
  alias AllThingsSocial.Mpesas

  def mount(_params, session, socket) do
    logged_in_brand = Brands.get_brand_by_session_token(session["brand_token"])

    IO.inspect(logged_in_brand)

    {:ok,
     socket
     |> assign(:logged_in_brand, logged_in_brand)}
  end

  @impl true
  def handle_params(params, _, socket) do
    id = params["id"]

    influencer_account = InfluencerAccounts.get_influencer_account!(id)

    correct_brand =
      if socket.assigns.logged_in_brand.id == influencer_account.brand_id do
        true
      else
        false
      end

    chats =
      Chats.list_chats_for_a_brand_and_influencer(
        socket.assigns.logged_in_brand.id,
        influencer_account.influencer_id
      )

    tasks =
      Tasks.list_tasks_for_a_brand_and_influencer(
        socket.assigns.logged_in_brand.id,
        influencer_account.influencer_id
      )

    task =
      if params["task_id"] != nil do
        Tasks.get_task!(params["task_id"])
      else
        %Task{}
      end

    content_board_id = influencer_account.content_board_id
    influencer_id = influencer_account.influencer_id
    brand_id = influencer_account.brand_id

    social_media_accounts =
      SocialMediaAccounts.list_social_media_accounts()
      |> Enum.filter(fn social_media_account ->
        social_media_account.influencer_id == influencer_id
      end)

    rates =
      Rates.list_rates()
      |> Enum.filter(fn rate ->
        rate.influencer_id == influencer_id
      end)

    niches =
      Niches.list_niches()
      |> Enum.filter(fn niche ->
        niche.influencer_id == influencer_id
      end)

    payments =
      Payments.list_payments()
      |> Enum.filter(fn payment ->
        payment.brand_id == socket.assigns.logged_in_brand.id and
          payment.influencer_id == influencer_id
      end)

    {:noreply,
     socket
     |> assign(:influencer_account, InfluencerAccounts.get_influencer_account!(id))
     |> assign(:changeset, Chats.change_chat(%Chat{}))
     |> assign(:chats, chats)
     |> assign(:social_media_accounts, social_media_accounts)
     |> assign(:rates, rates)
     |> assign(:niches, niches)
     |> assign(:tasks, tasks)
     |> assign(:payments, payments)
     |> assign(:page_title, "New Task")
     |> assign(:content_board_id, content_board_id)
     |> assign(:influencer_id, influencer_id)
     |> assign(:state, "social_media_accounts")
     |> assign(:error_modal, false)
     |> assign(:n, false)
     |> assign(:success_modal, false)
     |> assign(:error_message, "")
     |> assign(:brand_id, brand_id)
     |> assign(:task, task)
     |> assign(:correct_brand, correct_brand)}
  end

  def handle_event("save", %{"chat" => chat_params}, socket) do
    changeset = Chats.change_chat(%Chat{})

    brand_id = socket.assigns.logged_in_brand.id
    influencer_id = socket.assigns.influencer_account.influencer_id
    content_board_id = socket.assigns.influencer_account.content_board_id

    new_chat_params =
      Map.put(chat_params, "brand_id", brand_id)
      |> Map.put("influencer_id", influencer_id)
      |> Map.put("content_board_id", content_board_id)
      |> Map.put("sender", "brand")

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

  def handle_event("approve", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.update_task(task, %{status: "approved"})

    tasks =
      Tasks.list_tasks_for_a_brand_and_influencer(
        socket.assigns.logged_in_brand.id,
        socket.assigns.influencer_account.influencer_id
      )

    {:noreply,
     socket
     |> assign(:tasks, tasks)}
  end

  def handle_event("delete_task", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    tasks =
      Tasks.list_tasks_for_a_brand_and_influencer(
        socket.assigns.logged_in_brand.id,
        socket.assigns.influencer_account.influencer_id
      )

    {:noreply,
     socket
     |> assign(:tasks, tasks)}
  end

  def handle_event("change_state", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:state, id)}
  end

  def handle_event("pay", %{"id" => id}, socket) do
    case Mpesas.make_request(
           1,
           socket.assigns.logged_in_brand.phone_number,
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
    {:ok, brand} = Brands.update_brand(socket.assigns.logged_in_brand, %{"role" => "premium"})

    socket
    |> assign(:success_modal, true)
    |> assign(:logged_in_brand, brand)
    |> put_flash(:info, "Succesfully Paid")
  end

  def factorial(socket, n, string, id) when n == "error" do
    socket
    |> assign(:error_message, string)
    |> assign(:error_modal, true)
    |> put_flash(:info, string)
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
end
