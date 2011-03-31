package Task::MoCo::User;
use strict;
use warnings;
use base qw(Task::MoCo);
use Task::MoCo;

__PACKAGE__->table('user');

sub tasks {
    my $self = shift;
    return scalar moco('Task')->search(
        where => {
            user_id => $self->id,
        },
        order => 'name ASC',
    );
}

sub done_tasks {
    my $self = shift;
    return scalar moco('Task')->search(
        where => {
            user_id => $self->id,
            status => 1,
        },
        order => 'name ASC',
    );
}

sub undone_tasks {
    my $self = shift;
    return scalar moco('Task')->search(
        where => {
            user_id => $self->id,
            status => 0,
        },
        order => 'name ASC',
    );
}

sub set_task_status {
    my ($self, $task_id, $new_status) = @_;
    
    my $task = moco('Task')->find(
        id => $task_id,
        user_id => $self->id,
    ) or return;

    $task->status($new_status);
}

sub add_task {
    my ($self, %args) = @_;
    return undef unless defined $args{name} and length $args{name};

    my %create = (
        name => $args{name},
        user_id => $self->id,
        status => 0,
    );

    if ($args{due}) {
        $create{due} = DateTime::Format::MySQL->format_date($args{due});
    }
    
    my $task = moco('Task')->create(%create);

    if ($args{tags}) {
        $args{tags}->uniq->each(sub {
            $task->add_tag($_);
        });
    }
    
    return $task;
}

sub tags {
    my $self = shift;
    return scalar moco('Tag')->search(
        where => {
            user_id => $self->id,
        },
        order => 'name ASC',
    );
}

sub get_tag_by_name {
    my ($self, $name) = @_;
    return unless defined $name and length $name;
    return moco('Tag')->find(
        user_id => $self->id,
        name => $name,
    );
}

1;
