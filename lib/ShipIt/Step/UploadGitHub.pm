package ShipIt::Step::UploadGitHub;
use strict;
use warnings;
use base 'ShipIt::Step';

use ShipIt::Util qw(bool_prompt);

sub init {
    my ($self, $conf) = @_;

    my $module = 'Net::GitHub::Upload';
    eval "use $module";
    die "Net::GitHub::Upload not installed\n" if $@;

    my ($login, $token);

    # read github.user and github.token config first
    $login = $conf->value('github.user');
    $token = $conf->value('github.token');

    # if github config does not found in .shipit, then read git-config
    chomp($login = `git config github.user`) unless $login;
    chomp($token = `git config github.token`) unless $token;

    unless ($login and $token) {
        die qq[Can't find github.user and github.token configs in both .shipit and .gitconfig\n]
    }

    $self->{login} = $login;
    $self->{token} = $token;

    # check git repository and detect github remote url
    my $push_to = $conf->value('git.push_to');
    die qq[Can't find shipit config for git\n] unless $push_to;

    my $remote = `git remote show $push_to`;
    my ($url) = $remote =~ /URL:\s+(\S+)/;
    die qq[Can't find git remote url for "$push_to"\n] unless $url;
    die qq[remote url "$url" is not github\n] unless $url =~ /github\.com/;

    my ($repos) = $url =~ m!([^/]+/[^/]+)\.git$!;
    die qq[Can't detect github repos name] unless $repos;

    $self->{repos} = $repos;
}

sub run {
    my ($self, $state) = @_;
    my $distfile =  $state->distfile;
    die "No distfile was created!"             unless $distfile;
    die "distfile $distfile no longer exists!" unless -e $distfile;

    if ($state->dry_run) {
        warn "*** DRY RUN, not uploading to GitHub!\n";
        return;
    }

    return unless bool_prompt("Upload to GitHub?", "y");

    my $github = Net::GitHub::Upload->new(
        username => $self->{user},
        token    => $self->{token},
    );
    $github->upload(
        repos => $self->{repos},
        file  => $distfile,
    ) or die "upload failed.\n";
}


=head1 NAME

ShipIt::Step::UploadGitHub - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

  use ShipIt::Step::UploadGitHub;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2009 KAYAC Inc. All rights reserved.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
