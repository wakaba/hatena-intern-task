package Task::MoCo::Tag;
use strict;
use warnings;
use base qw(Task::MoCo);
use Task::MoCo;

__PACKAGE__->table('tag');

__PACKAGE__->utf8_columns(qw(name));

sub user {
    my $self = shift;
    return moco('User')->find(id => $self->user_id);
}

sub task {
    my $self = shift;
    return moco('Task')->find(id => $self->task_id);
}

1;
