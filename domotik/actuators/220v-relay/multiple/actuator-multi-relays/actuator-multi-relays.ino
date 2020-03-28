#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <PubSubClientTools.h>

#include <Thread.h>             // https://github.com/ivanseidel/ArduinoThread
#include <ThreadController.h>

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
#define DEVICE_ID "SwitchArray-1"
#define TOPIC_DEVICE_STRLEN 21

#define ON true
#define OFF false

#define MAX_RELAY 6
int relayPin[MAX_RELAY] = {D1, D2, D3, D5, D6, D7};


WiFiClient espClient;
PubSubClient client(MQTT_SERVER, 1883, espClient);
PubSubClientTools mqtt(client);

ThreadController threadControl = ThreadController();
Thread thread = Thread();

int value = 0;
const String s = "";

void setup() {
  initRelays();
  
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
  mqtt.subscribe(TOPIC_PREFIX DEVICE_ID "",  generalSubscriber);  // Visually check if device is responsive
  mqtt.subscribe(TOPIC_PREFIX DEVICE_ID "/#",  switchSubscriber);  // Catch-all, to be placed as last subscription

  // Enable Thread
  thread.onRun(checkMQTTconnection);
  thread.setInterval(63000);
  threadControl.add(&thread);

  pingDevice();
}

void loop() {
  client.loop();
  threadControl.run();
  //delay(500);
  //Serial.print(".");
}


void initRelays() {
  for (int i = 1; i <= MAX_RELAY; i++) {
    pinMode(relayPin[i-1], OUTPUT);
  }
  setRelay(0, OFF);
}

boolean getRelay(int id) {
  if (id > 0 && id <= MAX_RELAY)
    return (digitalRead(relayPin[id-1])==LOW);
  else
    return false;
}

void setRelay(int id, boolean onOff) {
  if (id == 0) {
    //Serial.println(s+ "Switching all to " + onOff?"ON":"OFF");
    for (int i = 1; i <= MAX_RELAY; i++) {
      digitalWrite(relayPin[i-1], onOff?LOW:HIGH);
    }
    delay(200);
  }
  else 
    if (id <= MAX_RELAY) {
      digitalWrite(relayPin[id-1], onOff?LOW:HIGH);
      delay(200);
    }
}

void toggleRelay(int id) {
  if (id > 0 && id <= MAX_RELAY) {
    Serial.print("Switch state before toggling : ");
    Serial.println(getRelay(id)?"ON":"OFF");
    setRelay(id, !getRelay(id));
  }
}

void switchSubscriber(String topic, String message) {
  message.toUpperCase();
  int switchId = topic.substring(TOPIC_DEVICE_STRLEN+1,TOPIC_DEVICE_STRLEN+2).toInt();
  if (switchId <= MAX_RELAY) {
    if (message == "TOGGLE" && switchId > 0)
      toggleRelay(switchId);
    else
      setRelay(switchId, (message == "ON"));
    Serial.print(s + "Switch " );
    Serial.print(switchId);
    Serial.println(s + " --> " + message);
  }
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
    Serial.println("MQTT connection is Ok");
  else {
    Serial.println("MQTT connection lost!");
    connectToMQTT();
    mqtt.resubscribe();
  }
}
