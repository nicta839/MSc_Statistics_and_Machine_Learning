#!/usr/bin/env python

import sys
import collections, re

class Word():
    def __init__(self, name, successor):
        self.name = name
        self.count = 1
        self.successors = [{successor:1}]

    def __eq__(self, other):
        return self.name == other.name

    def __repr__(self):
        return f"Word(name={self.name}, count={self.count}, successors={self.successors})"

    def increase_count(self):
        self.count += 1
    
    def add_successor(self, word):
        self.successors.append({word:1})

def read_file(input_file_name):
    try:
        with open(input_file_name) as f:
            input_file = f.read()
            return input_file
    except Exception:
        print("The file does not exist!")

def format_text(input_file):
    text = input_file.lower() # lowercase str
    regex = re.compile('[^a-zA-Z]')
    text = regex.sub(' ', text) # remove all non-alphabetical letters from the string
    return text

def get_letter_frequency(text):
    text = text.replace(" ", "")
    res = collections.Counter(text).most_common()
    return res

def get_word_number(words):
    return len(words)

def get_unique_word_number(words):
    unique_words = set(words)
    return len(unique_words)

def get_most_used_words(words):
    most_common_words = collections.Counter(words).most_common()
    return most_common_words

def get_most_followed_words(words, number_words):
    most_common_words_following = {}
    for ind, word in enumerate(words):
        if ind+1 < number_words:
            if word in most_common_words_following.keys():
                most_common_words_following[word].append(words[ind+1])
            else:
                most_common_words_following[word] = [words[ind+1]]

    for key, successors in most_common_words_following.items():
        most_common_words_following[key] = collections.Counter(successors).most_common()
    return most_common_words_following

def main(argv):
    if len(sys.argv) > 1:
        input_file_name = sys.argv[1]
        input_file = read_file(input_file_name)
        output_file = None
        if len(sys.argv) > 2:
            output_file = sys.argv[2]

        output_fh = open(output_file, 'w') if output_file else sys.stdout

        print(f"Input file: {input_file_name}", file=output_fh)

        # Format text
        text = format_text(input_file)

        # Alphabetic letter frequency
        letter_frequency = get_letter_frequency(text)
        print("---------------\nLetter | Count\n---------------", file=output_fh)
        for letter, count in letter_frequency:
            print(f"{letter}      | {count}", file=output_fh)
        print("---------------", file=output_fh)

        # Number of words
        words = text.split()
        number_words = get_word_number(words)   
        print(f"Number of words in {input_file_name}: {number_words}", file=output_fh)

        # Number of unique words
        number_unique_words = get_unique_word_number(words)
        print(f"Number of unique words in {input_file_name}: {number_unique_words}", file=output_fh)

        # Most commonly used words and the words most frequently following them
        most_common_words = get_most_used_words(words)
        most_common_words_following = get_most_followed_words(words, number_words)

        print("---------------", file=output_fh)
        for word in most_common_words[0:10]:
            print(f"{word[0]} ({word[1]} occurences)\n", file=output_fh)
            following_words = most_common_words_following[word[0]]
            for f_word in following_words[0:5]:
                print(f"-- {f_word[0]}, {f_word[1]}\n", file=output_fh)
            print("---------------", file=output_fh)

        if output_file:
            output_fh.close()

    else:
        raise Exception("Input file is missing. Please run the script again using text_stats.py <file_name>")

if __name__ == "__main__":
    main(sys.argv[1:])