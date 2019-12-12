defmodule ChirperWeb.UserController do
  use ChirperWeb, :controller

  alias Chirper.Accounts
  alias Chirper.Blog.Post
  alias Chirper.Accounts.User

  def index(conn, params) do
    page = Accounts.list_users(params)

    render(conn, "index.html",
      users: page.entries,
      page: page
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
        |> redirect(to: Routes.page_path(conn, :show))
    {:error, %Ecto.Changeset{} = changeset} ->
      render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    page = Post.feed_page(user.id, 1)
    count = Post.get_posts_page(user, 1).total_entries
    followers = Accounts.followers(user)
    following = Accounts.following(user)

    render(conn, "show.html",
      user: user,
      count: count,
      followers: followers,
      following: following,
      page: page,
      posts: page.entries,
      changeset: Post.change_post(%Post{})
    )
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

end
