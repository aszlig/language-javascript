module Language.JavaScript.Parser.Parser (
   -- * Parsing
     parse
   , readJs
   -- , readJsKeepComments
   , parseFile
   -- * Parsing expressions
   -- parseExpr
   , parseUsing
   , showStripped
   , showStrippedMaybe
   ) where

import Language.JavaScript.Parser.ParseError
import Language.JavaScript.Parser.Grammar5
import Language.JavaScript.Parser.Lexer
import qualified Language.JavaScript.Parser.AST as AST


-- | Parse one compound statement, or a sequence of simple statements.
-- Generally used for interactive input, such as from the command line of an interpreter.
-- Return comments in addition to the parsed statements.
parse :: String -- ^ The input stream (Javascript source code).
      -> String -- ^ The name of the Javascript source (filename or input device).
      -> Either String  AST.JSNode
         -- ^ An error or maybe the abstract syntax tree (AST) of zero
         -- or more Javascript statements, plus comments.
parse input _srcName = runAlex input parseProgram


readJs :: String -> AST.JSNode
readJs input = do
  case (parse input "src") of
    Left msg -> error (show msg)
    Right p -> p

parseFile :: FilePath -> IO AST.JSNode
parseFile filename =
  do
     x <- readFile (filename)
     return $ readJs x

showStripped :: AST.JSNode -> String
showStripped ast = AST.showStripped ast

showStrippedMaybe :: Show a => Either a AST.JSNode -> String
showStrippedMaybe maybeAst = do
  case maybeAst of
    Left msg -> "Left (" ++ show msg ++ ")"
    Right p -> "Right (" ++ AST.showStripped p ++ ")"

-- | Parse one compound statement, or a sequence of simple statements.
-- Generally used for interactive input, such as from the command line of an interpreter.
-- Return comments in addition to the parsed statements.
parseUsing ::
      Alex AST.JSNode -- ^ The parser to be used
      -> String -- ^ The input stream (Javascript source code).
      -> String -- ^ The name of the Javascript source (filename or input device).
      -> Either String AST.JSNode
         -- ^ An error or maybe the abstract syntax tree (AST) of zero
         -- or more Javascript statements, plus comments.

parseUsing p input _srcName = runAlex input p

