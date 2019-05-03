---
title: Global Message passing inside Purescript Halogen
published: false
description: 
tags: purescript, halogen, javascript, functional programming
---


Normally in Router Component of Halogen, you would have a `Query` to change route like this:

```haskell
-- Router.purs
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
```

The handlePage function would look something like this:

```haskell
-- Router.purs
handlePage :: Page -> _
handlePage page = do
    currentPage <- H.gets (\s -> s.currentPage)
    case (currentPage == page) of
    true ->
        pure unit
    false -> do
        H.modify_ (_ { currentPage = page })
        pure unit
```

The problem with this is that to change route we will have to call `HE.onClick $ HE.input_ HeroListPage` when using in Router Component or when using in child component we would pass a message back to the parent component `H.raise $ ChangeRoute HeroListPage` and then we handle it like in `HandleHeroListPage` above. 

When changing route by the deep nested component, we would have to pass some kind of messages back to the top component(Router Component) to handle and this could be very annoying. 

A faster way is to simply change route with `href="/#/home"` but using the hash style url is problemtic for search engine as well as google analytic. 

Using href without hash `href="/home"` will reload the page and we do not want this. So that is why we have to change url by changing url manually using pushState.

Global Passing Message can be really handy in this situation, we can pass message directly to Router Component from any child component by using Avar within a AppM ReaderT Pattern.

Our AppM will look like this: 

```haskell
-- AppM.purs
newtype AppM a = AppM (ReaderT Env Aff a)

runAppM :: forall a. Env -> AppM a -> Aff a
runAppM e (AppM m) = runReaderT m e


-- Data.Env.purs
data GlobalMessage 
    = LogoutG 
    | NavigateG Page

type Env = 
    { globalMessage :: AVar GlobalMessage
    , pushStateInterface :: PushStateInterface
    }

-- Main.purs
main :: Effect Unit
main = do
    log "Purescript is starting..."
    HA.runHalogenAff do
        globalMessage <- AVar.empty
        pushStateInterface <- liftEffect $ RoutingP.makeInterface
        let 
            environment :: Env
            environment = { pushStateInterface, globalMessage}

            rootComponent :: H.Component HH.HTML Router.Query Router.Input Void Aff
            rootComponent = H.hoist (runAppM environment) Router.component
-- ...
```

Inside our Router, we will fork a Query that listen to AVar changes

```haskell
Init n -> do
    S.log "Router Initialized"
    void $ H.fork $ eval $ ListenForGlobalMessage n
    pure n
ListenForGlobalMessage n -> do
    globalMessage <- asks _.globalMessage
    query <- H.liftAff $ AVar.take globalMessage
    case query of
    NavigateG page -> do
        handlePage page
        pure unit
    _-> do
        pure unit
    eval (ListenForGlobalMessage n)
```

From within any child component, we call `raiseG` which basically put a new global message inside avar

```haskell
raiseG query = do
  globalMessage <- asks _.globalMessage
  H.liftAff $ AVar.put query globalMessage
```

Example inside a child component call HeroList, we just call raiseG with the message we want to pass to Router Component directly

```haskell
GotoHeroDetail n -> do
    S.raiseG $ NavigateG $ HeroDetailPage 1
    pure n

```

That's it, you can talk a look at fully working example inside my haloge starter project: https://github.com/rinn7e/rinn7e-halogen-starter

Thanks for reading!

