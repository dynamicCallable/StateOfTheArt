#!/usr/bin/perl

@args = @ARGV;

sub index_of {
    my @array = @{ shift; };
    my @variants = @_;
    while (my ($index, $elem) = each @array) {
        foreach (@variants) {
            next if $elem ne $_;
            return $index;
        }
    }
}

($depth_index) = index_of \@args, '--depth', '-d';
($reverse_index) = index_of \@args, '--reverse', '-r';

if ($reverse_index) {
    splice @args, $reverse_index, 1;
}

if ($depth_index && $args[$depth_index + 1]) {
    $depth = $args[$depth_index + 1];
    splice @args, $depth_index, 2;
}

$dir = shift @args;
$search_phrase = shift @args;

$git_dir = "$dir/.git";

die "No git directory in $git_dir" unless (-e $git_dir);

$git = "git --git-dir=\"$git_dir\"";

$current_commit = "";
$author = "";
$number_of_matches = 0;

sub reset_state {
    $current_commit = "";
    $author = "";
    $number_of_matches = 0;
}

sub process_commit {
    my $result = join "\t", $current_commit, $author, $number_of_matches;
    print $result, "\n";
    reset_state;
}

$log_command = "$git log -S \"$search_phrase\" --pickaxe-regex -p";

if ($reverse_index) {
    $log_command .= " --reverse";
}

open my $git_log, '-|', $log_command or die "Cannot do git log";

while (<$git_log>) {
    if (/^commit ([a-z0-9]+)/) {
        if ($current_commit ne "") {
            last if $depth && --$depth <= 0;
            process_commit;
        }
        $current_commit = $1;
    }
    if (/^\+\+\+/ || /^\-\-\-/) {
        next;
    }
    if (/^Author: ([a-zA-Z \.]+) </) {
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
