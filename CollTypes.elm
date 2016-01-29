module CollTypes (..) where

import Types exposing (Player, Asteroid, Shot)


type alias Circle =
    { x : Float
    , y : Float
    , radius : Float
    }



{-
Circ acts as a replacement for classes. So instead of
  a class ToCircle a
    with function circle : a -> Circle
  and a function collision : ToCircle a, ToCircle b => a -> b -> Bool
we have
  one function ... : Circ -> Circle
  and a function collision : Circ -> Circ -> Bool
-}


type Circ
    = P Player
    | A Asteroid
    | S Shot
