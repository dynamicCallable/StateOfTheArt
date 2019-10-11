#!/usr/bin/perl

unless (-e '.git') {
    die "Put this script to your repo\n";
}

sub next_month {
    my %next_month_map = (
        Jan => "Feb",
        Feb => "Mar",
        Mar => "Apr",
        Apr => "Jun",
        Jun => "Jul",
        Jul => "Aug",
        Aug => "Sep",
        Sep => "Oct",
        Oct => "Nov",
        Nov => "Dec",
        Dec => "Jan"
    );

    my $input = shift;

    # Date:   Thu Oct 10 22:45:49 2019 +0100
    if ($input =~ /^Date:\s{3}[a-zA-Z]{3}\s([a-zA-Z]{3})\s[0-9:\s]*([0-9]{4})\s\+[0-9]{4}$/) {
        my $year = $2;
        $year++ if $month eq "Jan";
        my $month = $next_month_map{$1};
        return "$month $year";
    } else {
        die "Couldn't parse an input: $input\n";
    }
}

my $initial_commit_date = `git log --reverse | head -n3 | tail -n1`;

print "initial commit date: $initial_commit_date\n";

my $next = next_month $initial_commit_date;

print "next date is: $next\n";

die "fixme\n";

my $dir = shift;

my $current_branch = `git rev-parse --abbrev-ref HEAD`;

my $step = 10;

my @occurances = ();

sub check_for_occurances {
    my $count =`grep -roh Observable $dir | wc -l | tr -d " "`;
    push @occurances, $count;
}


system("git checkout $current_branch >/dev/null 2>&1");
