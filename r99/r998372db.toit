import ble
import device
import ntp
import esp32 show adjust-real-time-clock
import encoding.json
import .periodic_timer
import .toit_rest_api

HEART-RATE-SERVICE    ::= ble.BleUuid "180D"
HEART-RATE            ::= ble.BleUuid "2A37"
SCAN-DURATION         ::= Duration --s=20 //  20
MAX_CONNECT_ATTEMPTS  ::= 8
MAX_FIND_ATTEMPTS     ::= 5

MEASUREMENTS_NUMBER   ::= 3

counter/int           := 0

time -> string :
  time := Time.now.local
  ms := time.ns / Duration.NANOSECONDS_PER_MILLISECOND
  precise_ms := "$(%04d time.year)/$(%02d time.month)/$(%02d time.day) $(%02d time.h):$(%02d time.m):$(%02d time.s).$(%03d ms)"
  return precise_ms

time_short -> string :
  time := Time.now.local
  ms := time.ns / Duration.NANOSECONDS_PER_MILLISECOND
  precise_ms := "$(%02d time.h):$(%02d time.m):$(%02d time.s).$(%03d ms)"
  return precise_ms

class MeasurementHR_R998372 :
  
  result/Map := {:}

  find_attempts/int     := 0
  connect_attempts/int  := 0

  measure :
    
    adapter := ble.Adapter
    central := adapter.central
    
    try :
      error := catch --trace=false :
        find_and_connect central HEART-RATE-SERVICE
        print "Successfully found and connected to device."
      if error :
        result = {"error": "$error"}
    
    finally :
      central.close
      adapter.close
      result["time"]    = "$time"
      result["sensor"]  = "$device.name"
      result["fa"]      = find_attempts
      result["ca"]      = connect_attempts

  find_and_connect central/ble.Central service/ble.BleUuid -> none :

    find_attempts = 0

    device/ble.RemoteScannedDevice? := null

    // Retry find_device up to MAX_FIND_ATTEMPTS times
    while not device and find_attempts < MAX_FIND_ATTEMPTS:
      
      find_attempts++

      try :

        error := catch --trace=false :
          device = find-with-service central service
          //print "Device was found"
        if error == "No device found" :
          if find_attempts == MAX_FIND_ATTEMPTS :
            throw "No device found after $MAX_FIND_ATTEMPTS attempts"
        else:
          throw error
      finally :
        //print "[$find_attempts] find_device -- completed"
        if not device :
          throw "No device found after $MAX_FIND_ATTEMPTS attempts"
        
        connected := false
        connect_attempts = 0

        // Retry connect_device up to MAX_CONNECT_ATTEMPTS5 times
        while not connected and connect_attempts < MAX_CONNECT_ATTEMPTS :    

          connect_attempts++

          try :

            error := catch --trace=false :
              connect_device central device service
              connected = true
            if error == "Failed to connect" :
              if connect_attempts == MAX_CONNECT_ATTEMPTS:
                throw "Failed to connect after $MAX_CONNECT_ATTEMPTS attempts"
            else:
              throw error
          
          finally :
            //print "[$connect_attempts] connect_device -- completed"

        if not connected:
          throw "@Failed to connect after $MAX_CONNECT_ATTEMPTS attempts"

  connect_device central/ble.Central device/ble.RemoteScannedDevice service/ble.BleUuid -> none :

    // Connection logic
    remote-device := ?
    
    try :
    
      error := catch --trace=false :
        remote-device = central.connect device.identifier

    // Discover the heart rate service.
        services := remote-device.discover-services [service]
        heart-rate-service/ble.RemoteService := services.first

    // Discover the heart rate characteristic.
        characteristics := heart-rate-service.discover-characteristics [HEART-RATE]
        heart-characteristic/ble.RemoteCharacteristic := characteristics.first

    // Read the heart rate ... read should be replace to subscribe

        heart-characteristic.subscribe
        heart-rate := heart-characteristic.wait-for-notification
        heart-characteristic.unsubscribe

        value/int := heart-rate[1]
        
        remote-device.close

        result = {"rssi": device.rssi, "device": "$device.data.name", "heart rate": value, "units": "bpm"}

      if error :
        throw "Failed to connect"

    finally :

    
  find-with-service central/ble.Central service/ble.BleUuid -> ble.RemoteScannedDevice :
    central.scan --duration=SCAN-DURATION : | device/ble.RemoteScannedDevice |
      if device.data.name == "R99 8372" and device.data.services.contains service :
          return device
    throw "No device found"

main :

  connect_db

  sync_time

  counter = 0
  timer/PeriodicTimer := PeriodicTimer 30
  timer.start ::survey timer

survey timer/PeriodicTimer :

  counter++
  measurement/MeasurementHR_R998372 := MeasurementHR_R998372
  measurement.measure

  json_string := (json.encode measurement.result).to_string
  print "$time_short: [$counter] : [$json_string]"

  keep_measure measurement.result

  if counter == MEASUREMENTS_NUMBER :
    timer.final

sync_time :

  now := Time.now
  if now < (Time.parse "2022-01-10T00:00:00Z"):
    result ::= ntp.synchronize
    if result:
      adjust-real-time-clock result.adjustment
      print "Set time to $Time.now by adjusting $result.adjustment"
    else:
      print "ntp: synchronization request failed"
  else:
    print "We already know the time is $now"