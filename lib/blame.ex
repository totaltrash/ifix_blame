defmodule IFix.Blame do
  @moduledoc """
  Extend a resource to log who created and last edited a resource, and when.
  """

  @event_schema [
    name: [
      type: :atom,
      required: true,
      doc: "The name of the event"
    ],
    action_type: [
      type: :atom,
      required: false
    ],
    actions: [
      type: {:list, :atom},
      required: false
    ]
  ]
  @event %Spark.Dsl.Entity{
    name: :event,
    describe: "Adds an event to capture for blame",
    examples: [
      "event :created, action_type: :create",
      "event :updated, actions: [:update, :other_update]",
      "event :password_changed, actions: [:change_password, :reset_password]"
    ],
    target: IFix.Blame.Event,
    args: [:name],
    schema: @event_schema
  }
  @blame %Spark.Dsl.Section{
    name: :blame,
    describe: "Defines how blame is configured for a resource.",
    schema: [
      actor: [
        type: {:or, [:atom, :mod_arg]},
        doc: """
        The actor, must be an Ash resource (`Module`) or a tuple (`{Module, :primary_key}`)
        """
      ],
      api: [
        type: :atom,
        doc: """
        The api that the actor resource belongs to
        """
      ]
    ],
    entities: [
      @event
    ]
  }

  use Spark.Dsl.Extension,
    sections: [@blame],
    transformers: [
      IFix.Blame.Transformers.SetDefaultEvents,
      IFix.Blame.Transformers.AddTimestamps,
      IFix.Blame.Transformers.AddRelationships,
      IFix.Blame.Transformers.AddChanges
    ]
end
