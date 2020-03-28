#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <PubSubClientTools.h>

#include <Thread.h>             // https://github.com/ivanseidel/ArduinoThread
#include <ThreadController.h>

#define WIFI_SSID "Axilo"
#define WIFI_PASS "Woodworker2019"
#define MQTT_SERVER "workshop-pi.local"

#define TOPIC_PREFIX "shopvac/"
#define DEVICE_ID "wde1200"
#define TOPIC_DEVICE_STRLEN 15

#define ON true
#define OFF false

int relayPin = D2;
const int analogInPin = A0;

int closeDelay = 4; // time in seconds to wait before switching the hover off
long int timer = millis()-1;

WiFiClient espClient;
PubSubClient client(MQTT_SERVER, 1883, espClient);
PubSubClientTools mqtt(client);

ThreadController threadControl = ThreadController();
Thread thread = Thread();

int value = 0;
const String s = "";

void setup() {
  pinMode(D2,OUTPUT);
  digitalWrite(D2,false);
  
  Serial.begin(115200);
  Serial.println();

  pinMode(LED_BUILTIN, OUTPUT);
  switchBuiltInLed(OFF);

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
  mqtt.subscribe(TOPIC_PREFIX DEVICE_ID ,  generalSubscriber);

  // Enable Thread
  thread.onRun(checkMQTTconnection);
  thread.setInterval(63000);
  threadControl.add(&thread);

  mqtt.publish(TOPIC_PREFIX DEVICE_ID, "ready" );

  pingDevice();
}

void loop() {
  client.loop();
  threadControl.run();
  //Serial.print(".");
/*  
  if (analogRead(analogInPin) >= 100)
    timer = millis() + closeDelay*1000;
  
  digitalWrite(D2, timer>millis());

  delay(200);
*/
}

boolean getRelay() {
  return (digitalRead(relayPin)==HIGH);
}

void setRelay(boolean onOff) {
  digitalWrite(relayPin, onOff?HIGH:LOW);
  flickerDevice();
}

void toggleRelay() {
  setRelay(!getRelay());
}

void generalSubscriber(String topic, String message) {
  message.toUpperCase();
  if (message == "ON")       { setRelay(ON);   return; }
  if (message == "OFF")      { setRelay(OFF);  return; }
  if (message == "TOGGLE")   { toggleRelay();  return; }
  if (message == "PING")     { pingDevice();   return; } 
  
  Serial.println("Ignoring unknown request: '" + message + "'");
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

void flickerDevice() {
  for (int i = 0; i < 10; i++) {
    toggleBuiltInLed();
    delay(25);
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
    Serial.println("MQTT connection is Ok");
  else {
    Serial.println("MQTT connection lost!");
    connectToMQTT();
    mqtt.resubscribe();
  }
}
