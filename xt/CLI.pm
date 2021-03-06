package xt::CLI;
use strict;
use base qw(Exporter);
our @EXPORT = qw(run cli);

use Test::Requires qw( Directory::Scratch Capture::Tiny );

sub cli {
    my $dir = Directory::Scratch->new();
    chdir $dir;

    my $app = Carton::CLI::Tested->new(dir => $dir);
    $app->config->define(section => "cpanm", name => "mirror", value => "$ENV{HOME}/minicpan", origin => 'test');

    return $app;
}

sub run {
    my $app = cli();
    $app->run(@_);
    return $app;
}

package Carton::CLI::Tested;
use parent qw(Carton::CLI);

use Capture::Tiny qw(capture_merged);

sub new {
    my($class, %args) = @_;

    my $self = $class->SUPER::new;
    $self->{dir} = $args{dir};

    return $self;
}

sub dir {
    my $self = shift;
    $self->{dir};
}

sub print {
    my $self = shift;
    $self->{output} .= $_[0];
}

sub run {
    my($self, @args) = @_;
    delete $self->{config};
    $self->{output} = '';
    $self->{system_output} = capture_merged {
        eval { $self->SUPER::run(@args) };
    };
}

sub output {
    my $self = shift;
    $self->{output};
}

sub system_output {
    my $self = shift;
    $self->{system_output};
}

1;

