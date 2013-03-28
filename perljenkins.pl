#!/usr/bin/perl
use warnings;

use LWP::UserAgent;
use XML::LibXML;

my @GPIOPins = [0,5,11]; 
#my @GPIOPins = [17,24,7]; 
#my @GPIOPins = [11,18,26]; 
my $OFF = "1";
my $ON = "0";

#initPins($GPIOPins);



my $url = 'https://jenkins.zanox.com/view/API/api/xml?tree=jobs[name,color]';
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;
# ask jenkins
my $response = $ua->get($url);
# got a response from jenkins?
if ($response->is_success) {
        my $content = $response->decoded_content;
        my $parser = XML::LibXML->new();
        my $xmldoc = $parser->parse_string($response->decoded_content(charset => 'none'));
        for my $job ($xmldoc->findnodes('/listView/job')) {
                my $buildStatus = $job->findvalue('color/text()');
                my $jobName = $job->findvalue('name/text()');
                if($buildStatus eq "red")
                {
			print "JOB: $jobName  ------------------     STATUS: FAILED\n";
                }
                elsif($buildStatus eq "blue")
                {
                     print "JOB: $jobName  ------------------     STATUS: YEAH\n";
                }
                else
                {
                     print "JOB: $jobName  ------------------     STATUS: HUH?\n";
                }
        }
}

#resetPins($GPIOPins);

sub setPin {
	my $pin = shift;
	my $value = shift;
	open my $pinvalue, ">", "/sys/class/gpio/gpio$pin/value";
       print $pinvalue "$value";
       close $pinvalue;
}
sub initPins {
     my $pins = shift;
     foreach my $pin (@$pins) {
        open my $export, ">", "/sys/class/gpio/export";
        say $export "$pin";
        close $export;
        open my $pindirection, ">", "/sys/class/gpio/gpio$pin/direction";
        print $pindirection 'out';
        close $pindirection;
    }
}
 
sub resetPins {
    my $pins = shift;
 
    foreach my $pin (@$pins) {
        open my $unexport, ">", "/sys/class/gpio/unexport";
        say $unexport "$pin";
        close $unexport;
    }
}