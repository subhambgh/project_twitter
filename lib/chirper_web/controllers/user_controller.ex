defmodule ChirperWeb.UserController do
  use ChirperWeb, :controller

  alias Chirper.Accounts
  alias Chirper.Accounts.User
  alias Chirper.Blog
  alias Chirper.Blog.Post

  def index(conn, params) do
    users = Accounts.list_users()
    render(conn, "index.html",
      users: users
    )
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "Signed up successfully.")
        |> redirect(to: Routes.post_path(conn, :index))
    {:error, %Ecto.Changeset{} = changeset} ->
      render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    posts = Blog.feed(id)
    followers = Accounts.followers(user)
    following = Accounts.following(user)

    render(conn, "show.html",
      posts: posts,
      user: user,
      count: 0,
      followers: followers,
      following: following)
  end

end
