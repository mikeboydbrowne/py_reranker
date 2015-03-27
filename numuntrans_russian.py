#!/usr/bin/env python
import re
def numUntrans(hypothesis):
  retNum = 0
  for x in hypothesis.split():
    if re.match("\P{Cyrillic}*", x):
      retNum = retNum = 1
  return retNum
