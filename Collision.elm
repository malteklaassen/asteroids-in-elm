module Collision where

import Definitions exposing (..)
import Types exposing (..)
import CollTypes exposing (..)

{-
  Replacement for a Class ToCircle a, see CollTypes.elm
-}
toCircle : Circ -> Circle
toCircle c =
  case c of
    P p -> 
      { x = p.x
      , y = p.y
      , radius = playerRadius
      }
    A a ->
      { x = a.x
      , y = a.y
      , radius = toFloat (a.size + 1) * asteroidRadius
      }
    S s ->
      { x = s.x
      , y = s.y
      , radius = shotRadius
      }

moveCircle : (Float, Float) -> Circle -> Circle
moveCircle (x,y) =
  \c ->
    { x = c.x + x
    , y = c.y + y
    , radius = c.radius
    }

{-
  (Oh well, probably one of the worst workarounds for a problem I have ever written.)
  Unluckily the simple collision funcion is not enough as collision doesnt detect collisions happening on the edges and in the corners.
  To solve this, cornerCollision takes the first circle and checks its collision not only with the original second circle but also 8 other positions where the second one might overlap with the field.
  On the torus the field is supposed to mimic this is equivalent to one "round trip" - I'd be greatful if someone knew a more elegant solution for this problem.
-}
cornerCollision : Circle -> Circle -> Bool
cornerCollision c1 =
  \c2 ->
    List.any identity <<
    List.map
      (\(x,y) ->
        collision c1 <<
        moveCircle (x,y) <|
        c2
      ) <|
    [ (0,0)
    , (0, gameHeight)
    , (0, -gameHeight)
    , (gameWidth, 0)
    , (gameWidth, gameHeight)
    , (gameWidth, -gameHeight)
    , (-gameWidth, 0)
    , (-gameWidth, gameHeight)
    , (-gameWidth, -gameHeight)
    ]

collision : Circle -> Circle -> Bool
collision c1 c2 =
  let
    dx = c1.x - c2.x
    dy = c1.y - c2.y
    dx2 = dx * dx
    dy2 = dy * dy
    dist = sqrt <| dx2 + dy2
  in
    dist < c1.radius + c2.radius

{-
  These are the functions that later will be used by the game outside of this file.
-}

collisionPlayer : Player -> List Asteroid -> Bool
collisionPlayer p = 
  List.any identity << List.map ((cornerCollision (toCircle (P p))) << toCircle << A)

collisionAsteroids : List Asteroid -> List Shot -> List Asteroid
collisionAsteroids la ls =
  List.filter (\a -> collisionAsteroid a ls) <| la

collisionAsteroid : Asteroid -> List Shot -> Bool
collisionAsteroid a =
  List.any identity << List.map ((cornerCollision (toCircle (A a))) << toCircle << S)

collisionShot : Shot -> List Asteroid -> Bool
collisionShot s =
  List.any identity << List.map ((cornerCollision (toCircle (S s))) << toCircle << A)
