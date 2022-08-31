defmodule IFix.Blame.Transformers.AddRelationships do
  use Spark.Dsl.Transformer

  @before_transformers [
    Ash.Resource.Transformers.BelongsToAttribute,
    Ash.Resource.Transformers.RequireUniqueFieldNames
  ]

  alias Spark.Dsl.Transformer

  import IFix.Blame.Info,
    only: [api: 1, actor_resource: 1, actor_attribute: 1, actor_attribute_name: 1, events: 1]

  def before?(transformer) when transformer in @before_transformers, do: true
  def before?(_), do: false

  def transform(dsl) do
    Enum.reduce(events(dsl), {:ok, dsl}, fn event, acc ->
      add_user_relationship(acc, event)
    end)
  end

  defp add_user_relationship({:ok, dsl}, event) do
    with {:ok, user_relationship} <-
           Transformer.build_entity(Ash.Resource.Dsl, [:relationships], :belongs_to,
             name: actor_attribute_name(event),
             api: api(dsl),
             destination: actor_resource(dsl),
             destination_attribute: actor_attribute(dsl),
             required?: false
           ) do
      {:ok, Transformer.add_entity(dsl, [:relationships], user_relationship)}
    end
  end

  defp add_user_relationship({:error, error}, _), do: {:error, error}
end
