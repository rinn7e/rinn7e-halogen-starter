module Data.Error where

import BigPrelude
import Simple.JSON as SJ
import Foreign as F

type Model = Error 
  { code :: Int
  , reason :: String
  }

type Error a = 
  { error :: a}

decode :: String -> Either F.MultipleErrors Model 
decode = SJ.readJSON