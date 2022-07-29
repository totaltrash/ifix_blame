defmodule Test.BlameTest do
  use ExUnit.Case

  defmodule Registry do
    use Ash.Registry

    entries do
      entry DefaultResource
      entry CustomResource
    end
  end

  defmodule Api do
    use Ash.Api

    resources do
      registry Registry
    end
  end

  defmodule User do
    use Ash.Resource

    attributes do
      uuid_primary_key :id
    end
  end

  defmodule DefaultResource do
    use Ash.Resource,
      extensions: [IFix.Blame]

    blame do
      api Test.BlameTest.Api
      actor Test.BlameTest.User
    end

    actions do
      defaults [:create, :read, :update, :destroy]
    end

    attributes do
      uuid_primary_key :id
    end
  end

  test "default resource" do
    # assert timestamps
    assert_has_attribute(DefaultResource, :created_date)
    assert_has_attribute(DefaultResource, :updated_date)

    # assert relationships
    assert_has_relationship(DefaultResource, :created_user)
    assert_has_relationship(DefaultResource, :updated_user)

    # assert changes attached to actions
    assert Enum.count(Ash.Resource.Info.action(DefaultResource, :create).changes) == 2
    assert Enum.count(Ash.Resource.Info.action(DefaultResource, :update).changes) == 2
    assert_action_has_relate_actor(DefaultResource, :create, :created_user)
    assert_action_has_relate_actor(DefaultResource, :update, :updated_user)
    assert_action_has_set_timestamp(DefaultResource, :create, :created_date)
    assert_action_has_set_timestamp(DefaultResource, :update, :updated_date)
  end

  defmodule CustomResource do
    use Ash.Resource,
      extensions: [IFix.Blame]

    blame do
      api Test.BlameTest.Api
      actor Test.BlameTest.User

      event :created, action_type: :create
      event :updated, actions: [:update, :other_update]
      event :password_changed, actions: [:change_password, :reset_password]
    end

    actions do
      defaults [:create, :read, :update, :destroy]
      update :other_update
      update :change_password
      update :reset_password
    end

    attributes do
      uuid_primary_key :id
    end
  end

  test "custom resource" do
    # assert timestamps
    assert_has_attribute(CustomResource, :created_date)
    assert_has_attribute(CustomResource, :updated_date)
    assert_has_attribute(CustomResource, :password_changed_date)

    # assert relationships
    assert_has_relationship(CustomResource, :created_user)
    assert_has_relationship(CustomResource, :updated_user)
    assert_has_relationship(CustomResource, :password_changed_user)

    # assert changes attached to actions
    assert Enum.count(Ash.Resource.Info.action(CustomResource, :create).changes) == 2
    assert Enum.count(Ash.Resource.Info.action(CustomResource, :update).changes) == 2
    assert Enum.count(Ash.Resource.Info.action(CustomResource, :other_update).changes) == 2
    assert Enum.count(Ash.Resource.Info.action(CustomResource, :change_password).changes) == 2
    assert Enum.count(Ash.Resource.Info.action(CustomResource, :reset_password).changes) == 2

    assert_action_has_relate_actor(CustomResource, :create, :created_user)
    assert_action_has_relate_actor(CustomResource, :update, :updated_user)
    assert_action_has_relate_actor(CustomResource, :other_update, :updated_user)
    assert_action_has_relate_actor(CustomResource, :change_password, :password_changed_user)
    assert_action_has_relate_actor(CustomResource, :reset_password, :password_changed_user)

    assert_action_has_set_timestamp(CustomResource, :create, :created_date)
    assert_action_has_set_timestamp(CustomResource, :update, :updated_date)
    assert_action_has_set_timestamp(CustomResource, :other_update, :updated_date)
    assert_action_has_set_timestamp(CustomResource, :change_password, :password_changed_date)
    assert_action_has_set_timestamp(CustomResource, :reset_password, :password_changed_date)
  end

  defp assert_has_attribute(resource, attribute) do
    assert %Ash.Resource.Attribute{} = Ash.Resource.Info.attribute(resource, attribute)
  end

  defp assert_has_relationship(resource, attribute) do
    assert %Ash.Resource.Relationships.BelongsTo{} =
             Ash.Resource.Info.relationship(resource, attribute)
  end

  defp assert_action_has_relate_actor(resource, action, relationship) do
    Ash.Resource.Info.action(resource, action).changes
    |> Enum.any?(fn change ->
      {module, opts} = change.change
      module == Ash.Resource.Change.RelateActor && opts[:relationship] == relationship
    end)
  end

  defp assert_action_has_set_timestamp(resource, action, attribute) do
    Ash.Resource.Info.action(resource, action).changes
    |> Enum.any?(fn change ->
      {module, opts} = change.change
      module == Ash.Resource.Change.SetAttribute and opts[:attribute] == attribute
    end)
  end
end
