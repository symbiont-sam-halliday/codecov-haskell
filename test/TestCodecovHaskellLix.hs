{-# OPTIONS_GHC -fno-warn-missing-signatures #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module TestCodecovHaskellLix where

import Test.HUnit
import Trace.Hpc.Codecov.Lix
import Trace.Hpc.Codecov.Types

testToHit = "toHit" ~: [
    Irrelevant @=? toHit [],
    None       @=? toHit [False],
    None       @=? toHit [False, False],
    Full       @=? toHit [False, True],
    Full       @=? toHit [True, False],
    Full       @=? toHit [False, False, True],
    Full       @=? toHit [False, True, False],
    Full       @=? toHit [True, False, False],
    Full       @=? toHit [True],
    Full       @=? toHit [True, True]]

testLix = "Lix" ~: [testToHit]
