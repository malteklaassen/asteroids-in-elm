module Definitions where

-- Size of the "window"
(gameWidth, gameHeight) = (800, 600)

-- Sizes of different objects for the purpose of collision etc.
-- The visual represantion mostly DOESNT use these values as stretching Forms really kills the performance (?)
-- As asteroids can have different sizes asteroidSize is only a factor. The real size is ((asteroid.size + 1) * asteroidRadius)
playerRadius = 15.0
asteroidRadius = 10.0
shotRadius = 1.0

-- Values used in the update functions, e.g. for movement speed. Playing around with these values could be required to improve the "balance"
playerAcceleration = 60.0
playerDirectional = 3.0
playerMaxSpeed = 200.0
shotSpeed = 300.0

shotTTL = 2.0
