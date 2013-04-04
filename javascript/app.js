var gpio = require("pi-gpio"),
	greenLedPin = 26,
	yellowLedPin = 15,
	redLedPin = 11;

gpio.open(greenLedPin, "output", function(err) {
    gpio.write(greenLedPin, 1, function() {
        gpio.close(greenLedPin);
    });
});
gpio.open(yellowLedPin, "output", function(err) {
    gpio.write(yellowLedPin, 1, function() {
        gpio.close(yellowLedPin);
    });
});
gpio.open(redLedPin, "output", function(err) {
    gpio.write(redLedPin, 1, function() {
        gpio.close(redLedPin);
    });
});
