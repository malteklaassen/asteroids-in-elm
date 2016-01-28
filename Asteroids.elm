module Main where

--IMPORTS
import Time exposing (Time)
import Keyboard
import Text

--CUSTOM IMPORTS
import Game exposing (levelList, defaultLevel, defaultGameOver, defaultPause, defaultEnd)
import Types exposing (..)
import Definitions exposing (..)
import Helpers
import Collision
import Show exposing (view)

--UPDATE
update : Input -> Game -> Game
update input game =
  case game of
    Start ->
      if input.action then
        Level (Helpers.index levelList 0 defaultLevel)
      else
        game
    Level level ->
      if Collision.collisionPlayer level.player level.asteroids then
        GameOver { defaultGameOver | cooldown = True , level = level.level }
      else if List.isEmpty level.asteroids then
        if level.level >= List.length levelList - 1 then 
          End { defaultEnd | cooldown = True }
        else
          Pause { defaultPause | cooldown = True , level = level.level }
      else 
        let
          newShots =
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
              , asteroids = updateAsteroids level.asteroids level.shots input.delta
              , player = updatePlayer level.player input.direction input.acceleration input.delta
            }
    Pause pause ->
      if pause.level >= List.length levelList - 1 then
        End { defaultEnd | cooldown = True }
      else
        if (not pause.cooldown) && input.action then
          let
            next = Helpers.index levelList (pause.level + 1) defaultLevel
          in
            Level { next | level = (pause.level + 1) }
        else
          Pause { pause | cooldown = input.action }
    GameOver gameOver ->
      if (not gameOver.cooldown) && input.action then
        Start
      else
        GameOver { gameOver | cooldown = input.action }
    End end ->
      game

updatePlayer : Player -> Int -> Bool -> Time -> Player
updatePlayer p direction acceleration delta =
  let
    vx = p.vx + if acceleration then sin p.angle * playerAcceleration * delta else 0
    vy = p.vy + if acceleration then cos p.angle * playerAcceleration * delta else 0
    speed = sqrt <| vx * vx + vy * vy
  in
    { x = Helpers.sanx <| p.x + p.vx * delta
    , y = Helpers.sany <| p.y + p.vy * delta
    , vx = if speed > playerMaxSpeed then vx * playerMaxSpeed / speed else vx
    , vy = if speed > playerMaxSpeed then vy * playerMaxSpeed / speed else vy
    , angle = Helpers.sanangle <| p.angle + toFloat direction * playerDirectional * delta
    }

updateAsteroids : List Asteroid -> List Shot -> Time -> List Asteroid
updateAsteroids la ls delta =
  (++)
    ( -- Old, moved Asteroids
      List.map (\a ->
        { a | x = Helpers.sanx <| a.x + (sin a.angle) * a.speed * delta , y = Helpers.sany <| a.y + (cos a.angle) * a.speed * delta }
      ) <<
      List.filter (\a -> (not <| Collision.collisionAsteroid a ls)) <|
      la
    )
    ( -- New Asteroids created through collisions
      List.concat <<
      List.map 
        (\a ->
          [ { a 
              | x = a.x + sin (pi/2 - a.angle) * (toFloat a.size) * asteroidRadius
              , y = a.y - cos (pi/2 - a.angle) * (toFloat a.size) * asteroidRadius
              , angle = Helpers.sanangle <| a.angle + 0.5
              , size = a.size - 1
            }
          , { a
              | x = a.x - sin (pi/2 - a.angle) * (toFloat a.size) * asteroidRadius
              , y = a.y + cos (pi/2 - a.angle) * (toFloat a.size) * asteroidRadius
              , angle = Helpers.sanangle <| a.angle - 0.5
              , size = a.size - 1
              , form = a.form + 1
            }
          ]
        ) <<
      List.filter (\a -> Collision.collisionAsteroid a ls && a.size > 0) <|
      la
    )
  

updateShots : List Shot -> List Asteroid -> Time -> List Shot
updateShots ls la delta = 
  List.map (\s -> 
    { s
      | x = Helpers.sanx <| s.x + (sin s.angle) * s.speed * delta
      , y = Helpers.sany <| s.y + (cos s.angle) * s.speed * delta
      , ttl = s.ttl - delta
    }
  ) <<
  List.filter (\s -> (not <| Collision.collisionShot s la)) <<
  List.filter (\s -> s.ttl >= 0) <|
  ls

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
  Signal.sampleOn delta <|
    Signal.map4 Input
      Keyboard.space
      (Signal.map .x Keyboard.wasd)
      (Signal.map ((\v -> v > 0) << .y) Keyboard.wasd)
      delta
