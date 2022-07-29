defmodule IFix.Blame.Transformers.AddRelationships do
  use Ash.Dsl.Transformer

  @before_transformers [
    Ash.Resource.Transformers.BelongsToAttribute,
    Ash.Resource.Transformers.RequireUniqueFieldNames
  ]

  alias Ash.Dsl.Transformer

  import IFix.Blame,
    only: [api: 1, actor_resource: 1, actor_field: 1, actor_field_name: 1, events: 1]

  def before?(transformer) when transformer in @before_transformers, do: true
  def before?(_), do: false

  def transform(resource, dsl) do
    Enum.reduce(events(resource), {:ok, dsl}, fn event, acc ->
      add_user_relationship(acc, resource, event)
    end)
  end

  defp add_user_relationship({:ok, dsl}, resource, event) do
    with {:ok, user_relationship} <-
           Transformer.build_entity(Ash.Resource.Dsl, [:relationships], :belongs_to,
             name: actor_field_name(event),
             api: api(resource),
             destination: actor_resource(resource),
             destination_field: actor_field(resource),
             required?: false
           ) do
      {:ok, Transformer.add_entity(dsl, [:relationships], user_relationship)}
    end
  end

  defp add_user_relationship({:error, error}, _, _), do: {:error, error}
end
