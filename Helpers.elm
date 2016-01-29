module Helpers where

import Definitions exposing (..)

index : List a -> Int -> a -> a
index la i a =
  case List.head << List.drop i <| la of
    Nothing -> a
    Just x -> x

sanx : Float -> Float
sanx x = 
  if x < 0 then
    sanx <| x + gameWidth
  else if x > gameWidth then
    sanx <| x - gameWidth
  else
    x

sany : Float -> Float
sany y =
  if y < 0 then
    sany <| y + gameHeight
  else if y > gameHeight then
    sany <| y - gameHeight
  else
    y

sanangle : Float -> Float
sanangle a =
  if a < 0 then
    sanangle <| a + 2*pi
  else if a > 2*pi then
    sanangle <| a - 2*pi
  else
    a

dist : (Float, Float) -> (Float, Float) -> Float
dist (x1,y1) (x2,y2) =
  sqrt <| (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
