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
  }

defaultGameOver : GGameOver
defaultGameOver = 
  { level = 0
  , cooldown = False
  }

defaultPause : GPause
defaultPause = 
  { level = 0
  , cooldown = False
  }

defaultEnd : GEnd
defaultEnd =
  { cooldown = False }

-- LEVEL DEFINITIONS
-- These could potentially be move to an own file.
-- the level-value of GLevel can be ignored in the definition. It is later properly set by the update-function.

level0 : GLevel
level0 =
  { level = 0
  , player = defaultPlayer
  , asteroids =
    [ { x = gameWidth/4, y = gameHeight/4, angle = Helpers.sanangle <| 123.4, speed = 29, size = 1, form = 0 }
    , { x = 3 * gameWidth/4, y = gameHeight/4, angle = Helpers.sanangle <| 1234.5, speed = 21, size = 1, form = 1 }
    , { x = gameWidth/4, y = 3 * gameHeight/4, angle = Helpers.sanangle <| 12345.6, speed = 17, size = 1, form = 0 }
    , { x = 3 * gameWidth/4, y = 3 * gameHeight/4, angle = Helpers.sanangle <| 123456.7, speed = 23, size = 1, form = 1 }
    ]
  , shots = []
  , cooldown = True
  , accelerating = False
  }

level1 : GLevel
level1 =
  { level = 1
  , player = defaultPlayer
  , asteroids =
    [ { x = gameWidth/4, y = gameHeight/4, angle = Helpers.sanangle <| 1234.4, speed = 35, size = 2, form = 0 }
    , { x = 3 * gameWidth/4, y = gameHeight/4, angle = Helpers.sanangle <| 12344.5, speed = 26, size = 1, form = 1 }
    , { x = gameWidth/4, y = 3 * gameHeight/4, angle = Helpers.sanangle <| 123454.6, speed = 27, size = 2, form = 1}
    , { x = 3 * gameWidth/4, y = 3 * gameHeight/4, angle = Helpers.sanangle <| 1234564.7, speed = 23, size = 1, form = 0 }
    ]
  , shots = []
  , cooldown = True
  , accelerating = False
  }

-- List of levels later used by the actual game.

levelList : List GLevel
levelList = 
  [ level0
  , level1
  ]

