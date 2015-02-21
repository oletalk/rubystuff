package PasswordLib;

use Crypt::PBKDF2;

sub encrypt {
    my $password = shift;

    my $pbkdf2 = Crypt::PBKDF2->new(
            hash_class => 'HMACSHA2',
            hash_args => {
                sha_size => 512,
            },
        iterations => 10000,
        salt_len => 10,
    );

    my $hash = $pbkdf2->generate($password);
    return $hash;
}

sub validate {
    my ($hash, $password) = @_;

    my $validated = undef;
    my $pbkdf2 = Crypt::PBKDF2->new;
    if ($pbkdf2->validate($hash, $password)) {
        $validated = 1;
    }
    return $validated;
}

1;
