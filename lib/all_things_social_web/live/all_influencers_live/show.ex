defmodule AllThingsSocialWeb.AllInfluencersLive.ShowComponent do
  use AllThingsSocialWeb, :live_component
  alias AllThingsSocial.Influencers

  def render(assigns) do
    ~H"""
    <div>
      <div id="myModal" class="modal">
        <div class="modal-content pt-12 ">
          <div class="flex items-center gap-2">
            <%= Heroicons.icon("heart", type: "outline", class: "h-4 text-red-500 w-4") %>
            <p class="text-xl font-semibold">Influencer highlights</p>
          </div>

          <div class="flex justify-between  pt-4  items-start">
            <div class="flex flex-col bg-white overflow-y-scroll h-[400px] shadow-md rounded-xl shadow-gray-400  w-[100%] p-4 gap-4">
              <div class="flex items-center gap-5">
                <%= if @state == "social_media_accounts" do %>
                  <div
                    phx-click="change_state"
                    phx-value-id="social_media_accounts"
                    class="bg-[#887CF2] px-4 py-2 cursor-pointer  text-white rounded-3xl"
                  >
                    Social Media Accounts
                  </div>
                <% else %>
                  <div
                    phx-click="change_state"
                    phx-value-id="social_media_accounts"
                    class="bg-gray-100 px-4 py-2 cursor-pointer  text-black rounded-3xl"
                  >
                    Social Media Accounts
                  </div>
                <% end %>

                <%= if @state == "rates" do %>
                  <div
                    phx-click="change_state"
                    phx-value-id="rates"
                    class="bg-[#887CF2] px-4 py-2 cursor-pointer  text-white rounded-3xl"
                  >
                    Rates
                  </div>
                <% else %>
                  <div
                    phx-click="change_state"
                    phx-value-id="rates"
                    class="bg-gray-100 px-4 py-2 cursor-pointer  text-black rounded-3xl"
                  >
                    Rates
                  </div>
                <% end %>

                <%= if @state == "niches" do %>
                  <div
                    phx-click="change_state"
                    phx-value-id="niches"
                    class="bg-[#887CF2] px-4 py-2 cursor-pointer  text-white rounded-3xl"
                  >
                    Niches
                  </div>
                <% else %>
                  <div
                    phx-click="change_state"
                    phx-value-id="niches"
                    class="bg-gray-100 px-4 py-2 cursor-pointer  text-black rounded-3xl"
                  >
                    Niches
                  </div>
                <% end %>
              </div>
              <%= if @state == "social_media_accounts" do %>
                <div class="w-[100%]   overflow-y-scroll h-[100%] flex flex-col">
                  <div class="border-gray-100 border-b-2 rounded-t-xl bg-gray-100 h-[100%] shadow-gray-300 flex flex-col gap-2  p-4   w-[100%]">
                    <div class="grid grid-cols-2 py-4 gap-8">
                      <%= for social_media_account <- @social_media_accounts do %>
                        <%= if social_media_account.platform == "Instagram" do %>
                          <div class="h-[100px] p-2 hover:scale-105 transition-all ease-in-out duration-500  w-[100%] border-2 flex cursor-pointer justify-between pb-4 group  flex-col gap-2  rounded-xl">
                            <div class="flex gap-2 items-start">
                              <img
                                src="/images/instagramicon.png"
                                class="w-[50px] object-cover  rounded-full h-[50px]"
                              />

                              <div class="flex flex-col gap-1">
                                <p class="text-sm font-bold"><%= social_media_account.platform %></p>

                                <a
                                  href={social_media_account.account_url}
                                  target="_blank"
                                  class="text-xs text-[#595959]"
                                >
                                  View Profile
                                </a>
                              </div>
                            </div>
                          </div>
                        <% else %>
                          <div class="h-[120px] p-2 hover:scale-105 transition-all ease-in-out duration-500  gap-2 w-[100%] border-2 flex cursor-pointer justify-between pb-4 group  flex-col  rounded-xl">
                            <div class="flex gap-2 items-start">
                              <img
                                src="/images/tiktokicon.png"
                                class="w-[50px] object-cover  rounded-full h-[50px]"
                              />

                              <div class="flex flex-col gap-1">
                                <p class="text-sm font-bold"><%= social_media_account.platform %></p>

                                <a
                                  href={social_media_account.account_url}
                                  target="_blank"
                                  class="text-xs text-[#595959]"
                                >
                                  View Profile
                                </a>
                              </div>
                            </div>
                          </div>
                        <% end %>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>

              <%= if @state == "rates" do %>
                <div class="w-[100%]   overflow-y-scroll h-[100%] flex flex-col">
                  <div class="border-gray-100 border-b-2 rounded-t-xl bg-gray-100 h-[100%] shadow-gray-300 flex flex-col gap-2  p-4   w-[100%]">
                    <div class="grid grid-cols-2 py-4 gap-8">
                      <%= for rate <- @rates do %>
                        <div class="h-[150px] p-2 hover:scale-105 transition-all ease-in-out duration-500  gap-2 w-[100%] border-2 flex cursor-pointer justify-between pb-4 group  flex-col  rounded-xl">
                          <div class="flex flex-col gap-1">
                            <div class="flex gap-2 px-4 items-start">
                              <%= Heroicons.icon("calendar",
                                type: "solid",
                                class: "h-6 text-[#887CF2]  w-6"
                              ) %>

                              <p>
                                <%= rate.platform %>
                              </p>
                            </div>

                            <div class="flex gap-2 px-4 items-start">
                              <%= Heroicons.icon("briefcase",
                                type: "solid",
                                class: "h-6 text-[#887CF2]  w-6"
                              ) %>

                              <p>
                                <%= rate.description %>
                              </p>
                            </div>

                            <div class="flex gap-2 px-4 items-start">
                              <%= Heroicons.icon("banknotes",
                                type: "solid",
                                class: "h-6 text-[#887CF2]  w-6"
                              ) %>

                              <p>
                                <%= rate.amount %> KSH
                              </p>
                            </div>
                          </div>
                        </div>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>

              <%= if @state == "niches" do %>
                <div class="w-[100%]   overflow-y-scroll h-[100%] flex flex-col">
                  <div class="border-gray-100 border-b-2 rounded-t-xl bg-gray-100 h-[100%] shadow-gray-300 flex flex-col gap-2  p-4   w-[100%]">
                    <div class="grid grid-cols-2 py-4 gap-8">
                      <%= for niche <- @niches do %>
                        <div class="h-[100px] p-2 hover:scale-105 transition-all ease-in-out duration-500  w-[100%] border-2 flex cursor-pointer justify-between pb-4 group  flex-col  rounded-xl">
                          <div class="flex flex-col gap-1">
                            <div class="flex gap-2 px-4 items-start">
                              <%= Heroicons.icon("briefcase",
                                type: "solid",
                                class: "h-6 text-[#887CF2]  w-6"
                              ) %>

                              <p>
                                <%= niche.name %>
                              </p>
                            </div>
                          </div>
                        </div>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def update(%{influencer_account: influencer_account} = assigns, socket) do
    IO.inspect(socket.assigns)

    {:ok,
     socket
     |> assign(assigns)}
  end
end
