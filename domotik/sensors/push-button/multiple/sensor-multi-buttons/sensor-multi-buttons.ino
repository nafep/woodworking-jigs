#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <PubSubClientTools.h>

#include <Thread.h>             // https://github.com/ivanseidel/ArduinoThread
#include <ThreadController.h>

#include <Button.h>

/*
 * Include a file defining the network access information. 
 * The file should contain following constant defintions.
 *     #define WIFI_SSID "..."
 *     #define WIFI_PASS "..."
 *     #define MQTT_SERVER "..."
 * These respectively define the wifi ssid and password, 
 * and the ip address on hostname of the MQTT server.
 */
#include "wifi+mqtt-credentials.h"

#define TOPIC_PREFIX "domotik/"
#define DEVICE_ID "ButtonArray-1"
#define TOPIC_DEVICE_STRLEN 21

#define ON true
#define OFF false

#define MAX_RELAY 3
int relayPin[MAX_RELAY] = {D1, D2, D3};


Button button1(D1); // Connect your button between pin 2 and GND
Button button2(D2); // Connect your button between pin 3 and GND
Button button3(D3); // Connect your button between pin 4 and GND


WiFiClient espClient;
PubSubClient client(MQTT_SERVER, 1883, espClient);
PubSubClientTools mqtt(client);

ThreadController threadControl = ThreadController();
Thread thread = Thread();

int value = 0;
const String s = "";

void setup() {  
  Serial.begin(115200);
  Serial.println();

  pinMode(LED_BUILTIN, OUTPUT);
  switchBuiltInLed(OFF);

  button1.begin();
  button2.begin();
  button3.begin();

  // Connect to WiFi
  Serial.print(s + "Connecting to WiFi: " + WIFI_SSID + " ");
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("connected");

  // Connect to MQTT
  connectToMQTT();
  mqtt.subscribe(TOPIC_PREFIX DEVICE_ID "",  generalSubscriber);  // Visually check if device is responsive
  
  // Enable Thread
  thread.onRun(checkMQTTconnection);
  thread.setInterval(60000);
  threadControl.add(&thread);

  pingDevice();
}

void loop() {
  client.loop();
  threadControl.run();

  //mqtt.publish("keep-alive", s+"dummy");

  if (button1.pressed()) {
    mqtt.publish(TOPIC_PREFIX DEVICE_ID "/1", s+"pressed");
    Serial.println("Button 1 pressed");
  }
    
  if (button2.pressed()) {
    mqtt.publish(TOPIC_PREFIX DEVICE_ID "/2", s+"pressed");
    Serial.println("Button 2 pressed");
  }

  if (button3.pressed()) {
    mqtt.publish(TOPIC_PREFIX DEVICE_ID "/3", s+"pressed");
    Serial.println("Button 3 pressed");
  }

  delay(200);
}

void generalSubscriber(String topic, String message) {
  message.toUpperCase();
  if (message == "PING")    pingDevice(); return;  
  // if (message = "...")     .... ; return; 
  Serial.println("Unknown request: '" + message + "'");
}


void switchBuiltInLed(boolean onOff) {
  digitalWrite(LED_BUILTIN, onOff?LOW:HIGH);
}

void toggleBuiltInLed() {
  digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
}

void pingDevice() {
  for (int i = 0; i < 20; i++) {
    toggleBuiltInLed();
    delay(250);
  }
}

void connectToMQTT() {
  Serial.print(s + "Connecting to MQTT: " + MQTT_SERVER + " ... ");
  if (client.connect(DEVICE_ID)) {
    Serial.println("connected");
    switchBuiltInLed(ON);
  } else {
    Serial.println(s + "failed, rc=" + client.state());
    switchBuiltInLed(OFF);
  }
}

void checkMQTTconnection() {
  if (client.connected()) 
    Serial.println(s+ "MQTT connection is Ok");
  else {
    Serial.println(s + "MQTT connection lost!" + " rc=" + client.state());
    connectToMQTT();
    mqtt.resubscribe();
  }
}
