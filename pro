#!/usr/bin/env python
from bleu import bleu_stats, bleu
import operator
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

  ref = all_refs[s][:-1]
  ref = ref[0].split(' ')
  hyps_for_one_sent = all_hyps[s * 100:s * 100 + 100] # getting an array of 100 hypotheses

  V = {}

  # for the number of samplings
  for _ in range(0, opts.n):
    j1 = random.randrange(0, 100) # random index for first sentence
    j2 = random.randrange(0, 100) # random index for second sentence

    s1 = hyps_for_one_sent[j1][1].split(' ')  # random sentence #1
    s2 = hyps_for_one_sent[j2][1].split(' ')  # random sentence #2

    g1 = bleu(list(bleu_stats(s1, ref))) # bleu score for sentence #1
    g2 = bleu(list(bleu_stats(s2, ref))) # bleu score for sentence #2

    # print "random #1 ........... " + str(j1)
    # print "random #2 ........... " + str(j2)
    # print "sentence one ........ " + str(s1)
    # print "sentence two ........ " + str(s2)
    # print "reference ........... " + str(ref)
    # print "bleu one ............ " + str(g1)
    # print "bleu two ............ " + str(g2)
    # print "bleu differential ... " + str(abs(g1 - g2))
    # print "\n"

    # if the difference is above a threshold
    if abs(g1 - g2) > 0.005:

      # print "I get here!"

      # dump the results into the
      V[abs(g1 - g2)] = (hyps_for_one_sent[j1], hyps_for_one_sent[j2])


  sorted_keys = sorted(V.keys(), reverse=True)[:opts.x]

  # print sorted_keys

  # for the xi best in entries
  for i in sorted_keys:

    # getting values out of V
    (hyp_one, hyp_two) = V[i]
    hyp_one_sent = hyp_one[1].split(' ')
    hyp_two_sent = hyp_two[1].split(' ')
    hyp_one_x = hyp_one[2].split(' ')
    hyp_two_x = hyp_two[2].split(' ')

    # caluclating bleu score
    hyp_one_bleu = bleu(list(bleu_stats(s1, ref)))
    hyp_two_bleu = bleu(list(bleu_stats(s2, ref)))

    # getting x vector
    x1_vector = []
    x2_vector = []
    for i in hyp_one_x:
      x1_vector.append(float(i.split('=')[1]))

    for i in hyp_two_x:
      x2_vector.append(float(i.split('=')[1]))

    # calculating first output value
    first_output_x = [x1 - x2 for (x1, x2) in zip(x1_vector, x2_vector)]
    first_output_sign = ''

    # for (i, j) in (x1_vector, x2_vector):
    #   first_output_x.append(i - j)

    if (hyp_one_bleu - hyp_two_bleu) < 0:
      first_output_sign = '-'
    else:
      first_output_sign = "+"

    # calculating second output value
    second_output_x = [x1 - x2 for (x2, x1) in zip(x1_vector, x2_vector)]
    second_output_sign = ''
    # for (i, j) in enumerate(x2_vector, x1_vector):
    #   second_output_x.append(i - j)

    if (hyp_two_bleu - hyp_one_bleu) < 0:
      second_output_sign = '-'
    else:
      second_output_sign = "+"

    # print hyp_one
    # print hyp_two
    # print x1_vector
    # print x2_vector
    try:
      sys.stdout.write("%s\n" % ("(" + str(first_output_x) + ", " + first_output_sign + ")"))
      sys.stdout.write("%s\n" % ("(" + str(second_output_x) + ", " + second_output_sign + ")"))
    except (Exception):
        sys.exit(1)
    # print


