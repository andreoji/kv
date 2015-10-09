defmodule KV.Registry do
  use GenServer
  ##The Client and Server run in separate processes
  ##with the client passing messages back and forth
  ##to the server as functions are called

  ##Client API
  def start_link(opts \\[]) do
    :gen_server.start_link(__MODULE__, :ok, opts)
  end
  def lookup(server, name) do
    :gen_server.call server, {:lookup, name}
  end
  def create(server, name) do
    :gen_server.cast server, {:create, name}
  end
  def stop(server) do
    :gen_server.call server, :stop
  end
  ## Server callbacks
  def init(:ok) do
    {:ok, HashDict.new}
  end
  def handle_call({:lookup, name}, _from, names) do
    {:reply, HashDict.fetch(names, name), names}
  end
  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end
  def handle_cast({:create, name}, names) do
    if HashDict.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = KV.Bucket.start_link()
      {:noreply, HashDict.put(names, name, bucket)}
    end
  end
end
