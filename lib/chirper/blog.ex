defmodule Chirper.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Chirper.Repo
  alias Chirper.Accounts
  alias Chirper.Blog.Post
  alias Chirper.Accounts.User

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Post
    |> order_by(desc: :id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Post
    |> Repo.get(id)
    |> Repo.preload(:user)
  end

  def get_posts_page(user, page) do
    Post
    |> where([p], p.user_id == ^user.id)
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(page: page)
  end
  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%User{} = user, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end


  def feed(user_id) do
    following_ids = Accounts.following_ids(user_id)

    query =
      from p in Post,
        where: p.user_id in ^following_ids or p.user_id == ^user_id,
        order_by: [desc: p.inserted_at],
        preload: [:user]

    Repo.all(query)
  end

  def getPostByUserId(user_id) do
    query =
      from p in Post,
        where: p.user_id == ^user_id,
        order_by: [desc: p.inserted_at],
        preload: [:user]

    Repo.all(query)
  end
end
