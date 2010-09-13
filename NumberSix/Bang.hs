-- | Provides functions to deal with bang commands
--
module NumberSix.Bang
    ( -- * Obtaining parameters
      getBangCommand
    , getBangCommandText

      -- * Handlers
    , makeBangHandler

      -- * Reacting on events
    , onCommand
    , onBangCommand
    , onBangCommands
    ) where

import Control.Applicative ((<$>))
import Control.Monad (when, forM_)
import Data.Char (toLower, isSpace)

import NumberSix.Irc
import NumberSix.Util

-- | Get the bang commmand -- a user given command, for example, @!google@.
--
getBangCommand :: Irc String
getBangCommand = map toLower . head . words <$> getMessageText

-- | Get the text given to the bang command.
--
getBangCommandText :: Irc String
getBangCommandText = trim . dropWhile (not . isSpace) <$> getMessageText

-- | Create a simple handler with one bang hook. You should provide this
-- function with a function that produces a string to be written into the
-- channel, based on the bang command text.
--
makeBangHandler :: String                  -- ^ Handler name
                -> [String]                -- ^ Bang commands
                -> (String -> Irc String)  -- ^ Function
                -> Handler                 -- ^ Resulting handler
makeBangHandler name commands f = makeHandler name $ onBangCommands commands $
    getBangCommandText >>= f >>= writeChannel

-- | Execute an 'Irc' action only if the given bang command is executed.
--
onBangCommand :: String  -- ^ Bang command (e.g. @!google@)
              -> Irc ()  -- ^ Irc action to execute if match
              -> Irc ()  -- ^ Result
onBangCommand command = onBangCommands [command]

-- | Execute an 'Irc' action only if one of the given bang commands is executed.
--
onBangCommands :: [String]  -- ^ Bang commands (e.g. @!google@)
               -> Irc ()    -- ^ Irc action to execute if match
               -> Irc ()    -- ^ Result
onBangCommands commands irc = onCommand "privmsg" $ do
    actualCommand <- getBangCommand
    forM_ commands $ \c -> when (actualCommand == c) irc