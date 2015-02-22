package Mojolicious::Plugin::DebugHelper;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
    my ($self, $app) = @_;
    $app->helper(debug => sub {
        my ($c, $str) = @_;
        $c->app->log->debug($str);
    });

}

1;
