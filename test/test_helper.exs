ExUnit.start()

try do
  Ecto.Adapters.SQL.Sandbox.mode(Ether.Repo, :manual)
rescue
  _ -> :ok
end
