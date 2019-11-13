module Markdown exposing (render)

import Elm.Docs


render : List Elm.Docs.Module -> String
render =
    List.map renderModule >> String.concat


renderModule : Elm.Docs.Module -> String
renderModule =
    Elm.Docs.toBlocks >> List.map renderBlock >> String.concat


renderBlock : Elm.Docs.Block -> String
renderBlock block =
    case block of
        Elm.Docs.UnionBlock { name, comment, args, tags } ->
            ""

        Elm.Docs.MarkdownBlock md ->
            md

        Elm.Docs.AliasBlock _ ->
            ""

        Elm.Docs.ValueBlock _ ->
            ""

        Elm.Docs.BinopBlock _ ->
            ""

        Elm.Docs.UnknownBlock unknown ->
            unknown
