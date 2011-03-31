package Task::DataBase;
use strict;
use warnings;
use base qw(DBIx::MoCo::DataBase);

__PACKAGE__->dsn('dbi:mysql:dbname=task');
__PACKAGE__->username('root');
__PACKAGE__->password('');

1;
