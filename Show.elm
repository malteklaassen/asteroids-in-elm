module Show (..) where

import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Color exposing (..)
import Random
import Time
import Text
import String
import Helpers exposing (..)
import Definitions exposing (..)
import Types exposing (..)


view : Game -> Element
view g =
    case g of
        Start ->
            collage
                gameWidth
                gameHeight
                [ background
                , titleText
                ]

        Level level ->
            collage
                gameWidth
                gameHeight
                [ background
                , showShots <| level.shots
                , showPlayer level.accelerating <| level.player
                , showAsteroids <| level.asteroids
                , move ( -360, 285 ) << toForm << leftAligned << Text.color white << Text.fromString << String.concat <| [ "Lives: ", toString level.lives ]
                , move ( -360, 265 ) << toForm << leftAligned << Text.color white << Text.fromString << String.concat <| [ "Score: ", toString level.score ]
                ]

        GameOver gameOver ->
            collage
                gameWidth
                gameHeight
                [ background
                , endText gameOver.level gameOver.score
                ]

        Pause pause ->
            collage
                gameWidth
                gameHeight
                [ background
                , pauseText pause.level pause.score
                ]

        End end ->
            collage
                gameWidth
                gameHeight
                [ background
                , finishedText end.score
                ]


polygonPlayer : List ( Float, Float )
polygonPlayer =
    [ ( 0, -10 ), ( 10, -15 ), ( 0, 15 ), ( -10, -15 ) ]


polygonPlayerAcc : List ( Float, Float )
polygonPlayerAcc =
    polygonPlayer ++ [ ( -4, -12 ), ( 0, -15 ), ( 4, -12 ), ( 0, -15 ), ( -4, -12 ) ]


polygonAsteroid : List (List ( Float, Float ))
polygonAsteroid =
    [ [ ( 2, 4 ), ( 4, 4 ), ( 6, 6 ), ( 10, 2 ), ( 8, -6 ), ( 4, -6 ), ( 0, -10 ), ( -4, -10 ), ( -10, -2 ), ( -8, 4 ), ( -2, 4 ), ( -4, 8 ), ( 2, 8 ) ]
    , [ ( 0, 10 ), ( 2, 6 ), ( 6, 8 ), ( 8, 4 ), ( 6, 2 ), ( 10, 0 ), ( 6, -8 ), ( 2, -10 ), ( -2, -8 ), ( -6, -8 ), ( -10, -2 ), ( -10, 0 ), ( -8, 9 ) ]
    ]



{- cornerShow : Form -> Form
cornerShow =
  \f ->
    group <<
    List.map
      (\(x,y) ->
        move (x,y) f
      ) <|
    [ (0, 0)
    , (0, gameHeight)
    , (0, -gameHeight)
    , (gameWidth, 0)
    , (gameWidth, gameHeight)
    , (gameWidth, -gameHeight)
    , (-gameWidth, 0)
    , (-gameWidth, gameHeight)
    , (-gameWidth, -gameHeight)
    ]
-}
{-
Similar to cornerCollision from the module Collision this function is needed to show items on the edges and in the corners of the playing field.
It uses a similar approach to this problem of our field not really being a torus but unlike cornerCollision it draws only those instances of objects that are somewhat close to the visible field.
This makes the function even more ugly ( ;) ) but seems to improve the performance a bit in cases with many objects. No exensive testing was done though.
A stupid, cornerCollision-like version can be found above.
-}


cornerShow : ( Float, Float ) -> Float -> Form -> Form
cornerShow ( x, y ) r f =
    group
        << List.map
            (\( x, y ) ->
                move ( x - gameWidth / 2, y - gameHeight / 2 ) f
            )
        << List.filter
            (\( x, y ) ->
                List.any identity
                    << List.map
                        (\( x, y ) ->
                            x >= 0 && x <= gameWidth && y >= 0 && y <= gameHeight
                        )
                    <| [ ( x + r, y + r )
                       , ( x + r, y - r )
                       , ( x - r, y + r )
                       , ( x - r, y - r )
                       ]
            )
        <| [ ( x, y )
           , ( x, y + gameHeight )
           , ( x, y - gameHeight )
           , ( x + gameWidth, y )
           , ( x + gameWidth, y + gameHeight )
           , ( x + gameWidth, y - gameHeight )
           , ( x - gameWidth, y )
           , ( x - gameWidth, y + gameHeight )
           , ( x - gameWidth, y - gameHeight )
           ]



-- Visual representation of the player through a polygon


showPlayer : Bool -> Player -> Form
showPlayer accelerating p =
    cornerShow ( p.x, p.y ) playerRadius
        << rotate (0 - p.angle)
        << group
        << List.map
            (\f ->
                f
                    <| polygon
                        (List.map identity
                            <| if accelerating then
                                polygonPlayerAcc
                               else
                                polygonPlayer
                        )
            )
        <| [ filled black
             -- to hide items BEHIND this one
           , outlined (solid white)
           ]



-- Visual representation of an Asteroid through one of multiple polygons.


showAsteroids : List Asteroid -> Form
showAsteroids =
    group
        << List.map showAsteroid


showAsteroid : Asteroid -> Form
showAsteroid =
    \a ->
        cornerShow ( a.x, a.y ) (toFloat a.size + 1 * asteroidRadius)
            << rotate a.angle
            << group
            << List.map
                (\f ->
                    f
                        << polygon
                        << List.map (\( x, y ) -> ( (toFloat a.size + 1) * x, (toFloat a.size + 1) * y ))
                        <| index polygonAsteroid (a.form % (List.length polygonAsteroid)) []
                )
            <| [ filled black
                 -- to hide items BEHIND this one
               , outlined (solid white)
               ]



-- No polygons for shots, they are simple, small circles


showShots : List Shot -> Form
showShots =
    group
        << List.map
            (\s ->
                cornerShow ( s.x, s.y ) shotRadius
                    << outlined (solid white)
                    <| circle shotRadius
            )



-- Initially I wanted to make a dynamic background (e.g. through 100 random, small circles). This is not possible as seemingly 100 objects are too much to handle for the engine...
-- Instead I use a static background graphic


background : Form
background =
    toForm
        <| image gameWidth gameHeight "graphics/background.png"


titleText : Form
titleText =
    group
        [ move ( 0, 50 )
            << scale 4
            << toForm
            << centered
            << Text.color white
            << Text.fromString
            <| "Asteroids"
        , move ( 0, 0 )
            << toForm
            << centered
            << Text.color white
            << Text.fromString
            <| "in Elm"
        , move ( 0, -250 )
            << toForm
            << centered
            << Text.color white
            << Text.fromString
            <| "Press W to accelerate, A and D to turn and Space to fire.\nPress Space to start."
        ]


pauseText : Int -> Int -> Form
pauseText l s =
    group
        [ move ( 0, 50 )
            << scale 4
            << toForm
            << centered
            << Text.color white
            << Text.fromString
            <| "Level complete."
        , move ( 0, -40 )
            << toForm
            << centered
            << Text.color white
            << Text.fromString
            << String.concat
            <| [ "Level "
               , toString l
               , " finished.\nPress Space to continue."
               , "\nYour score is "
               , toString s
               , "!"
               ]
        ]


endText : Int -> Int -> Form
endText l s =
    group
        [ move ( 0, 50 )
            << scale 4
            << toForm
            << centered
            << Text.color white
            << Text.fromString
            <| "Game Over!"
        , move ( 0, -40 )
            << toForm
            << centered
            << Text.color white
            << Text.fromString
            << String.concat
            <| [ "You reached level "
               , toString l
               , " and score "
               , toString s
               , ".\nPress Space to restart."
               ]
        ]


finishedText : Int -> Form
finishedText s =
    group
        [ move ( 0, 50 )
            << scale 4
            << toForm
            << centered
            << Text.color white
            << Text.fromString
            <| "You won!"
        , move ( 0, -40 )
            << toForm
            << centered
            << Text.color white
            << Text.fromString
            << String.concat
            <| [ "You finished all levels."
               , "\nYour score is "
               , toString s
               , "!"
                 --, "\nPress Space to restart."
               ]
        ]
