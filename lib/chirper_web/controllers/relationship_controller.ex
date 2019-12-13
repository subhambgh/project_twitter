defmodule ChirperWeb.RelationshipController do
  use ChirperWeb, :controller

  alias Chirper.Accounts

  def follow(conn, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)
    Accounts.follow(user, conn.assigns.current_user)

    conn
    |> put_flash(:info, "User followed.")
    |> put_view(ChirperWeb.UserView)
    |> redirect(to: Routes.user_path(conn, :show, user))
  end

  def unfollow(conn, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)
    Accounts.unfollow(conn.assigns.current_user, user)

    conn
    |> put_flash(:info, "User unfollowed.")
    |> put_view(ChirperWeb.UserView)
    |> redirect(to: Routes.user_path(conn, :show, user))
  end
end