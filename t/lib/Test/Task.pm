package Test::Task;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('modules/*/lib')->stringify;
use Task::DataBase;
use Task::MoCo;
use Exporter::Lite;

Task::DataBase->dsn('dbi:mysql:dbname=task_test');

our @EXPORT = qw(
    create_user
    create_task
    create_tag
);

sub create_user (;%) {
    my $user_name = 'test_user_' . int rand 100000;
    my $user = moco('User')->create(
        name => $user_name,
    );
    return $user;
}

sub create_task (;%) {
    my %args = @_;
    my $user = $args{user} || create_user;
    my $task = moco('Task')->create(
        user_id => $user->id,
    );
    return $task;
}

sub create_tag (;%) {
    my %args = @_;
    my $user = $args{user} || create_user;
    my $task = $args{task} || create_task(user => $user);
    my $tag = moco('Tag')->create(
        user_id => $user->id,
        task_id => $task->id,
    );
    return $tag;
}

1;
