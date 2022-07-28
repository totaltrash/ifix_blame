defmodule IFix.Blame.Transformers.AddChange do
  use Ash.Dsl.Transformer

  alias Ash.Dsl.Transformer

  def after?(_), do: true

  def transform(_module, dsl) do
    with {:ok, dsl} <- create_actions_change(dsl),
         {:ok, dsl} <- update_actions_change(dsl) do
      {:ok, dsl}
    end
  end

  defp create_actions_change(dsl) do
    dsl
    |> Transformer.get_entities([:actions])
    |> Enum.filter(&(&1.type == :create))
    |> Enum.reduce({:ok, dsl}, fn create_action, {:ok, dsl} ->
      with {:ok, relate_actor} <-
             Transformer.build_entity(Ash.Resource.Dsl, [:actions, :create], :change,
               change: Ash.Resource.Change.Builtins.relate_actor(:created_user, allow_nil?: true)
             ) do
        new_action = %{
          create_action
          | changes: create_action.changes ++ [relate_actor]
        }

        {:ok,
         Transformer.replace_entity(dsl, [:actions], new_action, &(&1.name == create_action.name))}
      end
    end)
  end

  defp update_actions_change(dsl) do
    dsl
    |> Transformer.get_entities([:actions])
    |> Enum.filter(&(&1.type == :update))
    |> Enum.reduce({:ok, dsl}, fn update_action, {:ok, dsl} ->
      with {:ok, relate_actor} <-
             Transformer.build_entity(Ash.Resource.Dsl, [:actions, :update], :change,
               change: Ash.Resource.Change.Builtins.relate_actor(:updated_user, allow_nil?: true)
             ) do
        new_action = %{
          update_action
          | changes: update_action.changes ++ [relate_actor]
        }

        {:ok,
         Transformer.replace_entity(dsl, [:actions], new_action, &(&1.name == update_action.name))}
      end
    end)
  end
end
