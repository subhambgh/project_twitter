defmodule Chirper.Blog.Post do
@fields ~w(body updated_at title user id)a

  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string 
    field :title, :string
    # field :user_id, :id
    belongs_to :user, Chirper.Accounts.User, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> unique_constraint(:user_id)
  end
  
  def fields, do: @fields
end
