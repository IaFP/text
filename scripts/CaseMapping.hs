import System.Environment
import System.IO

import Arsec
import CaseFolding
import SpecialCasing

main = do
  args <- getArgs
  let oname = case args of
                [] -> "../src/Data/Text/Internal/Fusion/CaseMapping.hs"
                [o] -> o
  psc <- parseSC "SpecialCasing.txt"
  pcf <- parseCF "CaseFolding.txt"
  scs <- case psc of
           Left err -> print err >> return undefined
           Right ms -> return ms
  cfs <- case pcf of
           Left err -> print err >> return undefined
           Right ms -> return ms
  h <- openFile oname WriteMode
  let comments = map ("--" ++) $
                 take 2 (cfComments cfs) ++ take 2 (scComments scs)
  mapM_ (hPutStrLn h) $
                      ["-- AUTOMATICALLY GENERATED - DO NOT EDIT"
                      ,"-- Generated by scripts/CaseMapping.hs"] ++
                      comments ++
                      [""
                      ,"{-# LANGUAGE LambdaCase, MagicHash, PartialTypeSignatures #-}"
                      ,"{-# OPTIONS_GHC -Wno-partial-type-signatures #-}"
                      ,"module Data.Text.Internal.Fusion.CaseMapping where"
                      ,"import GHC.Int"
                      ,"import GHC.Exts"
                      ,"unI64 :: Int64 -> _ {- unboxed Int64 -}"
                      ,"unI64 (I64# n) = n"
                      ,""]
  mapM_ (hPutStrLn h) (mapSC "upper" upper toUpper scs)
  mapM_ (hPutStrLn h) (mapSC "lower" lower toLower scs)
  mapM_ (hPutStrLn h) (mapSC "title" title toTitle scs)
  mapM_ (hPutStrLn h) (mapCF cfs)
  hClose h
