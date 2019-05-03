module Shared.Helper where

import BigPrelude
import CSS hiding (map)

import Data.Array as DA
import Data.Error as Error
import Data.Foldable (foldr)
import Data.Int as DI
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Console as C
import Effect.Random (random)
import Foreign as F
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.CSS as HC
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.HTML.Properties.ARIA as AR
import Halogen.VDom.Driver (runUI)
import Web.Storage.Storage as Storage
import Effect.Aff.AVar as AVar


cl :: String -> _
cl str = 
  HP.class_ $ H.ClassName str

cl2 :: Array String -> _
cl2 arr = 
  HP.classes $ map (H.ClassName) arr

attr attrName value = 
  HP.attr (HH.AttrName attrName) value

-- log :: String -> _
log a =
  H.liftEffect $ C.log a

holder :: Int -> Int -> String
holder width height = 
  "https://via.placeholder.com/" <> show width <> "x" <> show height

holderSquare = holder 300 300

style inlineStyleString= 
  HP.attr (H.AttrName "style") 
    inlineStyleString

onClick :: _
onClick a = HE.onClick $ HE.input_ a
    -- """
    --   pointer-events: none;
    --   display: block;
    -- """

-- resStyle :: Array {rcl :: String, rstyle :: String} -> _
-- resStyle viewStyleList =
--   let
--     {rcl, rstyle} = 
--       foldr 
--         (\ a b -> {rcl: (a.rcl <> " " <> b.rcl), rstyle: (a.rstyle <> " " <> b.rstyle)} ) 
--         { rcl: "", rstyle: ""} 
--         viewStyleList
--   in
--     [ cl rcl, style rstyle ]  

res :: { a :: String, m :: String, l :: String} -> _
res {a, m, l}= cl (a <> " " <> m <> " " <> l)

data DecodeResult a b
  = DecodeDone a
  | DecodeUnexpected b
  | DecodeError (Array F.MultipleErrors)

chainDecode :: forall a b. String -> (String -> Either F.MultipleErrors a) -> (String -> Either F.MultipleErrors b) -> DecodeResult a b
chainDecode value decode errorDecode =
  case decode value of
    Right a -> 
      DecodeDone a
    Left err ->
      (case errorDecode value of
        Right b -> 
          DecodeUnexpected b
        Left err2 ->
          DecodeError [err, err2]
      )

newtype SessionString = SessionString String

removeTrailingZero :: Number -> String
removeTrailingZero num = 
  if (num `mod` 1.0 == 0.0) then
      show $ DI.round num
  else
      show num


filterMaybe :: Array (Maybe String) -> Array String
filterMaybe ls = ls
    # DA.filter (\x -> x /= Nothing) 
    # map 
        (\x -> case x of 
            Nothing -> ""
            Just a -> a
        )

raiseG query = do
  globalQuery <- asks _.globalQuery
  H.liftAff $ AVar.put query globalQuery