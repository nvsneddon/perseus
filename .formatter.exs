[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["priv/*/migrations"],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}", "priv/*/seeds.exs"],
  locals_without_parens: [
    arg: 2,
    import_types: 1,
    import_fields: 1,
    middleware: 1,
    resolve: 1,
    parse: 1,
    serialize: 1
  ]
]
