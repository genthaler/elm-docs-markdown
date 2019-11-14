module Markdown exposing (render)

import Elm.Docs exposing (..)
import Elm.Type exposing (..)


br : String
br =
    "\\\n"


brs : List String -> String
brs =
    String.join br


spaces : List String -> String
spaces =
    String.join " "


para : String
para =
    "\n\n"


paras : List String -> String
paras =
    String.join para


hr : String
hr =
    "\n\n----\n\n"


h1 : String -> String
h1 string =
    string ++ "\n====\n"


h2 : String -> String
h2 string =
    string ++ "\n----\n"


em : String -> String
em string =
    "*" ++ string ++ "*"


strong : String -> String
strong string =
    "**" ++ string ++ "**"


render : List Elm.Docs.Module -> String
render =
    List.map renderModule >> String.join para


renderModule : Module -> String
renderModule module_ =
    (h1 module_.name :: (module_ |> Elm.Docs.toBlocks |> List.map renderBlock)) |> paras


renderBlock : Elm.Docs.Block -> String
renderBlock block =
    case block of
        Elm.Docs.UnionBlock unionBlock ->
            renderUnion unionBlock

        Elm.Docs.MarkdownBlock md ->
            md

        Elm.Docs.AliasBlock aliasBlock ->
            renderAlias aliasBlock

        Elm.Docs.ValueBlock valueBlock ->
            renderValue valueBlock

        Elm.Docs.BinopBlock binopBlock ->
            renderBinop binopBlock

        Elm.Docs.UnknownBlock unknown ->
            unknown


renderAlias : Alias -> String
renderAlias { name, comment, args, tipe } =
    "> " ++ ([ (em "type alias" :: strong name :: args) |> spaces, renderType tipe, comment ] |> paras)


renderValue : Value -> String
renderValue { name, comment, tipe } =
    "> " ++ ([ [ strong name, ":", renderType tipe ] |> spaces, comment ] |> paras)


renderUnion : Union -> String
renderUnion { name, comment, args, tags } =
    let
        renderedTags =
            if List.length tags > 0 then
                " = " ++ (List.map renderTag tags |> String.join " | ")

            else
                ""
    in
    "> " ++ ([ ((em "type" :: strong name :: args) |> spaces) ++ renderedTags, comment ] |> paras)


renderTag : ( String, List Type ) -> String
renderTag ( tag, tipes ) =
    em tag :: List.map renderType tipes |> spaces


renderBinop : Binop -> String
renderBinop { name, comment, tipe, associativity, precedence } =
    "> " ++ ([ [ em "infix", renderAssociativity associativity, String.fromInt precedence, name, "=", renderType tipe ] |> spaces, comment ] |> paras)


renderAssociativity : Associativity -> String
renderAssociativity associativity =
    case associativity of
        Left ->
            "left"

        Right ->
            "right"

        None ->
            "non"


renderType : Type -> String
renderType tipe =
    case tipe of
        Var string ->
            string

        Lambda tipe1 tipe2 ->
            renderType tipe1 ++ " -> " ++ renderType tipe2

        Tuple tipes ->
            "(" ++ (List.map renderType tipes |> String.join ", ") ++ ")"

        Type string tipes ->
            string :: List.map renderType tipes |> spaces

        Record members _ ->
            -- ignoring (Maybe String) since I don't know what it's used for.
            "{ " ++ (List.map (\( name, tipe_ ) -> name ++ " : " ++ renderType tipe_) members |> String.join ", ") ++ " }"
