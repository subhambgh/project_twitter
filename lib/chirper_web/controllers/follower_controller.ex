defmodule ChirperWeb.FollowerController do
  use ChirperWeb, :controller

  alias Chirper.Accounts
  alias Chirper.Blog.Post

  def followers(conn, %{"user_id" => user_id}) do
    title = "Followers"
    render_page(conn, title, user_id)
  end

  def following(conn, %{"user_id" => user_id}) do
    title = "Following"
    render_page(conn, title, user_id)
  end

  defp render_page(conn, title, id) do
    user = Accounts.get_user(id)
    count = Post.get_posts_page(user, 1).total_entries
    followers = Accounts.followers(user)
    following = Accounts.following(user)

    conn
    |> put_view(ChirperWeb.UserView)
    |> render("show_follow.html",
      user: user,
      count: count,
      title: title,
      followers: followers,
      following: following
    )
  end
end