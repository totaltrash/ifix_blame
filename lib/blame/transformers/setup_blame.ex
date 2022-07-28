defmodule IFix.Blame.Transformers.SetupBlame do
  use Ash.Dsl.Transformer

  @before_transformers [
    Ash.Resource.Transformers.BelongsToAttribute
  ]

  alias Ash.Dsl.Transformer
  import IFix.Blame, only: [api: 1, actor: 1]

  def before?(transformer) when transformer in @before_transformers, do: true
  def before?(_), do: false

  def transform(resource, dsl) do
    with {:ok, dsl} <- add_created_user(dsl, resource),
         {:ok, dsl} <- add_created_date(dsl),
         {:ok, dsl} <- add_updated_user(dsl, resource),
         {:ok, dsl} <- add_updated_date(dsl) do
      {:ok, dsl}
    end
  end

  defp add_created_user(dsl, resource) do
    with {:ok, created_user} <-
           Transformer.build_entity(Ash.Resource.Dsl, [:relationships], :belongs_to,
             name: :created_user,
             api: api(resource),
             destination: actor(resource),
             required?: false
           ) do
      {:ok, Transformer.add_entity(dsl, [:relationships], created_user)}
    end
  end

  defp add_updated_user(dsl, resource) do
    with {:ok, updated_user} <-
           Transformer.build_entity(Ash.Resource.Dsl, [:relationships], :belongs_to,
             name: :updated_user,
             api: api(resource),
             destination: actor(resource),
             required?: false
           ) do
      {:ok, Transformer.add_entity(dsl, [:relationships], updated_user)}
    end
  end

  defp add_created_date(dsl) do
    with {:ok, created_date} <-
           Transformer.build_entity(Ash.Resource.Dsl, [:attributes], :attribute,
             allow_nil?: true,
             constraints: [],
             default: &DateTime.utc_now/0,
             match_other_defaults?: true,
             name: :created_date,
             private?: true,
             type: Ash.Type.UtcDatetimeUsec,
             update_default: nil,
             writable?: false
           ) do
      {:ok, Transformer.add_entity(dsl, [:attributes], created_date)}
    end
  end

  defp add_updated_date(dsl) do
    with {:ok, updated_date} <-
           Transformer.build_entity(Ash.Resource.Dsl, [:attributes], :attribute,
             allow_nil?: true,
             constraints: [],
             default: &DateTime.utc_now/0,
             match_other_defaults?: true,
             name: :updated_date,
             private?: true,
             type: Ash.Type.UtcDatetimeUsec,
             update_default: &DateTime.utc_now/0,
             writable?: false
           ) do
      {:ok, Transformer.add_entity(dsl, [:attributes], updated_date)}
    end
  end
end
