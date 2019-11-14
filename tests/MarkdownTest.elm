module MarkdownTest exposing (all)

-- import Fuzz exposing (Fuzzer, int, list, string)

import Dict
import Elm.Docs
import Expect
import Json.Decode as D
import Markdown exposing (render)
import Result
import Test exposing (Test, describe, test)


all : Test
all =
    let
        n =
            Nothing

        j =
            Just
    in
    describe "Game test"
        [ describe "Simple module"
            [ test "test" <|
                \_ ->
                    Expect.equal (Ok "") <|
                        Result.map Markdown.render <|
                            (D.decodeString (D.list <| Elm.Docs.decoder) >> Result.mapError D.errorToString) <|
                                """[{"name":"Deferred.Thunk","comment":" This library lets you delay a computation until later.


# Basics

@docs Thunk, thunk, force


# Mapping

@docs map, map2, map3, map4, map5


# Chaining

@docs apply, andThen

","unions":[{"name":"Thunk","comment":" A wrapper around a value that will be evaluated later.
","args":["a"],"cases":[]}],"aliases":[],"values":[{"name":"andThen","comment":" Chain together thunk computations, for when you have a series of
steps that all need delayed evaluation. This can be nice when you need to
pattern match on a value, for example, when appending thunk lists:

    type List a = Empty | Node a (Thunk (List a))

    cons : a -> Thunk (List a) -> Thunk (List a)
    cons first rest =
      Thunk.map (Node first) rest

    append : Thunk (List a) -> Thunk (List a) -> Thunk (List a)
    append thunkList1 thunkList2 =
      let
        appendHelp list1 =
          case list1 of
            Empty ->
              thunkList2

            Node first rest ->
              cons first (append rest list2))
      in
        thunkList1
          |> Thunk.andThen appendHelp

By using `andThen` we ensure that neither `thunkList1` nor `thunkList2` are forced
before they are needed. So as written, the `append` function delays the pattern
matching until later.

","type":"(a -> Deferred.Thunk.Thunk b) -> Deferred.Thunk.Thunk a -> Deferred.Thunk.Thunk b"},{"name":"apply","comment":" Delay application of a thunk function to a thunk value. This is pretty rare on its
own, but it lets you map as high as you want.

    map3 f a b == f `map` a `apply` b `apply` c

It is not the most beautiful, but it is equivalent and will let you create
`map9` quite easily if you really need it.

","type":"Deferred.Thunk.Thunk (a -> b) -> Deferred.Thunk.Thunk a -> Deferred.Thunk.Thunk b"},{"name":"force","comment":" Force the evaluation of a thunk value. This means we only pay for the
computation when we need it. Here is a rather contrived example.

    thunkSum : Thunk Int
    thunkSum =
        thunk (\\() -> List.sum (List.range 1 1000000))

    sums : ( Int, Int, Int )
    sums =
        ( force thunkSum, force thunkSum, force thunkSum )

    sums --> (500000500000, 500000500000, 500000500000)

We are forcing this computation three times. The cool thing is that the first
time you `force` a value, the result is stored. This means you pay the cost on
the first one, but all the rest are very cheap, basically just looking up a
value in memory.

","type":"Deferred.Thunk.Thunk a -> a"},{"name":"map","comment":" Create a thunk that when forced will apply a function to the evaluation of the given thunk value.

    thunkSum : Thunk Int
    thunkSum =
        map List.sum (thunk (\\() -> List.range 1 1000000))

The resulting thunk value will create a big list and sum it up when it is
finally forced.

    force thunkSum --> 500000500000

","type":"(a -> b) -> Deferred.Thunk.Thunk a -> Deferred.Thunk.Thunk b"},{"name":"map2","comment":" Delay application of a function to two thunk values.

    thunkSum : Thunk Int
    thunkSum =
        map List.sum (thunk (\\() -> List.range 1 1000000))

    thunkSumPair : Thunk (Int, Int)
    thunkSumPair =
        map2 Tuple.pair thunkSum thunkSum

    force thunkSumPair --> (500000500000, 500000500000)

","type":"(a -> b -> result) -> Deferred.Thunk.Thunk a -> Deferred.Thunk.Thunk b -> Deferred.Thunk.Thunk result"},{"name":"map3","comment":" ","type":"(a -> b -> c -> result) -> Deferred.Thunk.Thunk a -> Deferred.Thunk.Thunk b -> Deferred.Thunk.Thunk c -> Deferred.Thunk.Thunk result"},{"name":"map4","comment":" ","type":"(a -> b -> c -> d -> result) -> Deferred.Thunk.Thunk a -> Deferred.Thunk.Thunk b -> Deferred.Thunk.Thunk c -> Deferred.Thunk.Thunk d -> Deferred.Thunk.Thunk result"},{"name":"map5","comment":" ","type":"(a -> b -> c -> d -> e -> result) -> Deferred.Thunk.Thunk a -> Deferred.Thunk.Thunk b -> Deferred.Thunk.Thunk c -> Deferred.Thunk.Thunk d -> Deferred.Thunk.Thunk e -> Deferred.Thunk.Thunk result"},{"name":"thunk","comment":" Delay the evaluation of a value until later. For example, maybe we will
need to generate a very long list and find its sum, but we do not want to do
it unless it is absolutely necessary.

    thunkSum : Thunk Int
    thunkSum =
        thunk (\\() -> sum [1..1000000])

Now we only pay for `thunkSum` if we actually need it.

","type":"(() -> a) -> Deferred.Thunk.Thunk a"}],"binops":[]}]"""
            ]
        ]
