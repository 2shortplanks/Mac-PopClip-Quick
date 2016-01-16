package Mac::PopClip::Quick;
use base qw(Exporter);

use strict;
use warnings;

our $VERSION = '1.000000';

use File::Spec::Functions qw(tmpdir);
use File::Basename qw(fileparse);

use Mac::PopClip::Quick::Generator;

# usually I insist on @EXPORT_OK rather than @EXPORT, but that doesn't
# really make sense with the kind of interface we're dealing with here
## no critic (Modules::ProhibitAutomaticExportation)
our @EXPORT;

sub import {
    my $class = shift;
    my %args  = @_;

    # export as usual
    $class->export_to_level( 1, undef );

    ## custom import handling

    my $creating   = $ENV{CREATE_POPCLIP_EXTENSION};
    my $installing = $ENV{INSTALL_POPCLIP_EXTENSION};
    return unless $creating || $installing;

    # default to 'bazz.popclipextz' of '/foo/bar/bazz.pl'
    my ( undef, $src_filename, undef ) = caller;
    my ($name) = fileparse($src_filename);

    # note: $src_filename can still be overriden
    # by whatever is passed in
    my $generator_class
        = delete $args{generator_class} || $self->generator_class;
    my $generator = $generator_class->new(
        src_filename   => $src_filename,
        extension_name => $name,
        %args,
    );

    $generator->create;
    $generator->install if $installing;

    if ($creating) {
        if ( $generator->extension_identifier
            =~ /\^com[.]twoshortplanks[.]macpopquickthirdparty/ ) {
            print STDERR <<'WARNING';
WARNING: Your extension is using a temporary extension_identifier unsuitable
for distribution.  It is important that this identifier remain the same for
every version of your extension so installing later version of the extension
replaces the old version.

While the temporary extension identifier generated will not change as long as
you do not change the name of the extension and are generating the extension on
this particular Mac, you should use the extension_identifier parameter to set a
unique identifier in perpetuity in case you ever want to generate the extension
on different hardware:

   use Mac::PopClip::Quick (
      extension_identifier => 'com.yourdomainname.yourextensionname',
   );

WARNING
        }
        print 'Created extension at ', $generator->filename, "\n";
    }

    exit;
}

sub generator_class { return 'Mac::PopClip::Quick::Generator' }

sub popclip_text() { return $ENV{POPCLIP_TEXT} }
push @EXPORT, 'popclip_text';

=head1 NAME

Mac::PopClip::Quick - quickly write PopClip extensions in Perl

=head1 SYNOPSIS

First write a script:

   #!/usr/bin/perl

   use 5.012;
   use warnings;
   use autodie;

   use Mac::PopClip::Quick;
   use POSIX qw(strftime);

   open my $fh, ''>>:utf8', "$ENV{HOME}/Dropbox/runlog.txt";
   say $fh strftime("%FT%T",gmtime) . ' ' . popclip_text();

Then install it as a PopClip Extension

   bash$ INSTALL_POPCLIP_EXTENSION=1 ./runlog.pl

=head1 DESCRIPTION

PopClip For Mac is a commercial OS X utility from Pilotmoon Software that
creates little popup menus when you highlight text.  Please see
http://pilotmoon.com/popclip/ for more details.

This module make it easier to write PopClip extensions in Perl.  With this
module you can turn a simple Perl script into an installable extension with a
single command.

The resulting extension does not depend on the Mac::PopClip::Quick module, and
can be safely distributed to systems that do not have this module installed.

=head2 Examples

In your script you should C<use Mac::PopClip::Quick>.

    #!/usr/bin/perl

    use Mac::PopClip::Quick;
    system('say',"The selected text is '.popclip_text());

From the command line you simply need to execute the script with the
C<INSTALL_POPCLIP_EXTENSION> environment variable set to a true value.

   bash$ INSTALL_POPCLIP_EXTENSION=1 ./reverse.pl

You can also create an executable suitable for distribution using the

   bash$ CREATE_POPCLIP_EXTENSION=1 ./reverse.pl

Options can be set by passing them in the C<use> statement:

  use Mac::PopQuick::Quick (
      extension_identifier => 'com.yourdomain.extensionname',
  );

They'll be passed through to the underlying L<Mac::PopClip::Quick::Generator>
class's constructor.

You can use C<after_action> to control what your extension does with the
script output, for example pasting it:

    use Mac::PopQuick::Quick (
        extension_name => 'Reverse Text',
        after_action => 'paste-result',
    );
    print reverse popclip_text();

=back

=head1 Supported Options

=head2 Core Options

=over

=item extension_name

The name of the extension.  By default this is the name of the script, minus
any file extension (e.g. if your script if called C<foo.pl> then the extension
will be called C<foo> by default.)

=item title

The title.  By default, the same as the C<extension_name>.

=item filename

The filename that the tarball will be created with.  Should end with
C<.popclipextz> (though we don't force you to.)

By default a temporary filename is used if no value is provided.  If the
C<CREATE_POPCLIP_EXTENSION> environment variable is set then this will be
printed out.

=item extension_identifier

A unique identifier for your extension.  This enables PopClip to identify
if an extension it's installing should install as a new extension or replace
an older version of the same extension.

By default this will generate something unique for you by using the unique ID of
your Mac and the extension name.  This is B<not> suitable for distribution (if
you change hardware you won't be able to use it anymore) and you should set a
value for this attribute before distributing your extension.

=back

=head2 Options Controlling PopClip Behavior

=over

=item required_software_version

The required version of PopClip.  By default this is 701.

=item regex

A string containing the regex that controls when the extension will be
triggered.  Note that this is not a Perl regex, but rather a string that PopClip
can execute as a PCRE.

By default this is undefined, meaning no regex is used.

=item script_interpreter

The program you want to use to execute your Perl script (it can be handy to set
this if you want to use a perl other than the system perl, e.g. a perl you
installed with perlbrew)

By default this is C</usr/bin/perl>, the system perl.

=item blocked_apps

Array of bundle identifier strings (e.g. C<com.apple.TextEdit>) of applications
for which this extension's actions should not appear.

=item required_apps

Array of bundle identifier strings of applications (e.g. C<com.apple.TextEdit>)
that this extension's actions will appear in.

=back

=cut

1;

__END__

