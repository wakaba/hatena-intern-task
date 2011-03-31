package test::Task::MoCo::User;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::Task;
use Test::More;
use Task::MoCo;

sub _created_on : Test(2) {
    my $user_name = 'test_user_' . int rand 100000;
    my $user = moco('User')->create(
        name => $user_name,
    );
    isa_ok $user->created_on, 'DateTime';
    is $user->updated_on, undef;
}

sub _updated_on : Test(1) {
    my $user = create_user;
    $user->name($user->name . int rand 10);
    isa_ok $user->updated_on, 'DateTime';
}

sub _tasks_empty : Test(2) {
    my $user = create_user;
    my $tasks = $user->tasks;
    isa_ok $tasks, 'DBIx::MoCo::List';
    is $tasks->length, 0;
}

sub _tasks_many : Test(6) {
    my $user = create_user;
    my $task1 = create_task(user => $user);
    $task1->name('abc');
    my $task2 = create_task(user => $user);
    $task2->name('xyz');
    my $tasks = $user->tasks;
    isa_ok $tasks, 'DBIx::MoCo::List';
    is $tasks->length, 2;
    my $Task1 = $tasks->[0];
    isa_ok $Task1, moco('Task');
    is $Task1->id, $task1->id;
    my $Task2 = $tasks->[1];
    isa_ok $Task2, moco('Task');
    is $Task2->id, $task2->id;
}

sub _done_tasks : Test(4) {
    my $user = create_user;
    my $task1 = create_task(user => $user);
    $task1->status(0); # undone
    my $task2 = create_task(user => $user);
    $task2->status(1); # done
    my $tasks = $user->done_tasks;
    isa_ok $tasks, 'DBIx::MoCo::List';
    is $tasks->length, 1;
    my $Task1 = $tasks->[0];
    isa_ok $Task1, moco('Task');
    is $Task1->id, $task2->id;
}

sub _undone_tasks : Test(4) {
    my $user = create_user;
    my $task1 = create_task(user => $user);
    $task1->status(0); # undone
    my $task2 = create_task(user => $user);
    $task2->status(1); # done
    my $tasks = $user->undone_tasks;
    isa_ok $tasks, 'DBIx::MoCo::List';
    is $tasks->length, 1;
    my $Task1 = $tasks->[0];
    isa_ok $Task1, moco('Task');
    is $Task1->id, $task1->id;
}

sub _add_task_no_args : Test(1) {
    my $user = create_user;
    my $task = $user->add_task;
    is $task, undef;
}

sub _add_task_due_only : Test(1) {
    my $user = create_user;
    my $task = $user->add_task(due => DateTime->today(time_zone => 'UTC'));
    is $task, undef;
}

sub _add_task_name_only : Test(4) {
    my $user = create_user;
    my $task = $user->add_task(name => 'task 1');
    isa_ok $task, moco('Task');
    is $task->name, 'task 1';
    is $task->due, undef;
    is $task->user_id, $user->id;
}

sub _add_task_added : Test(5) {
    my $user = create_user;
    my $task = $user->add_task(
        name => 'task 2',
        due => DateTime->today(time_zone => 'UTC'),
    );
    isa_ok $task, moco('Task');
    is $task->name, 'task 2';
    isa_ok $task->due, 'DateTime';
    is $task->user_id, $user->id;
    is $task->due->ymd('-'), DateTime->now(time_zone => 'UTC')->ymd('-');
}

sub _add_task_with_empty_tags : Test(1) {
    my $user = create_user;
    my $tags = DBIx::MoCo::List->new;
    my $task = $user->add_task(
        name => 'task 3',
        tags => $tags,
    );
    is $task->tags->length, 0;
}

sub _add_task_with_1_tags : Test(2) {
    my $user = create_user;
    my $tags = DBIx::MoCo::List->new(['lmn']);
    my $task = $user->add_task(
        name => 'task 4',
        tags => $tags,
    );
    is $task->tags->length, 1;
    is $task->tags->[0]->name, 'lmn';
}

sub _add_task_with_4_dup_tags : Test(2) {
    my $user = create_user;
    my $tags = DBIx::MoCo::List->new([qw/lmn abc lmn xyz/]);
    my $task = $user->add_task(
        name => 'task 5',
        tags => $tags,
    );
    is $task->tags->length, 3;
    is_deeply $task->tags->map(sub { $_->name })->sort(sub { $_[0] cmp $_[1] })->to_a, [qw/abc lmn xyz/];
}

sub _set_task_status_same_user : Test(2) {
    my $user = create_user;
    my $task = create_task(user => $user);

    $user->set_task_status($task->id => 1);
    is moco('Task')->find(id => $task->id)->status, 1;

    $user->set_task_status($task->id => 0);
    is moco('Task')->find(id => $task->id)->status, 0;
}

sub _set_task_status_different_user : Test(1) {
    my $user = create_user;
    my $user2 = create_user;
    my $task = create_task(user => $user2);
    $task->status(0);

    $user->set_task_status($task->id => 1);

    is moco('Task')->find(id => $task->id)->status, 0;
}

sub _tags_empty : Test(2) {
    my $user = create_user;
    my $tags = $user->tags;
    isa_ok $tags, 'DBIx::MoCo::List';
    is $tags->length, 0;
}

sub _tags_many : Test(6) {
    my $user = create_user;
    my $tag1 = create_tag(user => $user);
    $tag1->name('abc');
    my $tag2 = create_tag(user => $user);
    $tag2->name('xyz');
    my $tags = $user->tags;
    isa_ok $tags, 'DBIx::MoCo::List';
    is $tags->length, 2;
    my $Tag1 = $tags->[0];
    isa_ok $Tag1, moco('Tag');
    is $Tag1->id, $tag1->id;
    my $Tag2 = $tags->[1];
    isa_ok $Tag2, moco('Tag');
    is $Tag2->id, $tag2->id;
}

sub _get_tag_by_name_undef : Test(1) {
    my $user = create_user;
    is $user->get_tag_by_name, undef;
}

sub _get_tag_by_name_empty : Test(1) {
    my $user = create_user;
    is $user->get_tag_by_name(''), undef;
}

sub _get_tag_by_name_not_found : Test(1) {
    my $user = create_user;
    is $user->get_tag_by_name('abc'), undef;
}

sub _get_tag_by_name_another_user : Test(1) {
    my $user = create_user;
    my $tag = create_tag; # 他のユーザーのタグ
    $tag->name('abc');
    is $user->get_tag_by_name('abc'), undef;
}

sub _get_tag_by_name_found : Test(3) {
    my $user = create_user;
    my $tag = create_tag(user => $user);
    $tag->name('abcdefg');
    
    my $Tag = $user->get_tag_by_name('abcdefg');
    isa_ok $Tag, moco('Tag');
    is $Tag->id, $tag->id;
    is $Tag->name, $tag->name;
}

__PACKAGE__->runtests;

1;
