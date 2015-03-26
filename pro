#!/usr/bin/env python
import optparse
import sys

optparser = optparse.OptionParser()
optparser.add_option("-k", "--kbest-list", dest="input", default="data/dev+test.100best", help="100-best translation lists")
optparser.add_option("-l", "--lm", dest="lm", default=-1.0, type="float", help="Language model weight")
optparser.add_option("-t", "--tm1", dest="tm1", default=-0.5, type="float", help="Translation model p(e|f) weight")
optparser.add_option("-s", "--tm2", dest="tm2", default=-0.5, type="float", help="Lexical translation model p_lex(f|e) weight")
(opts, _) = optparser.parse_args()
weights = {'p(e)'       : float(opts.lm) ,
           'p(e|f)'     : float(opts.tm1),
           'p_lex(f|e)' : float(opts.tm2)}

all_hyps = [pair.split(' ||| ') for pair in open(opts.input)]
num_sents = len(all_hyps) / 100 # of 100 sentence groupings

# for references 0 to 800
for s in xrange(0, num_sents):
  hyps_for_one_sent = all_hyps[s * 100:s * 100 + 100] # getting an array of 100 hypotheses
  (best_score, best) = (-1e300, '')                   # tuple of best score, sentence
  for (num, hyp, feats) in hyps_for_one_sent:         # for each sentence in that hyp array
    score = 0.0
    for feat in feats.split(' '):                     # for each metric in the p(e|f), p(e), p_lex(e|f) grouping
      (k, v) = feat.split('=')                        # get each key-value pair
      score += weights[k] * float(v)                  # multiply it by its weight
    if score > best_score:                            # if the score is an improvement
      (best_score, best) = (score, hyp)               # update the record
  try:
    sys.stdout.write("%s\n" % best)                   # print the result once you've run through all 100 sentences
  except (Exception):
    sys.exit(1)

