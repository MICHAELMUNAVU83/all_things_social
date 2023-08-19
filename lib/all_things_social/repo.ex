defmodule AllThingsSocial.Repo do
  use Ecto.Repo,
    otp_app: :all_things_social,
    adapter: Ecto.Adapters.Postgres
end
