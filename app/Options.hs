module Options (Options (..), parseOptions) where

import Data.Foldable (fold)
import Options.Applicative
import Test.Mendel.MutationOperator
import Test.Mendel.MutationVariant

data Options
    = MutateFile MuVariant FilePath
    | Version
    deriving (Eq, Show)

muVariantParser :: ReadM MuVariant
muVariantParser =
    str >>= \s -> case s of
        "ReverseString" -> pure ReverseString
        "ReverseClausesInPatternMatch" -> pure ReverseClausesInPatternMatch
        "SwapPlusMinus" -> pure SwapPlusMinus
        "SwapIfElse" -> pure SwapIfElse
        _ ->
            readerError
                "Accepted mutation operators are: ReverseString, ReverseClausesInPatternMatch, SwapPlusMinus, SwapIfElse"

muVariantParser' :: Parser MuVariant
muVariantParser' = argument muVariantParser (metavar "MUOP")

mutateFileParser :: Parser Options
mutateFileParser = MutateFile <$> muVariantParser' <*> argument str (metavar "FILE")

versionParser :: Parser Options
versionParser = Version <$ flag' () (long "version" <> help "Display version")

optionsParser :: ParserInfo Options
optionsParser = info (helper <*> (versionParser <|> mutateFileParser)) mods
  where
    mods =
        fold
            [ fullDesc
            , progDesc "Mendel is a tool for programmatically injecting faults into Haskell programs"
            , header "Mendel - mutant generation for Haskell"
            ]

parseOptions :: IO Options
parseOptions = customExecParser (prefs showHelpOnError) optionsParser
