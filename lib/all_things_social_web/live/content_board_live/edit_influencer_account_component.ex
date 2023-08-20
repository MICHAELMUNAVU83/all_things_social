defmodule AllThingsSocialWeb.ContentBoardLive.EditInfluencerAccountComponent do
  use AllThingsSocialWeb, :live_component
  alias AllThingsSocial.InfluencerAccounts

  def render(assigns) do
    ~H"""
    <div>
      <div id="myModal" class="modal">
        <div class="modal-content pt-12 ">
          <div class="flex items-center gap-2">
            <%= Heroicons.icon("heart", type: "outline", class: "h-4 text-red-500 w-4") %>
            <p class="text-xl font-semibold">Influencer highlights</p>
          </div>

          <.form
            let={f}
            for={@changeset}
            id="influencer_account-form"
            phx-target={@myself}
            phx-submit="save"
          >
            <div class="flex gap-2 w-[80%] mx-auto flex-col">
              <div class="flex gap-2 flex-col w-[100%]">
                <%= select(f, :column, ["Potential", "Outreached", "Negotiating", "Active"],
                  prompt: "Select Column",
                  class:
                    "w-[100%] h-[60px] border-2 my-2 border-gray-300 rounded-xl px-4 py-2 focus:outline-none focus:ring-2 focus:ring-purple-600 focus:border-transparent"
                ) %>
                <p class="pt-5">
                  <%= error_tag(f, :column) %>
                </p>
              </div>

              <div class="flex justify-end">
                <%= submit("Save",
                  phx_disable_with: "Saving...",
                  class:
                    "bg-[#887CF2] cursor-pointer hover:scale-105 transition-all ease-in-out duration-500 px-8 py-2 text-xl  flex justify-center items-center gap-2 text-white rounded-xl"
                ) %>
              </div>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("save", %{"influencer_account" => influencer_account_params}, socket) do
    save_influencer_account(socket, socket.assigns.action, influencer_account_params)
  end

  defp save_influencer_account(socket, :editinfluenceraccount, influencer_account_params) do
    case InfluencerAccounts.update_influencer_account(
           socket.assigns.influencer_account,
           influencer_account_params
         ) do
      {:ok, _influencer_account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Influencer account updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
