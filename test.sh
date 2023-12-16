#!/usr/bin/env bash


export EXTENSIONS="h|m|swift"
export SEARCH_PHRASE="\b(BPF)?Observable\b" 
# TODO: Add search phrase here
cat tmp | ./process_log.pl # | ./score.pl
