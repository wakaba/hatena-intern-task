package test::Task::MoCo::Tag;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::Task;
use Test::More;
use Task::MoCo;

sub _created_on : Test(2) {
    my $user = create_user;
    my $task = create_task;
    my $tag = moco('Tag')->create(
        user_id => $user->id,
        task_id => $task->id,
    );
    isa_ok $tag->created_on, 'DateTime';
    is $tag->updated_on, undef;
}

sub _updated_on : Test(1) {
    my $tag = create_tag;
    $tag->name('abc');
    isa_ok $tag->updated_on, 'DateTime';
}

sub _name : Test(1) {
    my $tag = create_tag;
    $tag->name("\x{4E00}\x{4E11}\x{4E12}");

    # inflate/deflate がちゃんと動いているか確認するため、レコードをDB
    # から引き直す
    $tag = moco('Tag')->find(id => $tag->id);
    is $tag->name, "\x{4E00}\x{4E11}\x{4E12}";
}

sub _user : Test(2) {
    my $user = create_user;
    my $tag = create_tag(user => $user);
    
    my $user2 = $tag->user;
    isa_ok $user2, moco('User');
    is $user2->id, $tag->user_id;
}

sub _task : Test(2) {
    my $task = create_task;
    my $tag = create_tag(task => $task);
    
    my $task2 = $tag->task;
    isa_ok $task2, moco('Task');
    is $task2->id, $tag->task_id;
}

__PACKAGE__->runtests;

1;
