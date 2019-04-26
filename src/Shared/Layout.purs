module Shared.Layout where

import BigPrelude

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.HTML.Events as HE
import Shared.Helper as S

import Data.Page

view :: _
view {viewList, changeRouteQuery} = 
  HH.div_ 
    [ HH.div [ S.cl "flex"]
      -- [ HH.div [ S.onClick $ changeRouteQuery HeroListPage ] [ HH.text "Hero List"]
      -- , HH.div [ S.onClick $ changeRouteQuery $ HeroDetailPage 1 ] [ HH.text "Hero Detail"]
      -- ]
      [ navItem { page: HeroListPage, label: "Hero List"}
      , navItem { page: (HeroDetailPage 1), label: "Hero Detail 1"}
      ]
    , HH.div [ S.cl "mt-4"] viewList  
    ]

  where
    navItem {page, label }=
      HH.div 
        [ S.onClick $ changeRouteQuery page
        , S.cl "p-4 mr-2 bg-yellow cursor-pointer"
        ] 
        [ HH.text label]