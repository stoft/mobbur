defmodule Mobbur.RoomChannel do
  use Phoenix.Channel
  alias Mobbur.Presence

  def join("room:lobby", _message, socket) do
    send self(), :after_join
    {:ok, socket}
  end

  def join("room:" <> team_id, _params, socket) do
    #  {:error, %{reason: "unauthorized"}}
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.user, %{
      online_at: System.system_time(:milliseconds),
      team_name: "Inglorious Anonymous"
      })
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end

  def handle_in("update", params, socket) do
    # IO.puts "---------------"
    # IO.inspect params
    user = socket.assigns.user
    %{^user => presence} = Presence.fetch "room:lobby", Presence.list(socket)
    Presence.update(socket, socket.assigns.user, %{
      team_name: params
      })
    push socket, "presence_state", Presence.list(socket)

    {:noreply, socket}
  end

  def handle_in("team_state", params, socket) do
    IO.puts "----------"
    IO.inspect params
    broadcast! socket, "team_state", params
    {:noreply, socket}
  end

  # def handle_in("new_msg", %{"body" => body}, socket) do
  #     broadcast! socket, "new_msg", %{body: body}
  #     {:noreply, socket}
  # end
  #
  # def handle_out("new_msg", payload, socket) do
  #     push socket, "new_msg", payload
  #     {:noreply, socket}
  # end

end
