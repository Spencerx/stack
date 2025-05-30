{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

{-|
Module      : Data.Attoparsec.Args
Description : Parsing of Stack command line arguments.
License     : BSD-3-Clause

Parsing of Stack command line arguments.
-}

module Data.Attoparsec.Args
  ( EscapingMode (..)
  , argsParser
  , parseArgs
  , parseArgsFromString
  ) where

import           Data.Attoparsec.Text ( (<?>) )
import qualified Data.Attoparsec.Text as P
import qualified Data.Text as T
import           Stack.Prelude

-- | Mode for parsing escape characters.
data EscapingMode
  = Escaping
  | NoEscaping
  deriving (Enum, Eq, Show)

-- | Parse arguments using 'argsParser'.
parseArgs :: EscapingMode -> Text -> Either String [String]
parseArgs mode = P.parseOnly (argsParser mode)

-- | Parse using 'argsParser' from a string.
parseArgsFromString :: EscapingMode -> String -> Either String [String]
parseArgsFromString mode = P.parseOnly (argsParser mode) . T.pack

-- | A basic argument parser. It supports space-separated text, and string
-- quotation with identity escaping: \x -> x.
argsParser :: EscapingMode -> P.Parser [String]
argsParser mode =
     many
       (  P.skipSpace
       *> (quoted <|> unquoted)
       )
  <* P.skipSpace
  <* (P.endOfInput <?> "unterminated string")
 where
  quoted = P.char '"' *> str <* P.char '"'
  unquoted = P.many1 naked
  str = many
    ( case mode of
        Escaping -> escaped <|> nonquote
        NoEscaping -> nonquote
    )
  escaped = P.char '\\' *> P.anyChar
  nonquote = P.satisfy (/= '"')
  naked = P.satisfy (not . flip elem ("\" " :: String))
