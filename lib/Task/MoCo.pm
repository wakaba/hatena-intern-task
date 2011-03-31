package Task::MoCo;
use strict;
use warnings;
use base qw(DBIx::MoCo);
use Task::DataBase;
use Exporter::Lite;
use UNIVERSAL::require;
use DateTime;
use DateTime::Format::MySQL;

our @EXPORT = qw(moco);

__PACKAGE__->db_object('Task::DataBase');

sub moco (@) {
    my $model = shift;
    return __PACKAGE__ unless $model;
    $model = join '::', __PACKAGE__, $model;
    $model->require or die $@;
    $model;
}

$DBIx::MoCo::DataBase::DEBUG = 1 if $ENV{MOCO_DEBUG};

sub datetime_columns {
    my $class = shift;
    my @columns = ref $_[0] eq 'ARRAY' ? @$_[0] : @_;

    foreach (@columns) {
        $class->inflate_column(
            $_ => {
                deflate => sub { $_[0] ? DateTime::Format::MySQL->format_datetime(shift) : '0000-00-00 00:00:00' },
                inflate => sub { $_[0] && $_[0] ne '0000-00-00 00:00:00' && DateTime::Format::MySQL->parse_datetime(shift) },
            }
        );
    }
}

sub date_columns {
    my $class = shift;
    my @columns = ref $_[0] eq 'ARRAY' ? @$_[0] : @_;

    foreach (@columns) {
        $class->inflate_column(
            $_ => {
                deflate => sub { $_[0] ? DateTime::Format::MySQL->format_date(shift) : '0000-00-00' },
                inflate => sub { $_[0] && $_[0] ne '0000-00-00' && DateTime::Format::MySQL->parse_date(shift) },
            }
        );
    }
}

__PACKAGE__->datetime_columns(qw(created_on updated_on));

__PACKAGE__->add_trigger(before_create => \&set_created_on);
__PACKAGE__->add_trigger(before_update => \&set_updated_on);

sub set_created_on {
    my ($class, $args) = @_;
    $args->{'created_on'} = DateTime::Format::MySQL->format_datetime(DateTime->now(time_zone => 'UTC'));
}

sub set_updated_on {
    my ($class, $self, $args) = @_;
    $args->{'updated_on'} = DateTime::Format::MySQL->format_datetime(DateTime->now(time_zone => 'UTC'));
}

1;
