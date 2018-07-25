defmodule Todo.Database do
  use Supervisor
  @pool_size 3

  def start_link(db_folder) do
    IO.puts("Starting Database server...")
    Supervisor.start_link(__MODULE__, db_folder, name: __MODULE__)
  end

  def init(db_folder) do
    File.mkdir_p!(db_folder)
    children = Enum.map(1..@pool_size, &(worker_spec(db_folder, &1)))
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp worker_spec(db_folder, worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def store(key, data) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
