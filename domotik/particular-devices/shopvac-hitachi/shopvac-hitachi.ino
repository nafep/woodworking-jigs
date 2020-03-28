#include <ESP8266WiFi.h>

#include <ESP8266mDNS.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>

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

#define TOPIC_PREFIX "shopvac/"
#define DEVICE_ID "wde1200"
#define TOPIC_DEVICE_STRLEN 15

#define STATE_TOPIC "state/device"
#define SWTCHSTATE_TOPIC "state/switch"

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

boolean mqttRelayState = false;

void setup() {
  pinMode(D2,OUTPUT);
  digitalWrite(D2,false);
  mqttRelayState = false;
  
  Serial.begin(115200);
  Serial.println();

  pinMode(LED_BUILTIN, OUTPUT);
  switchBuiltInLed(OFF);

  // Connect to WiFi
  Serial.print(s + "Connecting to WiFi: " + WIFI_SSID + " ");
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("connected");

  ArduinoOTA.setHostname("shopvac-wde1200");
  // ArduinoOTA.setPassword((const char *)"123");

  ArduinoOTA.onStart([]() {
    Serial.println("Start");
  });
  ArduinoOTA.onEnd([]() {
    Serial.println("\nEnd");
  });
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
  });
  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed");
  });
  ArduinoOTA.begin();

  // Connect to MQTT
  connectToMQTT();
  mqtt.subscribe(TOPIC_PREFIX DEVICE_ID ,  generalSubscriber);

  // Enable Thread
  thread.onRun(checkMQTTconnection);
  thread.setInterval(63000);
  threadControl.add(&thread);

  publishState("ready");
  pingDevice();

  mqttPublish("commands-accepted", "on, off, toggle, ping, reboot");
}

void loop() {
  client.loop();
  threadControl.run();

  ArduinoOTA.handle();

  plugControl();

  delay(200);
}

boolean getRelay() {
  return (digitalRead(relayPin)==HIGH);
}

void setRelay(boolean onOff) {
  digitalWrite(relayPin, onOff?HIGH:LOW);
  publishSwitchState();
  flickerDevice();
}

void mqttSetRelay(boolean onOff) {
  mqttRelayState = onOff;
  setRelay(onOff);
}

void toggleRelay() {
  setRelay(!getRelay());
}

void mqttToggleRelay() {
  mqttSetRelay(!getRelay());
}

void generalSubscriber(String topic, String message) {
  message.toUpperCase();
  if (message == "ON")       { mqttSetRelay(ON);   return; }
  if (message == "OFF")      { mqttSetRelay(OFF);  return; }
  if (message == "TOGGLE")   { mqttToggleRelay();  return; }
  if (message == "PING")     { pingDevice();   return; } 
  if (message == "REBOOT")   { ESP.restart();   return; }
  
  Serial.println("Ignoring unknown request: '" + message + "'");
}

void mqttPublish(String topic, String message){
  mqtt.publish(TOPIC_PREFIX DEVICE_ID "/" + topic, message );
}

void publishState(String message) {
  mqttPublish(STATE_TOPIC, message);
}

void publishSwitchState() {
  mqttPublish(SWTCHSTATE_TOPIC, getRelay()?"ON":"OFF");
}

void plugControl() {
  if (analogRead(analogInPin) >= 100)
    timer = millis() + closeDelay*1000;

  if (timer>millis()) {
    if (!getRelay())
      setRelay(true);
  }
  else {
    if(getRelay() && !mqttRelayState)
      setRelay(false);
  }
  //setRelay(timer>millis() || mqttRelayState);
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
