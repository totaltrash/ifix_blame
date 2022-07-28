defmodule IFix.Blame.Transformers.Inspect do
  use Ash.Dsl.Transformer

  def after?(_), do: true

  def transform(module, dsl) do
    {:ok, IO.inspect(dsl, label: module)}
  end
end
