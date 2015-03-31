#!/usr/bin/env python
import re

# module to count number of untranslated russian words
def numUntrans(hypothesis):
  retNum = 0
  for x in hypothesis.split():
    if re.match("\P{Cyrillic}*", x):
      retNum = retNum = 1
  return retNum
