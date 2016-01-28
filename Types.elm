module Types where

import Time

{-
  Game is representing the actual state of the game.
  There are 5 basic states:
    Start -> Initial starting state
    Level -> An actual game level is being played. The state of the level is given in GLevel
    GameOver -> The ship has been destroyed. Information like score is given in GGameOver
    Pause -> A non-final level has been completed, the game is waiting for the user to continue. GPause cotains cross-level information like score, lives, last played level.
    End -> The final level has been completed. GEnd gives information of score etc.
-}

type Game = Start | Level GLevel | GameOver GGameOver | Pause GPause | End GEnd

type alias GLevel =
  { level        : Int
  , player       : Player
  , asteroids    : List Asteroid
  , shots        : List Shot
  , cooldown     : Bool
  , accelerating : Bool
  , score        : Int
  , lives        : Int
  }

type alias GGameOver =
  { level    : Int
  , cooldown : Bool
  , score    : Int
  }

type alias GPause = 
  { level    : Int
  , cooldown : Bool
  , score    : Int
  , lives    : Int
  }

type alias GEnd = 
  { cooldown : Bool
  , score    : Int
  }

type alias Input = 
  { action       : Bool
  , direction    : Int
  , acceleration : Bool
  , delta        : Time.Time
  }

type alias Player = 
  { x     : Float
  , y     : Float
  , vx    : Float
  , vy    : Float
  , angle : Float
  }

type alias Asteroid =
  { x     : Float
  , y     : Float
  , speed : Float
  , angle : Float
  , size  : Int
  , form  : Int
  }

type alias Shot =
  { x     : Float
  , y     : Float
  , speed : Float
  , angle : Float
  , ttl   : Time.Time
  }
