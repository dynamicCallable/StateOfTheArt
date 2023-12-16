#!/usr/bin/env perl

$|++;

$chart_height = 20;
# TODO: Fix. last + 1 is wrong. Need to fix ChartView
$description_string_length = 3 + 1 + 4 + 1; # JAN 2020
# TODO: Take from the arguments
$delimeter = "\t";
# TODO: Get from the terminal
$width_limit = 90;
$max = 0;

@leaderboard = ();
%scores = ();

@history = ();
%months = ();

sub make_info {
    my $name = shift;
    my %info = (
        name => $name,
        value => 0
    );
    return \%info;
}

sub print_chart {
    open CHART_VIEW, "| ./ChartView.swift $chart_height $description_string_length $max" or die "Couldn't start ChartView.swift";

    # TODO: Fix history slice count being always the size of width_limit
    my @history_slice = @history[-$width_limit..-1];
    my $count = @history_slice;
    die "count is incorrect" if $count > $width_limit;

    foreach my $info (@history_slice) {
        my $month = $info->{name};
        my $value = $info->{value};
        print CHART_VIEW "$value $month\n";
    }

    close CHART_VIEW;
    print "========================================\n"
}

sub process_month {
    my $month_name = shift;
    my $value = shift;

    $current_value = 0 unless $current_value;
    $current_value += $value;

    $max = $current_value unless $current_value <= $max;

    my $month = $months{$month_name};
    $month = make_info $month_name unless $month;
    $month->{value} += $current_value;
    $months{$month_name} = $month;

    $last_month_in_history = $history[-1];
    if ($last_month_in_history->{name} ne $month_name) {
        push @history, $month;
    }
    # TODO: Check if we need it, or there is no copy of values in perl
    # else {
    #     $history[-1] = $month;
    # }
    print_chart;
}

sub update_leaderboard {
    my $score = shift;
}

sub process_score {
    my $author_name = shift;
    my $value = shift;

    my $score = $scores{$author_name};
    $score = make_info $author_name unless $score;
    $score->{value} += $value;
    $scores{$author_name} = $score;

    update_leaderboard $score;
}

sub process_commit_info {
    my $month_name = shift;
    my $value = shift;
    process_month $month_name, $value;
}

while (<>) {
    if (/^[a-z0-9]+$delimeter.*$delimeter[a-zA-Z]{3} ([a-zA-Z]{3}) \d+ \d\d:\d\d:\d\d (\d{4}) \+\d{4}$delimeter(-?[0-9]+$)/) {
        my $month = "$1 $2";
        my $value = $3;
        process_commit_info $month, int $value;
    } else {
        die "couldn't parse the string: $_";
    }
}
