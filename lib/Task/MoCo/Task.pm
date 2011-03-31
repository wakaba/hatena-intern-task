package Task::MoCo::Task;
use strict;
use warnings;
use base qw(Task::MoCo);
use Task::MoCo;

__PACKAGE__->table('task');

__PACKAGE__->utf8_columns(qw(name));

__PACKAGE__->date_columns(qw(due));

sub user {
    my $self = shift;
    return moco('User')->find(id => $self->user_id);
}

sub tags {
    my $self = shift;
    return scalar moco('Tag')->search(
        where => {
            task_id => $self->id,
        },
        order => 'name ASC',
    );
}

sub add_tag {
    my ($self, $name) = @_;
    my $tag = moco('Tag')->find(
        user_id => $self->user_id,
        task_id => $self->id,
        name => $name,
    ) || moco('Tag')->create(
        user_id => $self->user_id,
        task_id => $self->id,
        name => $name,
    );
    return $tag;
}

sub as_string {
    my $self = shift;
    my $s = sprintf "[%d] %s %s\n%s\n",
        $self->id,
        $self->due ? $self->due->ymd('-') : '????-??-??',
        $self->status ? 'done' : '',
        $self->name;
    my $tags = $self->tags;
    if ($tags->length) {
        $s .= $tags->map(sub { $_->name })->join(' ') . "\n";
    }
    return $s;
}

1;
