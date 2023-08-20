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
            <div class="flex flex-col h-[400px] bg-white p-4 shadow-md rounded-xl shadow-gray-400 w-[35%] gap-4">
              <div class="flex gap-2 items-center">
                <div class="w-[50px] h-[50px] rounded-full bg-[#887CF2]"></div>
                <div class="flex flex-col">
                  <p class="text-sm font-bold">Michael Munavu</p>
                  <p class="text-xs text-[#595959]">michaelmunavu</p>
                </div>
              </div>
              <div class="flex justify-between w-[100%] p-2 rounded-md font-bold bg-[#F3F6F9] text-black">
                <div class="flex gap-2 items-center">
                  <%= Heroicons.icon("heart", type: "outline", class: "h-4 text-red-500 w-4") %>
                  <p class="text-[#595959]">Followers</p>
                </div>
                <p>200</p>
              </div>
            </div>

            <div class="flex flex-col bg-white  h-[400px] shadow-md rounded-xl shadow-gray-400  w-[50%] gap-4">
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
