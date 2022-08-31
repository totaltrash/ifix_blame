defmodule IFix.Blame.Info do
  alias Spark.Dsl.Transformer

  def events(dsl) do
    Transformer.get_entities(dsl, [:blame])
  end

  def actor_resource(dsl) do
    case Transformer.get_option(dsl, [:blame], :actor, []) do
      {resource, _attribute} -> resource
      resource -> resource
    end
  end

  def actor_attribute(dsl) do
    case Transformer.get_option(dsl, [:blame], :actor, []) do
      {_resource, attribute} -> attribute
      _ -> :id
    end
  end

  def actor_attribute_name(event) do
    event.name
    |> Atom.to_string()
    |> Kernel.<>("_user")
    |> String.to_atom()
  end

  def timestamp_attribute_name(event) do
    event.name
    |> Atom.to_string()
    |> Kernel.<>("_date")
    |> String.to_atom()
  end

  def api(dsl) do
    Transformer.get_option(dsl, [:blame], :api, [])
  end
end
