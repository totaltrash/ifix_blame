defmodule IFix.Blame.Transformers.SetDefaultEvents do
  use Ash.Dsl.Transformer

  alias Ash.Dsl.Transformer

  import IFix.Blame, only: [events: 1]

  def before?(_), do: true

  def transform(resource, dsl) do
    case Enum.empty?(events(resource)) do
      true ->
        with {:ok, dsl} <- add_default_event(dsl, :created, :create),
             {:ok, dsl} <- add_default_event(dsl, :updated, :update) do
          {:ok, dsl}
        end

      _ ->
        {:ok, dsl}
    end
  end

  defp add_default_event(dsl, name, action_type) do
    with {:ok, event} =
           Transformer.build_entity(IFix.Blame, [:blame], :event,
             name: name,
             action_type: action_type,
             actions: []
           ) do
      {:ok, Transformer.add_entity(dsl, [:blame], event)}
    end
  end
end
