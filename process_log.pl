#!/usr/bin/perl

$|++;

$depth = $ENV{'DEPTH'};
$file_extensions = $ENV{'EXTENSIONS'};
$search_phrase = $ENV{'SEARCH_PHRASE'};

sub reset_state {
    $current_commit = "";
    $author = "";
    $date = "";
    $number_of_matches = 0;
    $skip = 0;
}

sub process_commit {
    my $result = join "\t", $current_commit, $author, $date, $number_of_matches;
    print $result, "\n";
    reset_state;
}

while (<>) {
    if (/^commit ([a-z0-9]+)/) {
        if ($current_commit) {
            if ($number_of_matches == 0) {
                reset_state;
            } elsif ($depth && --$depth <= 0) {
                last;
            } else {
                process_commit;
            }
        }
        $current_commit = $1;
    }

    next if /^\-\-\-/;

    if (/^\+\+\+/) {
        if ($file_extensions) {
            if (/\.($file_extensions)$/) {
                $skip = 0;
            } else {
                $skip = 1;
            }
        }
        next;
    }

    next if $skip;
    $author = $1 if /^Author: ([a-zA-Z \.]+) </;
    $date = $1 if /^Date: +([a-zA-Z0-9:+ ]+)$/;

    if (/^\+.*$search_phrase/) {
        $number_of_matches += 1;
    } elsif (/^\-.*$search_phrase/) {
        $number_of_matches -= 1;
    }
}
process_commit;
