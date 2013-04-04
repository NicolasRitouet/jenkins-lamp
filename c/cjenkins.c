#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>
#include <curl/curl.h>
#include <string.h>

//  int redLED = 11;  
//  int yellowLED = 18;
//  int greenLED = 26;
#define redLED 0  //wiringPi
#define yellowLED  5 //wiringPi
#define greenLED  11 //wiringPi

void initPins(void);


struct string 
{
	char *ptr;
	size_t len;
};

void init_string(struct string *s) 
{
	s->len = 0;
	s->ptr = malloc(s->len+1);
	if (s->ptr == NULL) 
	{
		fprintf(stderr, "malloc() failed\n");
		exit(EXIT_FAILURE);
	}
	s->ptr[0] = '\0';
}

size_t writefunc(void *ptr, size_t size, size_t nmemb, struct string *s)
{
	size_t new_len = s->len + size*nmemb;
	s->ptr = realloc(s->ptr, new_len+1);
	if (s->ptr == NULL) 
	{
		fprintf(stderr, "realloc() failed\n");
		exit(EXIT_FAILURE);
	}
	memcpy(s->ptr+s->len, ptr, size*nmemb);
	s->ptr[new_len] = '\0';
	s->len = new_len;

	return size*nmemb;
}

int main (void)
{

	printf("#########################################################\n");
	printf("#                                                       #\n");
	printf("#      jenkins build status monitor with c              #\n");
	printf("#      (c)2013 fv                                       #\n");
	printf("#                                                       #\n");
	printf("#########################################################\n");
	
	if (wiringPiSetup() == -1)
	{  
		exit(1);
	}
	
	initPins();
	
	CURL *curl;
	CURLcode res;
	
	curl = curl_easy_init();
	if(curl) 
	{
		struct string s;
		init_string(&s); 
		curl_easy_setopt(curl, CURLOPT_URL, "https://jenkins.zanox.com/view/API/api/xml?tree=jobs[name,color]");       
		curl_easy_setopt(curl, CURLOPT_POSTFIELDS, "in_chkcacic=chkinfo"); 
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writefunc);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &s);
		
		
		res = curl_easy_perform(curl);
		curl_easy_cleanup(curl);

		free(s.ptr);

		printf("%s\n", s.ptr);

		for (;;)
		{
			digitalWrite(redLED , 1);
			digitalWrite(yellowLED , 1);
			digitalWrite(greenLED , 1);
			delay(250);
		
			digitalWrite(redLED , 0);
			digitalWrite(yellowLED , 0);
			digitalWrite(greenLED , 0);
			delay(250);
		}

	}
	return 0;
}

void initPins()
{
pinMode(redLED , OUTPUT);
pinMode(yellowLED , OUTPUT);
pinMode(greenLED , OUTPUT);
digitalWrite(redLED , 0);
digitalWrite(yellowLED , 0);
digitalWrite(greenLED , 0);
}
