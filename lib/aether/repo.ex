defmodule Aether.Repo do
  use Ecto.Repo,
    otp_app: :aether,
    adapter: Ecto.Adapters.Postgres
end
