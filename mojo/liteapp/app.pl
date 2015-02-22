use Mojolicious::Lite;

use lib './lib';
use PasswordLib;
use DBLib;
use DebugHelper;
plugin 'DebugHelper';

get '/login' => sub {
    my $c = shift;
    $c->render( template => 'login' );
};

post '/login' => sub {
    my $c = shift;
    my $username = $c->param('username');
    my $password = $c->param('password');
   
    my $password_validated; 
    my $pass_hash = DBLib::query_single_cell('SELECT pass FROM users WHERE username = ?', [ $username ]);
    if ( defined $pass_hash ) {
        if ( PasswordLib::validate( $pass_hash, $password ) ) {
            $password_validated = 1;
        } else {
            $c->debug("Incorrect password entered for user '$username'");
        }
    } else {
        $c->debug("User '$username' not found");
    }

    if ($password_validated) {
        $c->render(text => "Welcome user $username!");
    } else {
        my $errormessage = "Sorry, login failed.";
        $c->render(template => 'login', errormessage => $errormessage );
    }
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
app->secrets(['moroccom0l3']);
app->start;
