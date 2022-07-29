locals_without_parens = [actor: 1, api: 1, event: 2]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:ash],
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
