package DBLib;

use strict;
use DBI;

our $CONFIG = 'conf/db.conf';

sub query_single_cell {
    my ($query, $params_listref) = @_;

    my $ret = query_results($query, $params_listref);
    if (defined $ret && scalar @{$ret} > 0) {
        my $row = $ret->[0];
        return $row->[0];
    }
    return undef;
}

sub query_results {
    my ($query, $params_listref) = @_;
    
    my $dbh = dbconnect();
    my $ret;
    if ($dbh) {
        my $sth = $dbh->prepare($query);
        my $rv;
        if (defined $params_listref && scalar @{$params_listref} > 0) {
            $rv = $sth->execute(@{$params_listref});
        } else {
            $rv = $sth->execute;
        }
        while ( my @row = $sth->fetchrow_array ) {
            push @{$ret}, \@row;
        }

        $dbh->disconnect;
    }

    return $ret;
}

sub dbconnect {
    my $cfg = read_cfg();
    # check for mandatory params
    my $user = param_or_die( $cfg, 'user' );
    my $pass = param_or_die( $cfg, 'pass' );
    my $database = param_or_die( $cfg, 'database' );
    my $dbh = DBI->connect("dbi:Pg:dbname=$database", $user, $pass,
            { AutoCommit => 1, RaiseError => 1 } ); 

    return $dbh;
}


sub read_cfg {
    open (my $fh, '<', $CONFIG) or die "Couldn't open db config file: $!";

    my $cfg;

    while (<$fh>) {
        my $line = $_;
        chomp $line;
        my ($key, $value) = split(/=/, $line);
        $cfg->{$key} = $value;
    }
    return $cfg;
}

sub param_or_die {
    my ($cfg, $param) = @_;
    if ( defined $cfg->{$param} ) {
        return $cfg->{$param};
    } else {
        die "Parameter '$param' not found in config";
    }
}


1;
