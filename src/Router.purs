module Router where

import BigPrelude

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.HTML.Events as HE
import Halogen.HTML.CSS as HC
import CSS as C
import Data.Functor.Coproduct.Nested
import Data.Either.Nested
import Data.String (toLower)
import Halogen.Component.ChildPath as HCC
import Affjax as AX
import Affjax.ResponseFormat as ResponseFormat
import Data.Argonaut.Core as J
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Effect.Class.Console (log)
import Data.Time.Duration as T
import Data.Bifunctor (lmap)
import Simple.JSON (readJSON)
import Control.Monad.Except (runExcept)
import Foreign (unsafeToForeign)  
import Routing.PushState as RoutingP
import Routing.Hash as RoutingH
import Routing.Match as RoutingM --(Match, lit, num)
import Routing.Match (root, lit, end, num)
import Routing.Match as RM 
import Data.Foldable (oneOf)

import Data.Page
import Page.HeroList as HeroList
import Page.HeroDetail as HeroDetail
import Shared.Helper as S
import Shared.Layout as Shared.Layout

data Query a
  = Init a
  | Goto Page a
  | HandleHeroDetailPage HeroDetail.Message a
  | HandleHeroListPage HeroList.Message a

type State =
  { title :: String 
  , currentPage :: Page
  }



init :: State
init = 
  { title: "Hello World" 
  , currentPage: HeroListPage
  }

component :: H.Component HH.HTML Query Unit Void Aff
component = H.lifecycleParentComponent
  { initialState: const init
  , render
  , eval
  , initializer: Just (H.action Init)
  , finalizer: Nothing
  , receiver: const Nothing
  }
  where
    render :: State -> H.ParentHTML Query ChildQuery ChildSlot Aff
    render state = 
      view state 

    eval :: Query ~> H.ParentDSL State Query ChildQuery ChildSlot Void Aff
    eval query =
      case query of
        Init n -> do
          S.log "Router Initialized"
          pure n
        Goto page n -> do
          S.log $ show page
          handlePage page
          pure n
        HandleHeroListPage msg n -> do
          case msg of
            HeroList.ChangeRoute page -> do
              handlePage page
              pure n
            _ ->
              pure n
        HandleHeroDetailPage msg n -> do
          case msg of
            HeroDetail.ChangeRoute page -> do
              handlePage page
              pure n
            _ ->
              pure n


routing :: _
routing = 
  oneOf
    [ HeroListPage        <$ (rootRoute <* end)
    , HeroListPage        <$ (rootRoute *> lit "heroes"     <* end)
    -- Match /hero/:id (It is not sure why this has to be written this way, 
    -- need more detail from `Routing` module)
    , rootRoute *> (HeroDetailPage <$ lit "hero" <*> RM.int <* end) 
    ]
  where
    rootRoute = root

handleUrl page = do
  H.liftEffect $ do
    pushStateInterface <- RoutingP.makeInterface
    case page of
      HeroListPage -> 
        pushStateInterface.pushState (unsafeToForeign {}) $ path <> "/heroes"
      HeroDetailPage heroId -> 
        pushStateInterface.pushState (unsafeToForeign {}) $ path <> "/hero/" <> (show heroId)
        
  H.modify_ (_ { currentPage = page })
  where
    path = ""

type ChildQuery = 
  Coproduct2
    HeroList.Query
    HeroDetail.Query

type ChildSlot = 
  Either2
    HeroList.Slot
    HeroDetail.Slot

cpHeroList = HCC.cp1
cpHeroDetail = HCC.cp2

handlePage page = do
  currentPage <- H.gets (\s -> s.currentPage)
  case (currentPage == page) of
    true ->
      pure unit
    false -> do
      handleUrl page
      pure unit

routeSignal :: H.HalogenIO Query Void Aff -> Aff (Effect Unit)
routeSignal driver = liftEffect do
    pushStateInterface <- RoutingP.makeInterface
    RoutingP.matches routing 
      (\ _ newRoute -> do
        liftEffect $ log $ "Parsing Route: " <> show newRoute 
        _ <- launchAff $ driver.query $ H.action $ Goto newRoute
        pure unit
      )
      pushStateInterface        

view :: State -> _
view state = 
  case state.currentPage of
    HeroListPage ->
      Shared.Layout.view 
        { viewList: [ HH.slot' cpHeroList HeroList.Slot HeroList.component unit (HE.input HandleHeroListPage) ]
        , changeRouteQuery: Goto
        -- , header: (HH.slot' cpCart Cart.Slot Cart.component state.selectProduct (HE.input HandleCart) )
        }
    HeroDetailPage id ->
      Shared.Layout.view 
        { viewList: [ HH.slot' cpHeroDetail HeroDetail.Slot HeroDetail.component unit (HE.input HandleHeroDetailPage) ]
        , changeRouteQuery: Goto
        }