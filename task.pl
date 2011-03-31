#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib      "$FindBin::Bin/lib";
use lib glob "$FindBin::Bin/modules/*/lib";

use Encode;
use Term::Encoding qw/term_encoding/;
use Pod::Usage;
use Getopt::Long;
use DateTime;

my (@tags, $due, $done, $todo);

GetOptions (
    't|tag=s' => \@tags,
    'd|due=s' => \$due,
    'done'    => \$done,
    'todo'    => \$todo,
);

use Task::MoCo;

my $user_name = 'onishi';

my %commands = (
    list => \&list_events,
    add  => \&add_events,
    done => \&done_events,
);

my $user = moco('User')->find(name => $user_name)
    or die "No such user ($user_name)";

my $command = $commands{shift || 'list'}
    or pod2usage(2);

$command->($user, @ARGV) or pod2usage(2);

sub list_events {
    my $user = shift;

    my $method = 'tasks';
    if ($done) {
        $method = 'done_tasks';
    } elsif ($todo) {
        $method = 'undone_tasks';
    }

    $user->$method->each(
        sub {
            print encode(term_encoding, $_->as_string)
        }
    );
    return 1;
}

sub add_events {
    my ($user, $task_name) = @_;
    return 0 unless defined $task_name and length $task_name;

    if (defined $due) {
        $due = eval { DateTime::Format::MySQL->parse_date($due) } or return 0;
    }

    my $task = $user->add_task(
        name => $task_name,
        due => $due,
        tags => DBIx::MoCo::List->new(\@tags),
    );
    print encode(term_encoding, $task->as_string);
    return 1;
}

sub done_events {
    my ($user, $task_id) = @_;
    return 0 unless $task_id;
    $user->set_task_status($task_id => 1)
      or die "Couldn't mark task with $task_id as done";
    return 1;
}

__END__

=head1 NAME

task.pl - a CLI for task app

=head1 SYNOPSIS

  task.pl list
    List all entries in your task list.

  task.pl add description
    Add a new entry to your task list.

  task.pl done <task_id>
    Mark task as done.

=cut
