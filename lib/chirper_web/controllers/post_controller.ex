defmodule ChirperWeb.PostController do
  use ChirperWeb, :controller

  alias Chirper.Blog
  alias Chirper.Accounts
  alias Chirper.Blog.Post

  def index(conn, _params) do
    posts = Blog.feed(conn.assigns.current_user.id)
    hashregex = ~r/\#\w*/
    tags = Enum.map Blog.list_posts(), fn x-> 
      List.flatten(Regex.scan(hashregex, x.body))
    end
    {_,hashTagMap} = List.flatten(tags)
      |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
      |> Map.pop("#retweet")
    changeset = Blog.change_post(%Post{})
    user = Accounts.get_user!(conn.assigns.current_user.id)
    followers = Accounts.followers(user)
    following = Accounts.following(user)
    render(conn, "index.html",
      posts: posts,
      changeset: changeset,
      user: user,
      followers: followers,
      following: following,
      hashTagMap: hashTagMap
      )
  end

  def retweet(conn, %{"post_id" => post_id}) do
    posts = Blog.feed(conn.assigns.current_user.id)
    hashregex = ~r/\#\w*/
    tags = Enum.map Blog.list_posts(), fn x-> 
      List.flatten(Regex.scan(hashregex, x.body))
    end
    {_,hashTagMap} = List.flatten(tags)
      |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
      |> Map.pop("#retweet")
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
      following: following,
      hashTagMap: hashTagMap
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

  def search(conn, params) do
    hashregex = ~r/\#\w*/
    search_term = get_in(params, ["query"])
    posts = Enum.map Blog.list_posts(), fn x->
      body = x.body
      title = x.title
      if search_term == nil || search_term == "" 
        || Enum.member?(List.flatten(Regex.scan(hashregex,body)),search_term)
        || Enum.member?(List.flatten(Regex.scan(hashregex,title)),search_term)  do
        x
      else
        []
      end
    end
    posts =List.flatten(posts)
    render(conn, "search.html", posts: posts)
  end

end
