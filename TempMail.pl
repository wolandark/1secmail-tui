#!/usr/bin/perl

use strict;
use warnings;
use Curses::UI;
# use Data::Dumper;
# use v5.38;
use JSON;


my $cui = Curses::UI->new(-color_support => 1, -clear_on_exit => 0);

$cui->set_binding(sub { exit(0); }, "\cC");

my $win = $cui->add('screen', 'Window');

my $ascii_art = <<'END_ART';
  ______                                                    __  ___      _ __
 /_  __/__  ____ ___  ____  ____  _________ ________  __   /  |/  /___ _(_) /
  / / / _ \/ __ `__ \/ __ \/ __ \/ ___/ __ `/ ___/ / / /  / /|_/ / __ `/ / / 
 / / /  __/ / / / / / /_/ / /_/ / /  / /_/ / /  / /_/ /  / /  / / /_/ / / /  
/_/  \___/_/ /_/ /_/ .___/\____/_/   \__,_/_/   \__, /  /_/  /_/\__,_/_/_/   
                  /_/                          /____/                        
  ________  ______   ____         ____            __       ______
 /_  __/ / / /  _/  /  _/___     / __ \___  _____/ /_   __/ ____/
  / / / / / // /    / // __ \   / /_/ / _ \/ ___/ /| | / /___ \  
 / / / /_/ // /   _/ // / / /  / ____/  __/ /  / /_| |/ /___/ /  
/_/  \____/___/  /___/_/ /_/  /_/    \___/_/  /_/(_)___/_____/   
END_ART

$win->add(
	'ascii_art', 'Label',
	-text   => $ascii_art,
	-bg     => '#1e1e2e',
	-fg     => 'cyan',
	-x      => 65,
	-y      => 5,
	-width  => $win->width(),
);


my $window_width = $win->width();
my $Rlabel_width = 20;
my $Llabel_width = 20;
my $x_position = $window_width - $Rlabel_width;

$win->add('l', 'Label', -x => 0, -bg => "magenta", -fg => "black", -text => "Perl Temporary Mail", -width => $Llabel_width);
$win->add('l1', 'Label', -x => $x_position, -bg => "black", -fg => "yellow", -text => "Powered By 1secmail", -width => $Rlabel_width);


my $response = "https://www.1secmail.com/api/v1/?action=genRandomMailbox&count=1";


my $email_address = '';
my $username = '';
my $domain = '';
my $formatted_json = '';
my $Id = '';
my $box = '';
my $filename = '/home/woland/Work/Languages/Perl/curses-ui/1/TempMail-Curses-UI/file.txt';


my $window_height = $win->height();
my $center_y = int(($window_height - 1) / 2);


my $buttonbox_container = $win->add(
	'buttonbox_container', 'Container',
	-border => 1,
	-y      => $center_y + 1,  
	-width  => $window_width,  
);


$buttonbox_container->add(
	'buttonbox_id', 'Buttonbox',
	-buttons          => [
		{
			-label   => '< Get Random Email >',
			-onpress => sub {
				$email_address = `curl -sL $response`;
				chomp($email_address);


				$email_address =~ s/^\["(.*)"\]$/$1/;


				($username, $domain) = split('@', $email_address);


				system("echo $email_address | xsel --clipboard --input");


				# open(FH, '>', $filename) or die $!;
				# print FH $email_address;
				# close(FH);


				# system("perl SendMailTest.pl");
				# system("echo -e '\033[H\033[2J'");


				$cui->dialog(
					-message => "Random Email:\n$email_address\nCopied To Clipboard",
					-title   => "Email Address",
					-buttons => [
						{
							-label   => '< OK >',
							-value => 1,
							-shortcut => 'o',
						}
					],
				);
			}
		},
		{
			-label   => '< Update Inbox >',
			-onpress => sub {

				my $command_output = `curl -sL "https://www.1secmail.com/api/v1/?action=getMessages&login=$username&domain=$domain"`;
				chomp($command_output);


				eval { $formatted_json = decode_json($command_output); };
				if ($@ || !@$formatted_json) {
					$cui->dialog(
						-message => "No messages found or failed to retrieve messages.",
						-title   => "Inbox",
						-buttons => [{ -label => '< OK >', -value => 1, -shortcut => 'o' }],
					);
					return;
				}

				$Id = $formatted_json->[0]->{id};


				$cui->dialog(
					-message => "$formatted_json->[0]->{subject};",
					-title   => "$formatted_json->[0]->{id};",
					-buttons => [
						{
							-label   => '< Fetch Mail Body >',
							-value   => 1,
							-shortcut => 'o',
						}
					],
				);


				my $inbox = `curl -sL "https://www.1secmail.com/api/v1/?action=readMessage&login=$username&domain=$domain&id=$Id"`;
				chomp($inbox);


				my $formatted_inbox = decode_json($inbox);
				$box = $formatted_inbox->{textBody};


				$cui->dialog(
					-message => $box,
					-title   => "$Id = $formatted_json->[0]->{subject}",
					-buttons => [
						{
							-label   => '< OK >',
							-value   => 1,
							-shortcut => 'o',
						}
					],
				);
			}
		},
	],
	-buttonalignment => 'middle',
);

$cui->mainloop;

