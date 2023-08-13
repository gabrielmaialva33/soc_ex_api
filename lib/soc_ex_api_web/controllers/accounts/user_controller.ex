defmodule SocExApiWeb.UserController do
  use SocExApiWeb, :controller

  alias SocExApi.Accounts
  alias SocExApi.Accounts.User

  action_fallback SocExApiWeb.FallbackController

  @paging_opts ~w(page page_size search order_by order_directions)

  defp parse_order_by(opts) do
    if Map.has_key?(opts, :order_by) do
      opts
      |> Map.update!(:order_by, &parse_order(&1))
    else
      opts
    end
  end

  defp parse_order_directions(opts) do
    if Map.has_key?(opts, :order_directions) do
      opts
      |> Map.update!(:order_directions, &parse_order(&1))
    else
      opts
    end
  end

  defp parse_order(order) do
    order
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_atom/1)
  end

  def paginate(conn, params) do
    flop_opts =
      params
      |> Map.take(@paging_opts)
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Enum.into(%{})
      |> parse_order_by
      |> parse_order_directions

    with {:ok, flop} <- Flop.validate(flop_opts),
         {:ok, {users, meta}} <- Accounts.paginate_users(flop) do
      render(conn, :paginate, users: users, meta: meta)
    end
  end

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
