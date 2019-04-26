module Main where

import BigPrelude
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Effect.Aff (forkAff)
import Router as Router

main :: Effect Unit
main = do
  log "Purescript is starting..."
  HA.runHalogenAff do
    body <- HA.awaitBody
    driver <- runUI Router.component unit body
    _ <- forkAff $ Router.routeSignal driver
    pure unit

