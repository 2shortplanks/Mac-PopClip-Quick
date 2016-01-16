package Mac::PopClip::Quick::Role::Regex;
use Moo::Role;

requires '_plist_action_key_values';

=head1 NAME

Mac::PopClip::Quick::Role::Regex - regex controlling when extension is available

=head1 SYNOPSIS

    package Mac::PopClip::Quick::Generator;
    use Moo;
    with 'Mac::PopClip::Quick::Role::Regex';
    ...

=head1 DESCRIPTION

Configure the Before and After actions

=cut

around '_plist_action_key_values' => sub {
    my $orig = shift;
    my $self = shift;
    my @ret  = $orig->( $self, @_ );
    push @ret, 'Regular Expression' => $self->regex if defined $self->regex;
    return @ret;
};

=head1 ATTRBITUTES

=head2 regex

A string containing the regex that controls when the extension will be
triggered.  Note that this is not a Perl regex, but rather a string that PopClip
can execute as a PCRE.

By default this is undefined, meaning no regex is used.

=cut

has 'regex' => (
    is => 'ro',
);

1;
