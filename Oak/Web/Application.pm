package Oak::Web::Application;

use strict;
use Error qw(:try);
use base qw(Oak::Application);

=head1 NAME

Oak::Application - Class for creating applications in Oak

=head1 DESCRIPTION

This is the class that will be used to create real applications,
the executable file will launch it.

=head1 HIERARCHY

L<Oak::Object|Oak::Object>

L<Oak::Application|Oak::Application>

L<Oak::Web::Application|Oak::Web::Application>


=head1 METHODS

=over

=item run(MODE)

Runs the application, receives the requests and pass to the toplevel
components. Receives the mode of operation, that can be CGI or FCGI

  Oak::Web::Application generates the message (POST => $cgiobj)

The request must have the "__owa_origin__" parameter to distinguish
which toplevel component to use.

The function run creates a Oak::Web::Session object in $::SESSION.
You can use it to set session attributes.

=back

=cut

sub run {
	my $self = shift;
	my $mode = shift;
	$mode = "FCGI" unless $mode =~ /^(CGI|FCGI)$/;
	my $class;
	if ($mode eq "FCGI") {
		$class = "CGI::Fast";
	} else {
		$class = "CGI";
	}
	eval "require $class" || throw Oak::Web::Application::Error::BrokenDependencies;
	require Oak::Web::Session;
	while (1) {
		$::SESSION = new Oak::Web::Session;
		my $cgi;
		if ($mode eq "FCGI") {
			$cgi = new CGI::Fast;
		} else {
			$cgi = new CGI;
		}
 		my $origin = $cgi->param('__owa_origin__');
		$self->{topLevels} ||= {};
		$Error::Debug = 1;
		try {
			if ($origin) {
				$self->initiateTopLevel($origin);
				unless (eval '$::TL::'.$origin.'->message(POST => $cgi)') {
					if ($@) {
						if (my $err = Error::prior) {
							$err->throw
						} else {
							throw Error::Simple($@);
						}
					}
				}
			} else {
				$self->initiateTopLevel($self->get('default'));
				$::TL::default->show;
			}
		} otherwise {
			my $error = shift;
			$self->emergency($cgi, $error);
		};
		$self->freeAllTopLevel;
		$::SESSION = undef;
		last if $mode eq "CGI";
	}
}

sub emergency {
	my $self = shift;
	my $cgi = shift;
	my $exception = shift;
	print "Content-type: text/plain\n\n";
	print "Uncaught exception: ".$exception->stringify."\n";
	print "Stack trace follows:\n";
	print $exception->stacktrace;
}

=head1 EXCEPTIONS

The following exceptions are introduced by Oak::Web::Application

=over

=item Oak::Web::Application::Error::BrokenDependencies

You tryied to user or CGI or FCGI, but it failed to require
or "CGI" or "CGI::Fast".

=back

=cut

package Oak::Web::Application::Error::BrokenDependencies;
use base qw (Error);

sub stringify {
	return "Broken dependencies while trying to load 'CGI' or 'CGI::Fast'";
}

1;

__END__

=head1 EXAMPLES

  my $app = new Oak::Web::Application
    (
     "formCreate" => ["MyApp::TopLevel1", "TopLevel1.xml"],
     "formList" => ["MyApp::TopLevel2", "TopLevel2.xml"],
     "formSearch" => ["MyApp::TopLevel3", "TopLevel3.xml"],
     "default" => "formCreate"
    );

  $app->run(mode => CGI);

  # OR

  $app->run(mode => FCGI);

  # OR

  $app->run;			# will use mode => FCGI

=head1 COPYRIGHT

Copyright (c) 2001
Daniel Ruoso <daniel@ruoso.com>
All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
