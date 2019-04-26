module Data.Page where

import BigPrelude
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)

data Page 
  = HeroListPage 
  | HeroDetailPage Int

derive instance eqPage :: Eq Page
derive instance ordPage :: Ord Page

derive instance genericPage :: Generic Page _
instance showPage :: Show Page where
  show = genericShow