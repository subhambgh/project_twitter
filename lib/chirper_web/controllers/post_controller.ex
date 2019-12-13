defmodule ChirperWeb.PostController do
  use ChirperWeb, :controller

  alias Chirper.Blog
  alias Chirper.Accounts
  alias Chirper.Blog.Post

  def index(conn, _params) do
    posts = Blog.feed(conn.assigns.current_user.id)
    changeset = Blog.change_post(%Post{})
    user = Accounts.get_user!(conn.assigns.current_user.id)
    followers = Accounts.followers(user)
    following = Accounts.following(user)
    render(conn, "index.html",
      posts: posts,
      changeset: changeset,
      user: user,
      followers: followers,
      following: following
      )
  end

  def retweet(conn, %{"post_id" => post_id}) do
    posts = Blog.feed(conn.assigns.current_user.id)
    post_params = Blog.get_post!(post_id)
    changeset = Blog.change_post(%Post{title: post_params.title<>" #retweet ",body: post_params.body<>" #retweet "})
    user = Accounts.get_user!(conn.assigns.current_user.id)
    followers = Accounts.followers(user)
    following = Accounts.following(user)
    render(conn, "index.html",
      posts: posts,
      changeset: changeset,
      user: user,
      followers: followers,
      following: following
      )
  end

  def create(conn, %{"post" => post_params}) do
    case Blog.create_post(conn.assigns.current_user, post_params) do
      {:ok, post} ->
        post = %{post | user: Chirper.Accounts.get_username!(post.user_id)}
        {your_post, _} = Map.split(post, Post.fields)
        ChirperWeb.UserChannel.broadcast_tweet(conn.assigns.current_user,your_post)
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html", changeset: changeset)
    end
  end

end
