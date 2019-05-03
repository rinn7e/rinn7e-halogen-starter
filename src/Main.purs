module Main where

import BigPrelude
import Halogen as H
import Halogen.HTML as HH
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Effect.Aff (forkAff)
import Router as Router
import Routing.PushState as RoutingP
import Effect.Aff.AVar as AVar

import AppM
import Data.Env

main :: Effect Unit
main = do
  log "Purescript is starting..."
  HA.runHalogenAff do
    globalQuery <- AVar.empty
    pushStateInterface <- liftEffect $ RoutingP.makeInterface
    let 
      environment :: Env
      environment = { pushStateInterface, globalQuery}

      rootComponent :: H.Component HH.HTML Router.Query Router.Input Void Aff
      rootComponent = H.hoist (runAppM environment) Router.component

    body <- HA.awaitBody
    driver <- runUI rootComponent unit body
    void $ liftEffect $ RoutingP.matches Router.routing 
      (\ _ newRoute -> do
        liftEffect $ log $ "Parsing Route: " <> show newRoute 
        _ <- launchAff $ driver.query $ H.action $ Router.Goto newRoute
        pure unit
      )
      pushStateInterface    
    pure unit

