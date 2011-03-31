package test::Task::MoCo::Task;
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
    my $task = moco('Task')->create(
        user_id => $user->id,
    );
    isa_ok $task->created_on, 'DateTime';
    is $task->updated_on, undef;
}

sub _updated_on : Test(1) {
    my $task = create_task;
    $task->status(1);
    isa_ok $task->updated_on, 'DateTime';
}

sub _name : Test(1) {
    my $task = create_task;
    $task->name("\x{4E00}\x{4E11}\x{4E12}");

    # inflate/deflate がちゃんと動いているか確認するため、レコードをDB
    # から引き直す
    $task = moco('Task')->find(id => $task->id);
    is $task->name, "\x{4E00}\x{4E11}\x{4E12}";
}

sub _due : Test(4) {
    my $task = create_task;
    $task->due(DateTime->new(year => 2010, month => 8, day => 31, time_zone => 'UTC'));
    
    # inflate/deflate がちゃんと動いているか確認するため、レコードをDB
    # から引き直す
    $task = moco('Task')->find(id => $task->id);
    my $due = $task->due;
    isa_ok $due, 'DateTime';
    is $due->year, 2010;
    is $due->month, 8;
    is $due->day, 31;
}

sub _user : Test(2) {
    my $user = create_user;
    my $task = create_task(user => $user);
    
    my $user2 = $task->user;
    isa_ok $user2, moco('User');
    is $user2->id, $task->user_id;
}

sub _tags_empty : Test(2) {
    my $task = create_task;
    my $tags = $task->tags;
    isa_ok $tags, 'DBIx::MoCo::List';
    is $tags->length, 0;
}

sub _tags_many : Test(6) {
    my $task = create_task;
    my $tag1 = create_tag(task => $task);
    $tag1->name('abc');
    my $tag2 = create_tag(task => $task);
    $tag2->name('xyz');
    my $tags = $task->tags;
    isa_ok $tags, 'DBIx::MoCo::List';
    is $tags->length, 2;
    my $Tag1 = $tags->[0];
    isa_ok $Tag1, moco('Tag');
    is $Tag1->id, $tag1->id;
    my $Tag2 = $tags->[1];
    isa_ok $Tag2, moco('Tag');
    is $Tag2->id, $tag2->id;
}

sub _add_tag_new : Test(5) {
    my $user = create_user;
    my $task = create_task(user => $user);
    my $tag = $task->add_tag('abc');
    isa_ok $tag, moco('Tag');
    is $tag->name, 'abc';
    is $tag->user_id, $user->id;
    is $tag->task_id, $task->id;
    is $task->tags->length, 1;    
}

sub _add_tag_not_new : Test(3) {
    my $task = create_task;
    my $old_tag = moco('Tag')->create(
        task_id => $task->id,
        user_id => $task->user_id,
        name => 'abc',
    );

    my $tag = $task->add_tag('abc');
    isa_ok $tag, moco('Tag');
    is $tag->id, $old_tag->id;
    is $task->tags->length, 1;    
}

sub _as_string_with_due : Test(1) {
    my $task = create_task;
    $task->name('abc xyz');
    $task->due(DateTime->today(time_zone => 'UTC'));

    my $str = $task->as_string;
    is $str, '['.$task->id.'] ' . DateTime->today(time_zone => 'UTC')->ymd('-') . " \n" . $task->name . "\n";
}

sub _as_string_without_due : Test(1) {
    my $task = create_task;
    $task->name('abc xyz');

    my $str = $task->as_string;
    is $str, '['.$task->id."] ????-??-?? \n" . $task->name . "\n";
}

sub _as_string_with_tags : Test(1) {
    my $task = create_task;
    $task->name('abc xyz');
    $task->add_tag($_) for qw(ab xy XXX);

    my $str = $task->as_string;
    is $str, '['.$task->id."] ????-??-?? \n" . $task->name . "\n" . "XXX ab xy\n";
}

__PACKAGE__->runtests;

1;
