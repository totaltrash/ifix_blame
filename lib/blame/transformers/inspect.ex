defmodule IFix.Blame.Transformers.Inspect do
  use Spark.Dsl.Transformer

  def transform(dsl) do
    {:ok, IO.inspect(dsl, label: "inspect")}
  end
end
