#!/usr/bin/perl
use warnings;

use LWP::UserAgent;
use XML::LibXML;
use Device::BCM2835;

print "#########################################################\n";
print "#                                                       #\n";
print "#      jenkins build status monitor with perl           #\n";
print "#      (c)2013 fv                                       #\n";
print "#                                                       #\n";
print "#########################################################\n";

Device::BCM2835::init() || die "Could not init library BCM2835";

my $ON = 1;
my $OFF = 0;

initPins();

my $jenkinsUrl= 'https://jenkins.zanox.com/view/API/api/xml?tree=jobs[name,color]';
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;
# ask jenkins
my $response = $ua->get($jenkinsUrl);
# got a response from jenkins?
if ($response->is_success) {
        my $content = $response->decoded_content;
        my $parser = XML::LibXML->new();
        my $xmldoc = $parser->parse_string($response->decoded_content(charset => 'none'));
        for my $job ($xmldoc->findnodes('/listView/job')) {
                my $buildStatus = $job->findvalue('color/text()');
                my $jobName = $job->findvalue('name/text()');
$jbName="business-sonar";                
if($buildStatus eq "red")
                {
			Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_11, $ON);
			Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_18, $OFF);
			Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_26, $OFF);


			print "JOB: $jobName\n";
			print "STATUS: FAILED\n\n";
			
                }
                elsif($buildStatus eq "blue")
                {
			Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_11, $OFF);
			Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_18, $OFF);
			Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_26, $ON);

                     print "JOB: $jobName\n";
			print "STATUS: SUCCESS\n\n";

                }
                else
                {
			Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_11, $OFF);
			Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_18, $ON);
			Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_26, $OFF);


                     print "JOB: $jobName\n";
			print "STATUS: ???\n\n";
                }
		  #sleep(1);
        }
}

resetPins();

sub initPins {
	#my @GPIOPins = [11,18,26]; 
	Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_GPIO_P1_11,&Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
	Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_GPIO_P1_18,&Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
	Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_GPIO_P1_26,&Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
	resetPins();
}
 
sub resetPins {
	Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_11, $OFF);
	Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_18, $OFF);
	Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_26, $OFF);
}