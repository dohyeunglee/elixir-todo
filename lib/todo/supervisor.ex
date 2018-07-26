defmodule Todo.Supervisor do
  def init(_) do
    children = [
      {Todo.Database, ["./persist/"]},
      Todo.Cache
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_link() do
    Supervisor.start_link(__MODULE__, nil)
  end
end
