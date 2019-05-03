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
import Effect.Aff.AVar (AVar)
import Effect.Aff.AVar as AVar

import Data.Page
import Data.Env
import Page.HeroList as HeroList
import Page.HeroDetail as HeroDetail
import Shared.Helper as S
import Shared.Layout as Shared.Layout

data Query a
  = Init a
  | Goto Page a
  | HandleHeroDetailPage HeroDetail.Message a
  | HandleHeroListPage HeroList.Message a
  | ListenForGlobalQuery a

type State =
  { title :: String 
  , currentPage :: Page
  }

data GlobalQuery 
  = ChangeRouteG Page

type Input = Unit


init :: State
init = 
  { title: "Hello World" 
  , currentPage: HeroListPage
  }

component :: forall m r
   . MonadAff m
  => MonadAsk Env m 
  => H.Component HH.HTML Query Unit Void m
component = H.lifecycleParentComponent
  { initialState: const init
  
  , render
  , eval
  , initializer: Just (H.action Init)
  , finalizer: Nothing
  , receiver: const Nothing
  }
  where
    render :: State -> H.ParentHTML Query ChildQuery ChildSlot m
    render state = 
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

    eval :: Query ~> H.ParentDSL State Query ChildQuery ChildSlot Void m
    eval query =
      case query of
        Init n -> do
          S.log "Router Initialized"
          void $ H.fork $ eval $ ListenForGlobalQuery n
          pure n
        Goto page n -> do
          S.log $ show page
          handlePage page
          pure n
        ListenForGlobalQuery n -> do
          globalQuery <- asks _.globalQuery
          query <- H.liftAff $ AVar.take globalQuery
          case query of
            NavigateG page -> do
              handlePage page
              pure unit
            _-> do
              pure unit
          eval (ListenForGlobalQuery n)

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
    
    handleUrl page = do
      pushStateInterface <- asks _.pushStateInterface
      H.liftEffect $ do
        case page of
          HeroListPage -> 
            pushStateInterface.pushState (unsafeToForeign {}) $ path <> "/heroes"
          HeroDetailPage heroId -> 
            pushStateInterface.pushState (unsafeToForeign {}) $ path <> "/hero/" <> (show heroId)
            
      H.modify_ (_ { currentPage = page })
      where
        path = ""
    
    handlePage page = do
      currentPage <- H.gets (\s -> s.currentPage)
      case (currentPage == page) of
        true ->
          pure unit
        false -> do
          handleUrl page
          pure unit


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




