#!/usr/bin/perl 

use strict;
use warnings;
use Email::Sender::Transport::SMTP::TLS;
use Email::Simple ();
use Email::Simple::Creator ();
use Email::Sender::Simple qw(sendmail);

my $smtpserver = 'smtp.gmail.com';
my $smtpport = 587;
my $smtpuser   = 'a.g.a@gmail.com';
my $smtppassword = 'Password Here';

my $src = "/home/woland/Work/Languages/Perl/curses-ui/1/TempMail-Curses-UI/file.txt";
open( my $fh,'<',$src) or die $!;
my $email_address = <$fh>;
close($fh);

# Remove any unwanted whitespace or newline characters
$email_address =~ s/[\r\n]+//g;
$email_address =~ s/^\s+|\s+$//g;

# Check if the email address looks valid
unless ($email_address =~ /^[\w\.\-]+@[\w\.\-]+\.[a-zA-Z]{2,6}$/) {
    die "Invalid email address format: $email_address";
}

my $transport = Email::Sender::Transport::SMTP::TLS->new({
  host => $smtpserver,
  port => $smtpport,
  username => $smtpuser,
  password => $smtppassword,
});

my $email = Email::Simple->create(
  header => [
    To      => $email_address,
    From    => 'foo@bar.com',
    Subject => 'This is sent from perl!',
  ],
  body => "Posting screenshots means that people are less likely to inspect your code since they can't easily run it.Posting screenshots means that people are less likely to inspect your code since they can't easily run it.Posting screenshots means that people are less likely to inspect your code since they can't easily run it.",
);

sendmail($email, { transport => $transport });
