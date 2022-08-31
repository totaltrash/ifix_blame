defmodule IFix.Blame.Transformers.AddChanges do
  use Spark.Dsl.Transformer

  alias Spark.Dsl.Transformer
  import IFix.Blame.Info, only: [events: 1, actor_attribute_name: 1, timestamp_attribute_name: 1]

  def after?(_), do: true

  def transform(dsl) do
    Enum.reduce(events(dsl), {:ok, dsl}, fn event, acc ->
      add_change(acc, event)
    end)
  end

  defp add_change({:ok, dsl}, event) do
    dsl
    |> Transformer.get_entities([:actions])
    |> filter_actions(event)
    |> Enum.reduce({:ok, dsl}, fn action, {:ok, dsl} ->
      with {:ok, relate_actor} <-
             Transformer.build_entity(Ash.Resource.Dsl, [:actions, action.type], :change,
               change:
                 Ash.Resource.Change.Builtins.relate_actor(actor_attribute_name(event),
                   allow_nil?: true
                 )
             ),
           {:ok, set_timestamp} <-
             Transformer.build_entity(Ash.Resource.Dsl, [:actions, action.type], :change,
               change:
                 Ash.Resource.Change.Builtins.set_attribute(
                   timestamp_attribute_name(event),
                   &DateTime.utc_now/0
                 )
             ) do
        new_action = %{
          action
          | changes: action.changes ++ [relate_actor, set_timestamp]
        }

        {:ok, Transformer.replace_entity(dsl, [:actions], new_action, &(&1.name == action.name))}
      end
    end)
  end

  defp add_change({:error, error}, _), do: {:error, error}

  defp filter_actions(actions, %{action_type: nil, actions: actions_for_event}) do
    Enum.filter(actions, &(&1.name in actions_for_event))
  end

  defp filter_actions(actions, %{action_type: action_type}) do
    Enum.filter(actions, &(&1.type == action_type))
  end
end
