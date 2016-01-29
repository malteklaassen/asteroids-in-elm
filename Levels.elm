module Levels (..) where

import Types exposing (..)
import Definitions exposing (..)
import Game exposing (..)
import Helpers


-- LEVEL DEFINITIONS
-- These could potentially be move to an own file.
-- the level-value of GLevel can be ignored in the definition. It is later properly set by the update-function.


level0 : GLevel
level0 =
    { level = 0
    , player = defaultPlayer
    , asteroids =
        [ { x = gameWidth / 4, y = gameHeight / 4, angle = Helpers.sanangle <| 123.4, speed = 29, size = 1, form = 0 }
        , { x = 3 * gameWidth / 4, y = gameHeight / 4, angle = Helpers.sanangle <| 1234.5, speed = 21, size = 1, form = 1 }
        , { x = gameWidth / 4, y = 3 * gameHeight / 4, angle = Helpers.sanangle <| 12345.6, speed = 17, size = 1, form = 0 }
        , { x = 3 * gameWidth / 4, y = 3 * gameHeight / 4, angle = Helpers.sanangle <| 123456.7, speed = 23, size = 1, form = 1 }
        ]
    , shots = []
    , cooldown = True
    , accelerating = False
    , lives = 0
    , score = 0
    }


level1 : GLevel
level1 =
    { level = 1
    , player = defaultPlayer
    , asteroids =
        [ { x = gameWidth / 4, y = gameHeight / 4, angle = Helpers.sanangle <| 1234.4, speed = 35, size = 2, form = 0 }
        , { x = 3 * gameWidth / 4, y = gameHeight / 4, angle = Helpers.sanangle <| 12344.5, speed = 26, size = 1, form = 1 }
        , { x = gameWidth / 4, y = 3 * gameHeight / 4, angle = Helpers.sanangle <| 123454.6, speed = 27, size = 2, form = 1 }
        , { x = 3 * gameWidth / 4, y = 3 * gameHeight / 4, angle = Helpers.sanangle <| 1234564.7, speed = 23, size = 1, form = 0 }
        ]
    , shots = []
    , cooldown = True
    , accelerating = False
    , lives = 0
    , score = 0
    }


level2 : GLevel
level2 =
    { level = 2
    , player = defaultPlayer
    , asteroids =
        [ { x = gameWidth / 4, y = gameHeight / 4, angle = 1, speed = 40, size = 3, form = 2 }
        , { x = 3 * gameWidth / 5, y = gameHeight / 6, angle = 3, speed = 38, size = 2, form = 3 }
        , { x = 5 * gameWidth / 7, y = 7 * gameHeight / 9, angle = 28, speed = 29, size = 3, form = 4 }
        , { x = 1 * gameWidth / 5, y = gameHeight / 2, angle = 291, speed = 35, size = 2, form = 1 }
        , { x = 2 * gameWidth / 6, y = 5 * gameHeight / 7, angle = 192, speed = 38, size = 1, form = 0 }
        , { x = 1 * gameWidth / 4, y = 3 * gameHeight / 7, angle = 19, speed = 42, size = 4, form = 2 }
        ]
    , shots = []
    , cooldown = True
    , accelerating = False
    , lives = 0
    , score = 0
    }



-- List of levels later used by the actual game.


levelList : List GLevel
levelList =
    [ level0
    , level1
    , level2
    ]
