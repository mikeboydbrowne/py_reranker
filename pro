#!/usr/bin/env python
from bleu import bleu_stats, bleu
import optparse
import random
import math
import sys

optparser = optparse.OptionParser()
optparser.add_option("-k", "--kbest-list", dest="input", default="data/dev+test.100best", help="100-best translation lists")
optparser.add_option("-n", "--gamma", dest="n", default=5000, type="int", help="Number of samplings")
optparser.add_option("-x", "--xi", dest="x", default=50, type='int', help='number of values with greatest score deviation')
optparser.add_option("-l", "--lm", dest="lm", default=-1.0, type="float", help="Language model weight")
optparser.add_option("-t", "--tm1", dest="tm1", default=-0.5, type="float", help="Translation model p(e|f) weight")
optparser.add_option("-s", "--tm2", dest="tm2", default=-0.5, type="float", help="Lexical translation model p_lex(f|e) weight")
(opts, _) = optparser.parse_args()
weights = {'p(e)'       : float(opts.lm) ,
          'p(e|f)'     : float(opts.tm1),
          'p_lex(f|e)' : float(opts.tm2)}


all_hyps = [pair.split(' ||| ') for pair in open(opts.input)]
all_refs = [pair.split('\n') for pair in open("data/dev.ref")]

num_sents = len(all_hyps) / 100 # of 100 sentence groupings

# for references 0 to 800
for s in xrange(0, num_sents):

  hyps_for_one_sent = all_hyps[s * 100:s * 100 + 100] # getting an array of 100 hypotheses

  V = {}

  # for the number of samplings
  for _ in range(0, opts.n):
    j1 = random.randrange(0, 100) # random index for first sentence
    j2 = random.randrange(0, 100) # random index for second sentence

    s1 = hyps_for_one_sent[j1][1].split(' ')  # random sentence #1
    s2 = hyps_for_one_sent[j2][1].split(' ')  # random sentence #2
    ref = all_refs[s][:-1]
    ref = ref[0].split(' ')

    # print "sentence one: " + str(s1)
    # print "sentence two: " + str(s2)
    # print "reference:    " + str(ref)

    # s1stats = bleu_stats(s1, ref)
    # s2stats = bleu_stats(s2, ref)

    # print s1stats
    # print s2stats

    g1 = bleu(list(bleu_stats(s1, ref))) # bleu score for sentence #1
    g2 = bleu(list(bleu_stats(s2, ref))) # bleu score for sentence #2

    # if the difference is above a threshold
    if abs(g1 - g2) > 0.05:

    #   # dump the results into the
      print 'I got here!'
      V[math.abs(g1 - g2)] = (hyps_for_one_sent[j1], hyps_for_one_sent[j2])
      print hyps_for_one_sent[j1]
      print hyps_for_one_sent[j2]

