defmodule AllThingsSocialWeb.MyInfluencersLive.Show do
  use AllThingsSocialWeb, :brand_live_view
  alias AllThingsSocial.InfluencerAccounts
  alias AllThingsSocial.Brands
  alias AllThingsSocial.Chats
  alias AllThingsSocial.Chats.Chat
  alias AllThingsSocial.Tasks
  alias AllThingsSocial.Tasks.Task

  def mount(_params, session, socket) do
    logged_in_brand = Brands.get_brand_by_session_token(session["brand_token"])

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

    {:noreply,
     socket
     |> assign(:influencer_account, InfluencerAccounts.get_influencer_account!(id))
     |> assign(:changeset, Chats.change_chat(%Chat{}))
     |> assign(:chats, chats)
     |> assign(:tasks, tasks)
     |> assign(:page_title, "New Task")
     |> assign(:content_board_id, content_board_id)
     |> assign(:influencer_id, influencer_id)
     |> assign(:state, "tasks")
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
end
