use Mojolicious::Lite;

get '/login' => sub {
    my $c = shift;
    $c->render( template => 'login' );
};

get '/:foo' => sub {
	my $c = shift;
	my $foo = $c->param('foo');
    my $bar = $c->param('bar');
    my $ret = "Hello from $foo.";
    $ret .= "  $bar says hi." if defined $bar;
	$c->render(text => $ret);
};

# Start the app
app->start;
