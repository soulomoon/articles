import Data.List
import System.Directory


readMe :: FilePath
readMe = "README.md"

main :: IO ()
main = do names <- getCurrentDirectory >>= getDirectoryContents
          getCurrentDirectory >>= print
          let filtered = filter filterFunc names
          print filtered
          let content = foldMap nameToLink filtered
          print content
          readMePath <- fmap (++readMe) getCurrentDirectory 
          print readMePath
          writeFile readMePath $ "# Articles" ++ content 

nameToLink :: String -> String
nameToLink name = "\n[" ++ takeWhile (/='.') name ++ "](" ++ name ++ ")"

filterFunc :: String -> Bool
filterFunc name = 
  any (`isSuffixOf` name) [".md"] 
  && (name /= readMe)
