module Markdown exposing (render)

import Elm.Docs exposing (..)
import Elm.Type exposing (..)


render : List Elm.Docs.Module -> String
render =
    List.map renderModule >> String.join "\n-----------------\n"


{-| All the documentation for a particular module.

  - name is the module name

  - comment is the module comment

The actual exposed stuff is broken into categories.

-}
renderModule : Module -> String
renderModule ({ name, comment, unions, aliases, values, binops } as module_) =
    module_ |> Elm.Docs.toBlocks |> List.map renderBlock |> String.join "\n-----------------\n"


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


{-| Documentation for a type alias. For example, if you had the source code:

    {-| pair of values -}
    type alias Pair a = ( a, a )

When it became an Alias it would be like this:

    { name = "Pair"
    , comment = " pair of values "
    , args = ["a"]
    , tipe = Tuple [ Var "a", Var "a" ]
    }

-}
renderAlias : Alias -> String
renderAlias { name, comment, args, tipe } =
    [ name, comment ] ++ args ++ [ renderType tipe ] |> String.join "\n"



-- Documentation for values and functions. For example, if you had the source code:
-- {-| do not do anything -}
-- identity : a -> a
-- identity value =
--   value
-- The Value would look like this:
-- { name = "identity"
-- , comment = " do not do anything "
-- , tipe = Lambda (Var "a") (Var "a")
-- }


renderValue : Value -> String
renderValue { name, comment, tipe } =
    [ name, comment, renderType tipe ] |> String.join "\n"



-- Documentation for a union type. For example, if you had the source code:
-- {-| maybe -}
-- type Maybe a = Nothing | Just a
-- When it became a Union it would be like this:
-- { name = "Maybe"
-- , comment = " maybe "
-- , args = ["a"]
-- , tipe =
--     [ ("Nothing", [])
--     , ("Just", [Var "a"])
--     ]
-- }


renderUnion : Union -> String
renderUnion { name, comment, args, tags } =
    ([ name, comment ] ++ args ++ List.map renderTag tags) |> String.join "\n"


renderTag : ( String, List Type ) -> String
renderTag _ =
    ""



-- Documentation for binary operators. The content for (+) might look something like this:
-- { name = "+"
-- , comment = "Add numbers"
-- , tipe = Lambda (Var "number") (Lambda (Var "number") (Var "number"))
-- , associativity = Left
-- , precedence = 6
-- }8
-- type Associativity
--     = Left
--     | None
--     | Right
-- The associativity of an infix operator. This determines how we add parentheses around everything. Here are some examples:
-- 1 + 2 + 3 + 4
-- We have to do the operations in some order, so which of these interpretations should we choose?
-- ((1 + 2) + 3) + 4   -- left-associative
-- 1 + (2 + (3 + 4))   -- right-associative
-- This is really important for operators like (|>)!
-- Some operators are non-associative though, meaning we do not try to add missing parentheses. (==) is a nice example. 1 == 2 == 3 just is not allowed!


renderBinop : Binop -> String
renderBinop { name, comment, tipe, associativity, precedence } =
    [ name, comment, renderType tipe, renderAssociativity associativity, String.fromInt precedence ] |> String.join "\n"


renderAssociativity : Associativity -> String
renderAssociativity associativity =
    case associativity of
        Left ->
            "Left"

        Right ->
            "Right"

        None ->
            "None"



-- Represent Elm types as values! Here are some examples:
-- Int            ==> Type "Int" []
-- a -> b         ==> Lambda (Var "a") (Var "b")
-- ( a, b )       ==> Tuple [ Var "a", Var "b" ]
-- Maybe a        ==> Type "Maybe" [ Var "a" ]
-- { x : Float }  ==> Record [("x", Type "Float" [])] Nothing


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
            string :: List.map renderType tipes |> String.join " "

        Record members maybeString ->
            -- ignoring maybeString since I don't know what it's used for.
            "{ " ++ (List.map (\( name, tipe_ ) -> name ++ " : " ++ renderType tipe_) members |> String.join ", ") ++ " }"
