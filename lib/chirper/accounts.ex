defmodule Chirper.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Chirper.Repo

  alias Chirper.Accounts.User
  alias Chirper.Blog.Post
  alias Chirper.Accounts.Relationship

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    User
    |>Repo.all()
    |> Repo.preload(:posts)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(posts: [:user])
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def get_by_username(username) when is_nil(username) do
    nil
  end
  def get_by_username(username) do
    User
    |> Repo.get_by(username: username)
    |> Repo.preload(:posts)
  end

  def followers(user) do
    list = user |> Repo.preload(:followers)
    list.followers
  end

  def following(user) do
    list = user |> Repo.preload(:following)
    list.following
  end

  def follow(current_user, other_user) do
    %Relationship{}
    |> Relationship.changeset(%{follower_id: other_user.id, followed_id: current_user.id})
    |> Repo.insert()
  end

  def following?(current_user, other_user) do
    Enum.member?(following(current_user), other_user)
  end

  def unfollow(current_user, other_user) do
    Repo.get_by!(Relationship, follower_id: current_user.id, followed_id: other_user.id)
    |> Repo.delete()
  end

  def following_ids(user_id) do
    query =
      from r in Relationship,
        where: r.follower_id == ^user_id,
        select: r.followed_id

    Repo.all(query)
  end
end
