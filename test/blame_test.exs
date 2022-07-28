defmodule Test.BlameTest do
  use ExUnit.Case

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

  defmodule Registry do
    use Ash.Registry

    entries do
      entry DefaultResource
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

  test "default resource" do
    # assert timestamps
    assert_has_attribute(DefaultResource, :created_date)
    assert_has_attribute(DefaultResource, :updated_date)

    # assert relationships
    assert_has_relationship(DefaultResource, :created_user)
    assert_has_relationship(DefaultResource, :updated_user)

    # assert changes attached to actions
    assert Enum.count(Ash.Resource.Info.action(DefaultResource, :create).changes) == 1
    assert Enum.count(Ash.Resource.Info.action(DefaultResource, :update).changes) == 1
    assert_action_has_relate_actor(DefaultResource, :create, :created_user)
    assert_action_has_relate_actor(DefaultResource, :update, :updated_user)
  end

  defp assert_has_attribute(resource, attribute) do
    assert %Ash.Resource.Attribute{} = Ash.Resource.Info.attribute(resource, attribute)
  end

  defp assert_has_relationship(resource, attribute) do
    assert %Ash.Resource.Relationships.BelongsTo{} =
             Ash.Resource.Info.relationship(resource, attribute)
  end

  defp assert_action_has_relate_actor(resource, action, relationship) do
    Enum.any?(
      Ash.Resource.Info.action(resource, action).changes,
      fn action ->
        {Ash.Resource.Change.RelateActor, [relationship: ^relationship, allow_nil?: true]} =
          action.change
      end
    )
  end
end
