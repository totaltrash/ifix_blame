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
  @event %Ash.Dsl.Entity{
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
  @blame %Ash.Dsl.Section{
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

  use Ash.Dsl.Extension,
    sections: [@blame],
    transformers: [
      IFix.Blame.Transformers.SetDefaultEvents,
      IFix.Blame.Transformers.AddTimestamps,
      IFix.Blame.Transformers.AddRelationships,
      IFix.Blame.Transformers.AddChanges
    ]

  def events(resource) do
    Ash.Dsl.Extension.get_entities(resource, [:blame])
  end

  def actor_resource(resource) do
    case Ash.Dsl.Extension.get_opt(resource, [:blame], :actor, []) do
      {resource, _field} -> resource
      resource -> resource
    end
  end

  def actor_field(resource) do
    case Ash.Dsl.Extension.get_opt(resource, [:blame], :actor, []) do
      {_resource, field} -> field
      _ -> :id
    end
  end

  def actor_field_name(event) do
    event.name
    |> Atom.to_string()
    |> Kernel.<>("_user")
    |> String.to_atom()
  end

  def timestamp_field_name(event) do
    event.name
    |> Atom.to_string()
    |> Kernel.<>("_date")
    |> String.to_atom()
  end

  def api(resource) do
    Ash.Dsl.Extension.get_opt(resource, [:blame], :api, [])
  end
end
