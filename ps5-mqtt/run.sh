#!/usr/bin/env bashio

export CONFIG_PATH="/data/options.json"
export CREDENTIAL_STORAGE_PATH="/config/ps5-mqtt/credentials.json"

if bashio::config.is_empty 'mqtt' && bashio::var.has_value "$(bashio::services 'mqtt')"; then
    export MQTT_HOST="$(bashio::services 'mqtt' 'host')"
    export MQTT_PORT="$(bashio::services 'mqtt' 'port')"
    export MQTT_USERNAME="$(bashio::services 'mqtt' 'username')"
    export MQTT_PASSWORD="$(bashio::services 'mqtt' 'password')"
else
    _MQTT_HOST=$(bashio::config 'mqtt.host')
    _MQTT_PORT=$(bashio::config 'mqtt.port')
    _MQTT_USER=$(bashio::config 'mqtt.user')
    _MQTT_PASS=$(bashio::config 'mqtt.pass')

    [ "$_MQTT_HOST" != "null" ] && [ -n "$_MQTT_HOST" ] && export MQTT_HOST="$_MQTT_HOST"
    [ "$_MQTT_PORT" != "null" ] && [ -n "$_MQTT_PORT" ] && export MQTT_PORT="$_MQTT_PORT"
    [ "$_MQTT_USER" != "null" ] && [ -n "$_MQTT_USER" ] && export MQTT_USERNAME="$_MQTT_USER"
    [ "$_MQTT_PASS" != "null" ] && [ -n "$_MQTT_PASS" ] && export MQTT_PASSWORD="$_MQTT_PASS"
fi

export FRONTEND_PORT=8645
if [ ! -z $(bashio::addon.ingress_port) ]; then
    FRONTEND_PORT=$(bashio::addon.ingress_port)
fi

# configure logger
export DEBUG="*,-mqttjs*,-mqtt-packet*,-playactor:*,-@ha:state*,-@ha:ps5:poll*,-@ha:ps5:check*"

if [ ! -z $(bashio::config 'logger') ]; then
    DEBUG=$(bashio::config 'logger')
fi

echo Starting PS5-MQTT...
node app/server/dist/index.js