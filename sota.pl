#!/usr/bin/perl

unless (-e '.git') {
    die "Put this script to your repo\n";
}

my $dir = shift;

my $current_branch = `git rev-parse --abbrev-ref HEAD`;

my $step = 10;

my @occurances = ();

sub check_for_occurances {
    push @occurances, `grep -roh Observable $dir | wc -l | tr -d " "`;
    my $current_total = $occurances[$#occurances];
    print "Current total: $current_total\n";
}

check_for_occurances;

while (true) {
    if (system("git checkout HEAD~$step >/dev/null 2>&1")) {
        last;
    }
    check_for_occurances;
}

print "Number of occurances:\n";

for (@occurances) {
    print;
}

system("git checkout $current_branch >/dev/null 2>&1");
