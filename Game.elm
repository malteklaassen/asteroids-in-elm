module Game where

import Types exposing (..)
import Definitions exposing (..)
import Helpers

-- default values for a bunch of types. These are often used as a basis for partial updates or as a fallback for the index function

defaultPlayer : Player
defaultPlayer =
  { x = gameWidth/2
  , y = gameHeight/2
  , vx = 0
  , vy = 0
  , angle = 0
  }

defaultLevel : GLevel
defaultLevel =
  { level = 0
  , player = defaultPlayer
  , asteroids = []
  , shots = []
  , cooldown = False
  , accelerating = False
  , score = 0
  , lives = 0
  }

defaultGameOver : GGameOver
defaultGameOver = 
  { level = 0
  , cooldown = False
  , score = 0
  }

defaultPause : GPause
defaultPause = 
  { level = 0
  , cooldown = False
  , score = 0
  , lives = 0
  }

defaultEnd : GEnd
defaultEnd =
  { cooldown = False
  , score = 0
  }
