defmodule IFix.Blame.Transformers.AddTimestamps do
  use Spark.Dsl.Transformer

  @before_transformers [
    Ash.Resource.Transformers.RequireUniqueFieldNames
  ]

  alias Spark.Dsl.Transformer
  import IFix.Blame.Info, only: [events: 1, timestamp_attribute_name: 1]

  def before?(transformer) when transformer in @before_transformers, do: true
  def before?(_), do: false

  def transform(dsl) do
    Enum.reduce(events(dsl), {:ok, dsl}, fn event, acc ->
      add_event_timestamp(acc, event)
    end)
  end

  defp add_event_timestamp({:ok, dsl}, event) do
    with {:ok, event_date_entity} <-
           Transformer.build_entity(Ash.Resource.Dsl, [:attributes], :attribute,
             name: timestamp_attribute_name(event),
             type: Ash.Type.UtcDatetimeUsec,
             allow_nil?: true,
             constraints: [],
             default: nil,
             update_default: nil,
             private?: true,
             writable?: false
           ) do
      {:ok, Transformer.add_entity(dsl, [:attributes], event_date_entity)}
    end
  end

  defp add_event_timestamp({:error, error}, _), do: {:error, error}
end
