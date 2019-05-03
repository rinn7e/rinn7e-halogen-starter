module Page.HeroDetail where

import BigPrelude
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Data.Page as Page
import Data.Config
import Shared.Helper as S

data Query a
  = NoOp a

type State = Unit

data Slot = Slot

data Message = 
  ChangeRoute Page.Page

derive instance eqSlot :: Eq Slot
derive instance ordSlot :: Ord Slot

component :: forall m. H.Component HH.HTML Query Unit Message m
component = H.component
  { initialState: const unit
  , render
  , eval
  , receiver: const Nothing
  }
  where
    render _ =
      HH.div [ S.cl "bg-green-light min-h-screen p-4"]
        [ HH.text "This is hero detail View "]

    eval :: Query ~> H.ComponentDSL State Query Message m
    eval query = case query of 
      NoOp n -> pure n

