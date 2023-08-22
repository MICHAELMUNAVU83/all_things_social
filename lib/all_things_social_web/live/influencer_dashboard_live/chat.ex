defmodule AllThingsSocialWeb.InfluencerDashboardLive.ChatComponent do
  use AllThingsSocialWeb, :live_component
  alias AllThingsSocial.Influencers

  def render(assigns) do
    ~H"""
    <div>
      <div id="myModal" class="modal">
        <div class="modal-content pt-12 ">
          <div class="w-[100%]   overflow-hidden h-[70vh] flex flex-col">
            <div class="border-gray-200 border-b-2 rounded-t-xl bg-gray-100 shadow-gray-300 flex justify-between items-center  p-4   w-[100%]">
              <div class="flex gap-2 items-center">
                <div class=" w-[40px] bg-[#887CF2] rounded-full h-[40px]  "></div>
                <p class="text-[#887CF2] text-sm poppins-regular">
                  <%= @brand.email %>
                </p>
              </div>

              <div class="flex text-white items-center gap-2"></div>
            </div>
            <div class="bg-gray-100 h-[80%] flex flex-col-reverse overflow-y-scroll  md:p-4 p-2  w-[100%]">
              <div class="flex flex-col w-[100%]   gap-2">
                <%= for chat <- @chats do %>
                  <%= if chat.sender == "brand" do %>
                    <div class="flex  justify-start   ">
                      <p class="   p-2 md:h-[70px] text-xs bg-white text-black w-[200px]">
                        <%= chat.message %>
                      </p>
                    </div>
                  <% else %>
                    <div class="flex  justify-end   ">
                      <p class="  text-white p-2 md:h-[70px] text-xs bg-[#887CF2] w-[200px]">
                        <%= chat.message %>
                      </p>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>

            <div class="bg-gray-100 rounded-b-xl border-gray-200 border-t-2  pb-8  p-4   w-[100%]">
              <.form let={f} for={@changeset} id="message-form" phx-submit="save">
                <div class="flex justify-between  w-[100%] items-center">
                  <div class="md:w-[85%] w-[75%] text-[#A8B1CF] ">
                    <%= text_input(f, :message,
                      class:
                        "w-[100%] md:h-[90%] h-[50%]  border border-transparent text-[#A8B1CF]  focus:ring-0 border-none  p-4 bg-white shadow-gray-300 shadow-md",
                      placeholder: "Enter message..."
                    ) %>
                  </div>

                  <div class="p-2 flex justify-center items-center hover:scale-105 transition-all duration-500 ease-in-out rounded-md bg-[#7269EF] ">
                    <%= submit do %>
                      <%= Heroicons.icon("paper-airplane",
                        type: "solid",
                        class: "h-6 text-white w-6"
                      ) %>
                    <% end %>
                  </div>
                </div>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def update(%{chat: chat} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
