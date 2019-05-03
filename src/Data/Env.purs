module Data.Env where

import BigPrelude
import Data.Page
import Effect.Aff.AVar (AVar)
import Routing.PushState (PushStateInterface)

data GlobalMessage 
  = LogoutG 
  | NavigateG Page

type Env = 
  { globalMessage :: AVar GlobalMessage
  , pushStateInterface :: PushStateInterface
  }

