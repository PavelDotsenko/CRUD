defmodule Test.RepoOfdb do
  use Ecto.Repo,
    otp_app: :crud,
    adapter: Ecto.Adapters.Postgres
end
