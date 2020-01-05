#!/usr/bin/perl

$dir = shift;
$search_phrase = shift;

$git_dir = "$dir/.git";

die "No git directory in $git_dir" unless (-e $git_dir);

$git = "git --git-dir=\"$git_dir\"";

@history = ();

$current_commit = "";
$author = "";
$number_of_matches = 0;

sub reset_state {
    $current_commit = "";
    $author = "";
    $number_of_matches = 0;
}

sub process_commit {
    my %info = (
        "commit" => $current_commit,
        "author" => $author,
        "number_of_matches" => $number_of_matches,
    );
    push @history, \%info;
    reset_state;
}

open my $git_log, '-|', "$git log -S \"$search_phrase\" --pickaxe-regex -p" or die "Cannot do git log";

while (<$git_log>) {
    if (/^commit ([a-z0-9]+)/) {
        if ($current_commit ne "") {
            process_commit;
        }
        $current_commit = $1;
    }
    if (/^Author: ([a-zA-Z ]+) </) {
        $author = $1;
    }
    if (/^\+.*$search_phrase/) {
        $number_of_matches += 1;
    } elsif (/^\-.*$search_phrase/) {
        $number_of_matches -= 1;
    }
}
process_commit;

close $git_log;

foreach (@history) {
    my %info = %$_;

    my $author = $info{"author"};
    my $count = $info{"number_of_matches"};
    my $commit = $info{"commit"};

    print "$commit author: $author, count: $count\n";
}
