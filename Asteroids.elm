module Main (..) where

import Time exposing (Time)
import Keyboard
import Text


--CUSTOM IMPORTS

import Game exposing (defaultLevel, defaultGameOver, defaultPause, defaultEnd)
import Levels exposing (levelList)
import Types exposing (..)
import Definitions exposing (..)
import Helpers
import Collision
import CollTypes exposing (..)
import Show exposing (view)


{-
Main update function, effectively only determines the state of the game and calls specific update functions accordingly.
-}


update : Input -> Game -> Game
update input game =
    case game of
        Start ->
            updateStart input

        Level level ->
            updateLevel input level

        Pause pause ->
            updatePause input pause

        GameOver gameOver ->
            updateGameOver input gameOver

        End end ->
            game



------------------------------------------------------------------------------------------------------------------------
{-
Case Start: if action is pressed, start a new game with the first level. Otherwise do nothing.
-}


updateStart : Input -> Game
updateStart input =
    if input.action then
        let
            level = Helpers.index levelList 0 defaultLevel
        in
            Level { level | lives = 5 }
    else
        Start



------------------------------------------------------------------------------------------------------------------------
{-
Case Level level: ...lots of stuff...
-}


updateLevel : Input -> GLevel -> Game
updateLevel input level =
    let
        collision = Collision.collisionPlayer level.player level.asteroids
    in
        if collision && (level.lives == 0) then
            -- if the player collides with an asteroid and has no lives left -> GameOver
            GameOver { defaultGameOver | cooldown = True, level = level.level, score = level.score }
        else if List.isEmpty level.asteroids then
            -- if the level is done ...
            if level.level >= List.length levelList - 1 then
                -- ... and it is the last level -> End/Finished
                End { defaultEnd | cooldown = True, score = level.score + level.lives * 100 }
            else
                -- ... and it is not the last level -> Pause, wait for the user to start the next level
                Pause { defaultPause | cooldown = True, level = level.level, score = level.score, lives = level.lives }
        else
            -- if the ship is not destroyed and the level is not over, update the level values accordingly
            let
                newShots =
                    -- if the player shoots newShots is a list of one shot, otherwise []
                    if input.action && (not level.cooldown) then
                        [ { x = level.player.x + sin level.player.angle * playerRadius
                          , y = level.player.y + cos level.player.angle * playerRadius
                          , speed = shotSpeed
                          , angle = level.player.angle
                          , ttl = shotTTL
                          }
                        ]
                    else
                        []
            in
                Level
                    { level
                        | accelerating = input.acceleration
                        , cooldown = input.action
                        , shots = updateShots level.shots level.asteroids input.delta ++ newShots
                        , asteroids = updateAsteroids level.asteroids level.player level.shots input.delta
                        , player = updatePlayer level.player input.direction input.acceleration input.delta
                        , lives =
                            if collision then
                                level.lives - 1
                            else
                                level.lives
                        , score =
                            let 
                                c = Collision.collisionAsteroids level.asteroids level.shots
                            in
                                level.score + (List.sum << List.map (\a -> (a.size + 1) * 10) <| c) - (List.length newShots)
                            -- an asteroid destroyed by shots gives points according to its size, a shot fired costs points
                    }



-- player movement


updatePlayer : Player -> Int -> Bool -> Time -> Player
updatePlayer p direction acceleration delta =
    let
        vx =
            p.vx
                + if acceleration then
                    sin p.angle * playerAcceleration * delta
                  else
                    0

        vy =
            p.vy
                + if acceleration then
                    cos p.angle * playerAcceleration * delta
                  else
                    0

        speed = sqrt <| vx * vx + vy * vy
    in
        { x = Helpers.sanx <| p.x + p.vx * delta
        , y = Helpers.sany <| p.y + p.vy * delta
        , vx =
            if speed > playerMaxSpeed then
                vx * playerMaxSpeed / speed
            else
                vx
        , vy =
            if speed > playerMaxSpeed then
                vy * playerMaxSpeed / speed
            else
                vy
        , angle = Helpers.sanangle <| p.angle + toFloat direction * playerDirectional * delta
        }



-- asteroid movement and filtering


updateAsteroids : List Asteroid -> Player -> List Shot -> Time -> List Asteroid
updateAsteroids la p ls delta =
    (++)
        (-- Old, moved Asteroids
         List.map
            (\a ->
                { a | x = Helpers.sanx <| a.x + (sin a.angle) * a.speed * delta, y = Helpers.sany <| a.y + (cos a.angle) * a.speed * delta }
            )
            << List.filter (\a -> (not <| Collision.collisionAsteroid a ls) && (not <| Collision.cornerCollision (Collision.toCircle (P p)) (Collision.toCircle (A a))))
            <| la
        )
        (-- New Asteroids created through collisions
         List.concat
            << List.map
                (\a ->
                    [ { a
                        | x = a.x + sin (pi / 2 - a.angle) * (toFloat a.size) * asteroidRadius
                        , y = a.y - cos (pi / 2 - a.angle) * (toFloat a.size) * asteroidRadius
                        , angle = Helpers.sanangle <| a.angle + 0.5
                        , size = a.size - 1
                      }
                    , { a
                        | x = a.x - sin (pi / 2 - a.angle) * (toFloat a.size) * asteroidRadius
                        , y = a.y + cos (pi / 2 - a.angle) * (toFloat a.size) * asteroidRadius
                        , angle = Helpers.sanangle <| a.angle - 0.5
                        , size = a.size - 1
                        , form = a.form + 1
                      }
                    ]
                )
            << List.filter (\a -> (Collision.collisionAsteroid a ls || Collision.cornerCollision (Collision.toCircle (P p)) (Collision.toCircle (A a))) && a.size > 0)
            <| la
        )



-- shot movement and filtering


updateShots : List Shot -> List Asteroid -> Time -> List Shot
updateShots ls la delta =
    List.map
        (\s ->
            { s
                | x = Helpers.sanx <| s.x + (sin s.angle) * s.speed * delta
                , y = Helpers.sany <| s.y + (cos s.angle) * s.speed * delta
                , ttl = s.ttl - delta
            }
        )
        << List.filter (\s -> (not <| Collision.collisionShot s la) && s.ttl >= 0)
        <| ls



------------------------------------------------------------------------------------------------------------------------


updatePause : Input -> GPause -> Game
updatePause input pause =
    if pause.level >= List.length levelList - 1 then
        End { defaultEnd | cooldown = True, score = pause.score }
    else if (not pause.cooldown) && input.action then
        let
            next = Helpers.index levelList (pause.level + 1) defaultLevel
        in
            Level { next | level = (pause.level + 1), score = pause.score, lives = pause.lives }
    else
        Pause { pause | cooldown = input.action }



------------------------------------------------------------------------------------------------------------------------


updateGameOver : Input -> GGameOver -> Game
updateGameOver input gameOver =
    if (not gameOver.cooldown) && input.action then
        Start
    else
        GameOver { gameOver | cooldown = input.action, score = gameOver.score }



------------------------------------------------------------------------------------------------------------------------
--MAIN


main =
    Signal.map view gameState


gameState : Signal Game
gameState =
    Signal.foldp update Start input


delta =
    Signal.map Time.inSeconds (Time.fps 35)


input : Signal Input
input =
    Signal.sampleOn delta
        <| Signal.map4
            Input
            Keyboard.space
            (Signal.map .x Keyboard.wasd)
            (Signal.map ((\v -> v > 0) << .y) Keyboard.wasd)
            delta
