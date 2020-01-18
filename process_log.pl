#!/usr/bin/perl

$|++;

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

while (my $index = index_of \@args, '--extension', '-e') {
    my $extension = $args[$index + 1];
    splice @args, $index, 2;
    push @file_extensions, $extension;
}

$dir = shift @args;
$search_phrase = shift @args;

$git_dir = "$dir/.git";

die "No git directory in $git_dir" unless (-e $git_dir);

$git = "git --git-dir=\"$git_dir\"";

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

@log_options = qw(--pickaxe-regex -p);
push @log_options, '--reverse' if $reverse_index;

$log_command = "$git log -S \"$search_phrase\" @log_options";

open my $git_log, '-|', $log_command or die "Cannot do git log";

while (<$git_log>) {
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
        if (@file_extensions) {
            my $exts = join '|', @file_extensions;
            if (/\.($exts)$/) {
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

close $git_log;
