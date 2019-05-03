module Page.HeroList where

import BigPrelude
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Data.Env
import Data.Page
import Data.Config
import Shared.Helper as S

data Query a
  = NoOp a
  | GotoHeroDetail a

type State = Unit

data Slot = Slot

data Message = 
  ChangeRoute Page

derive instance eqSlot :: Eq Slot
derive instance ordSlot :: Ord Slot

component :: forall m
  .  MonadAsk Env m 
  => MonadAff m 
  => H.Component HH.HTML Query Unit Message m
component = H.component
  { initialState: const unit
  , render
  , eval
  , receiver: const Nothing
  }
  where
    render _ =
      HH.div [ S.cl "bg-purple-light min-h-screen p-4 flex flex-col"]
        [ HH.div [ S.cl "py-4 "] [ HH.text "This is hero List View " ] 
        , HH.div [] 
          [ HH.button [ S.cl "p-4 bg-yellow flex", S.onClick GotoHeroDetail ] [ HH.text "Go to Hero Detail (Using global message technique)"] ]
        ]

    eval :: Query ~> H.ComponentDSL State Query Message m
    eval query = case query of 
      NoOp n -> pure n
      GotoHeroDetail n -> do
        S.raiseG $ NavigateG $ HeroDetailPage 1
        pure n

