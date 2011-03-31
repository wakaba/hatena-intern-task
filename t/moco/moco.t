package test::Task::MoCo;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::Task;
use Test::More;

# 特にテストするものもないので、 use_ok だけしておく
sub _use : Test(1) {
    use_ok 'Task::MoCo';
}

__PACKAGE__->runtests;

1;
