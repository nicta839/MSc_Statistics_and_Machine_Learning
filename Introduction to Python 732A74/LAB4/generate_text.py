#!/usr/bin/env python

import sys, getopt
import random
from text_stats import read_file, format_text, get_word_number, get_most_used_words, get_most_followed_words


def gen_text(starting_word, most_common_words_following, max_num_words):
    cur_word = starting_word
    msg = cur_word
    while (len(msg.split()) != max_num_words and most_common_words_following[cur_word]):
        successors = []
        probabilities = []
        for f_word in most_common_words_following[cur_word]:
            successors.append(f_word[0])
            probabilities.append(f_word[1])

        if (successors and probabilities):
            cur_word = random.choices(successors, probabilities)[0]
            msg = f"{msg} {cur_word}"
    return msg

def main(argv):
    # try:
    #     opts, args = getopt.getopt(argv,"hi:s:m:",["ifile=","sword=","maxnum="])
    # except getopt.GetoptError:
    #     print('generate_text.py -i <inputfile> -s <starting_word> -m max_num_words')
    #     sys.exit(2)
    # for opt, arg in opts:
    #     if opt == '-h':
    #         print('generate_text.py -i <inputfile> -s <starting_word> -m max_num_words')
    #         sys.exit()
    #     elif opt in ("-i", "--ifile"):
    #         inputfile = arg
    #     elif opt in ("-s", "--sword"):
    #         starting_word = str(arg)
    #     elif opt in ("-m", "--maxnum"):
    #         max_num_words = int(arg)

    if len(sys.argv) == 4:
        inputfile = sys.argv[1]
        starting_word = sys.argv[2]
        max_num_words = int(sys.argv[3])
    else:
        raise Exception("ArgumentError! Please confirm your call: generate_text.py <inputfile> <starting_word> <max_num_words>")

    inputfilestr = read_file(inputfile) 
    text = format_text(inputfilestr)
    words = text.split()
    number_words = get_word_number(words)
    most_common_words_following = get_most_followed_words(words, number_words)

    generated_text = gen_text(starting_word, most_common_words_following, max_num_words)
    print ("##############################")
    print (f"Inputfile: {inputfile}\nStarting word: {starting_word}\nMaximum number of words: {max_num_words}")
    print ("##############################")

    print (f"Generated text:\n{generated_text}")

if __name__ == "__main__":
   main(sys.argv[1:])