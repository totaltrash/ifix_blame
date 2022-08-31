# Blame

**This is me playing with Ash extensions - don't use it**

A simple Ash extension to log who created and last edited a resource, and when.

## Installation

```
def deps do
  [
    {:ifix_blame, github: "totaltrash/ifix_blame"}
  ]
end
```

If you're using the formatter, add `ifix_blame` to `import_deps` in your `formatter.exs`:

```
import_deps: [:ash, :ash_postgres, :ecto, :phoenix, :ifix_blame],
```

## Usage

Blame works by recording *who* performed an action, and *when*. It only records the most
recent update. It gets the who from the actor. You can optionally remove existing timestamp
attributes from your resource.

By default, Blame will create a `created_user` relationship and a `created_date` timestamp,
and an `updated_user` and `updated_date` pair to record the most recent update. Blame also
adds changes to look after the updating of these attributes upon all `:create` and `:update`
action types.

The minimum configuration for each resource is:

```elixir
defmodule MyApp.SomeResource do
  use Ash.Resource,
    extensions: [IFix.Blame]
    
  blame do
    api MyApp.Api
    actor MyApp.User
  end
end
```

Blame let's you have tighter control over the events that you want to capture, and
lets you define additional actor/timestamp pairs. You must provide one of `action_type`,
or `actions` for each event:

```elixir
blame do
  api MyApp.Api
  actor MyApp.User

  event :created, action_type: :create
  event :updated, actions: [:update, :other_update]
  event :password_changed, actions: [:change_password, :reset_password]
end
```

The above configuration will create 3 actor/timestamp pairs on the resource: `created_user`/`created_date`,
`updated_user`/`updated_date`, and `password_changed_user`/`password_changed_date`.
