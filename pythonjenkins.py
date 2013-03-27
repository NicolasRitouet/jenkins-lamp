try:
	from jenkinsapi import api
	import RPi.GPIO as GPIO
	import time
	import urllib2
	import json
	

	# to use Raspberry Pi board pin numbers
	GPIO.setmode(GPIO.BOARD)
	GPIO.cleanup()
	# set up GPIO output channel
	GPIO.setup(11, GPIO.OUT)
	GPIO.setup(18, GPIO.OUT)
	GPIO.setup(26, GPIO.OUT)

	LED_RED = 11
	LED_YELLOW = 18
	LED_GREEN = 26


	jenkins=api.Jenkins('http://jenkins.zanox.com/api/python/')
	api_view=jenkins.get_view('API')

	api_view_items=api_view.items()
	jobCount=len(api_view_items)

	for i in range(0,jobCount):
		jobName=api_view_items[i][0] #.replace(" ","%20")
		job=jenkins.get_job(jobName)
		buildStatus="n/a"

		buildStatus=job.get_last_build().get_status()
		print "JOB: " + jobName + " -> STATUS: " + buildStatus 
		if buildStatus == "FAILURE":
			GPIO.output(LED_RED ,GPIO.HIGH)
			GPIO.output(LED_YELLOW ,GPIO.LOW)
			GPIO.output(LED_GREEN ,GPIO.LOW)
		if buildStatus  == "UNSTABLE":
			GPIO.output(LED_RED ,GPIO.LOW)
			GPIO.output(LED_YELLOW ,GPIO.HIGH)
			GPIO.output(LED_GREEN ,GPIO.LOW)
		if buildStatus  == "SUCCESS":
			GPIO.output(LED_RED ,GPIO.LOW)
			GPIO.output(LED_YELLOW ,GPIO.LOW)
			GPIO.output(LED_GREEN ,GPIO.HIGH)
	GPIO.cleanup()
except KeyboardInterrupt:
	GPIO.cleanup()
