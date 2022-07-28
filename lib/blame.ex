defmodule IFix.Blame do
  @moduledoc """
  Configures a resource to log who created and last edited a resource, and when.

  WIP!

  So, this extension creates two (one for creates, another for updates):

  * timestamps, so you no longer need to add timestamps to your resources
  * relationships, for who did the create or update

  and adds changes to all create and update actions, to populate the created_user
  and updated_user with the current actor

  You will need to configure the api and resource module to use for the actor:

      blame do
        actor Portal.Accounts.User
        api Portal.Accounts
      end

  Improvements
  ============

  I'd like to pass the api and the actor in config - for most apps it's going to be the
  same api and actor for all resources. Maybe you can extend the Api dsl to include this
  and use that as the default config for all resources?

  I'd like to be able to configure the elements (bad name) to be tracked for blame.
  This is an example of the default config:

  blame do
    api ...
    actor ...

    element :created, action_type: :create, actions: :all
    element :updated, action_type: :update, actions: :all
  end

  But you might want to be able to track some special elements:

      element :password_changed, action_type: :update, actions: [:changed_password, :admin_changed_password]

  There's currently a lot of duplication in the transformers, but that will go away when you implement the elements
  configuration

  I'm not sure if I like the setting of updated (user and timestamp) at the time of creation. Maybe they should remain nil?
  Doing that makes more sense in light of extending the tracked elements - ie, we probably don't want the :password_changed
  element to be set to the current user and timestamp when creating a new user. Or maybe it is should be configurable in the
  update (action_type) elements

  Maybe this should be the config:

    tracking do
      create :created, actions: :all
      update :updated, actions: [:update, :other_update]
      update :password_changed, actions: [:changed_password, :admin_changed_password]
    end
  """

  @blame %Ash.Dsl.Section{
    name: :blame,
    describe: "A section for configuring how blame is configured for a resource.",
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
        The api that the actor belongs to
        """
      ]
    ]
  }

  use Ash.Dsl.Extension,
    sections: [@blame],
    transformers: [
      IFix.Blame.Transformers.SetupBlame,
      IFix.Blame.Transformers.AddChange
      # IFix.Blame.Transformers.Inspect
    ]

  def actor(resource) do
    Ash.Dsl.Extension.get_opt(resource, [:blame], :actor, [])
  end

  def api(resource) do
    Ash.Dsl.Extension.get_opt(resource, [:blame], :api, [])
  end
end
