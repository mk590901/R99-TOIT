# R99-TOIT

The repository contains two applications in the __Toit__ language from __Toitware__, which allow access to a __BLE__ device, connection to its services, and reading the required information.

## Introduction

The device I'm trying to access via __BLE__ is a very inexpensive Chinese __smart ring__ marketed as a __smart health care__ device. In addition to __fitness__ information, it can measure several parameters such as __oxygen__, __heart rate__, and __blood pressure__. According to the info from __nRF__ application, the __heart rate service__ (__0x180D__) is __accessable__ on device, and this parameter can be measured, readed, and for  instance saved to a __cloud database__ using the __REST API__.

<img width="1204" height="1600" alt="r99" src="https://github.com/user-attachments/assets/70205bae-a4fc-4d7e-ac14-2f2d0ab583e6" />

## Brief description

The main application module is the __r998372.toit__ file. The following it's components are worth noting:

> Class MeasurementHR_R998372 with a public __measure__ function, which allows you to measure and read the __heart rate__ and a __result__ field: a map (hash table) containing the measurement result.

> The functions of this class that support the measurement process are listed below:

* __find_and_connect__ - searches for a device using the function
* __find-with-service__, which scans BLE nearby devices and, if successful, returns a __ble.RemoteScannedDevice object.

> Next, an attempt is made to connect to the found device and measure the __heart_rate__ using the function

* __connect_device__

> __Note__: access to __heart_rate__ is by subscription, not by reading.

That's all there is to it. It's not much different from the process of accessing __BLE__ devices in __Android__ apps using packages like __flutter_reactive_ble__. It's just a bit simpler.

## Time

If the measured value is expected to have a timestamp, then it's necessary to somehow obtain the local time corresponding to the moment of measurement. I took advantage of the ability to use NTP (Network Time Protocol) to synchronize the clocks of computers & µcontrollers over a network: https://docs.toit.io/tutorials/misc/date-time.

> This essentially concludes the description of the __r998372__ application. Below is a monitor log for two __ESP32 S3__ chips: the __ESP32 S3 WROOM-N16R8__ with 44 pins and __ESP32 S3 super-mini__ variants. Oddly enough, there's no significant difference, although I thought the mini was less reliable. It's worth noting the __ca = connect__ attempts parameter, which indicates the number of connection attempts to the device before performing a measurement. It's clear that this number is roughly the same for both chip variants.

* __ESP32 S3 WROOM-N16R8__ log
  
```
[jaguar] INFO: program ab8c3b05-36da-74ef-7336-f7322310292b started
Set time to 2025-11-16T08:27:14.153054Z by adjusting 489800h26m21.814105391s
08:27:21.494: [1] : [{"rssi":-81,"device":"R99 8372","heart rate":79,"units":"bpm","time":"2025/11/16 08:27:21.486","sensor":"b45310f9-5107-5db1-8c61-c3b37e7188ca","fa":1,"ca":1}]
08:28:31.335: [2] : [{"rssi":-79,"device":"R99 8372","heart rate":79,"units":"bpm","time":"2025/11/16 08:28:31.330","sensor":"b45310f9-5107-5db1-8c61-c3b37e7188ca","fa":1,"ca":2}]
08:29:37.083: [3] : [{"rssi":-77,"device":"R99 8372","heart rate":79,"units":"bpm","time":"2025/11/16 08:29:37.077","sensor":"b45310f9-5107-5db1-8c61-c3b37e7188ca","fa":1,"ca":2}]
08:30:44.110: [4] : [{"rssi":-79,"device":"R99 8372","heart rate":79,"units":"bpm","time":"2025/11/16 08:30:44.102","sensor":"b45310f9-5107-5db1-8c61-c3b37e7188ca","fa":1,"ca":1}]
08:31:52.330: [5] : [{"rssi":-79,"device":"R99 8372","heart rate":79,"units":"bpm","time":"2025/11/16 08:31:52.322","sensor":"b45310f9-5107-5db1-8c61-c3b37e7188ca","fa":1,"ca":2}]
08:32:58.269: [6] : [{"rssi":-78,"device":"R99 8372","heart rate":78,"units":"bpm","time":"2025/11/16 08:32:58.263","sensor":"b45310f9-5107-5db1-8c61-c3b37e7188ca","fa":1,"ca":2}]
08:34:05.270: [7] : [{"rssi":-76,"device":"R99 8372","heart rate":79,"units":"bpm","time":"2025/11/16 08:34:05.263","sensor":"b45310f9-5107-5db1-8c61-c3b37e7188ca","fa":1,"ca":1}]
08:35:17.118: [8] : [{"rssi":-76,"device":"R99 8372","heart rate":79,"units":"bpm","time":"2025/11/16 08:35:17.111","sensor":"b45310f9-5107-5db1-8c61-c3b37e7188ca","fa":1,"ca":4}]
Timer has been delete
[jaguar] INFO: program ab8c3b05-36da-74ef-7336-f7322310292b stopped
```
* __ESP32 S3 super-mini__ log
```
[jaguar] INFO: program ab8c3b05-36da-74ef-7336-f7322310292b started
We already know the time is 2025-11-16T09:30:21.776579Z
09:30:28.360: [1] : [{"rssi":-79,"device":"R99 8372","heart rate":78,"units":"bpm","time":"2025/11/16 09:30:28.354","sensor":"a3fb9ac6-4c3a-5bc8-a583-28a0e375fd8f","fa":1,"ca":2}]
09:31:38.205: [2] : [{"rssi":-79,"device":"R99 8372","heart rate":78,"units":"bpm","time":"2025/11/16 09:31:38.201","sensor":"a3fb9ac6-4c3a-5bc8-a583-28a0e375fd8f","fa":1,"ca":3}]
09:32:45.975: [3] : [{"rssi":-77,"device":"R99 8372","heart rate":78,"units":"bpm","time":"2025/11/16 09:32:45.971","sensor":"a3fb9ac6-4c3a-5bc8-a583-28a0e375fd8f","fa":1,"ca":1}]
09:33:48.765: [4] : [{"rssi":-77,"device":"R99 8372","heart rate":78,"units":"bpm","time":"2025/11/16 09:33:48.762","sensor":"a3fb9ac6-4c3a-5bc8-a583-28a0e375fd8f","fa":1,"ca":1}]
09:34:53.485: [5] : [{"rssi":-77,"device":"R99 8372","heart rate":77,"units":"bpm","time":"2025/11/16 09:34:53.480","sensor":"a3fb9ac6-4c3a-5bc8-a583-28a0e375fd8f","fa":1,"ca":1}]
09:36:05.355: [6] : [{"rssi":-79,"device":"R99 8372","heart rate":78,"units":"bpm","time":"2025/11/16 09:36:05.351","sensor":"a3fb9ac6-4c3a-5bc8-a583-28a0e375fd8f","fa":1,"ca":2}]
09:37:08.025: [7] : [{"rssi":-77,"device":"R99 8372","heart rate":78,"units":"bpm","time":"2025/11/16 09:37:08.020","sensor":"a3fb9ac6-4c3a-5bc8-a583-28a0e375fd8f","fa":1,"ca":1}]
09:38:13.254: [8] : [{"rssi":-77,"device":"R99 8372","heart rate":78,"units":"bpm","time":"2025/11/16 09:38:13.250","sensor":"a3fb9ac6-4c3a-5bc8-a583-28a0e375fd8f","fa":1,"ca":1}]
Timer has been delete
[jaguar] INFO: program ab8c3b05-36da-74ef-7336-f7322310292b stopped
```

## Saving data to the cloud

A few notes about the __r998372db.toit__ app. It's essentially a clone of the __r998372.toit__ app, augmented with the feature of storing measured data in __Firebase RunTime DB__. The app uses modules from the https://github.com/mk590901/Authentication-with-Toit-Security project almost unchanged. Can also check out the https://github.com/mk590901/Authentication-with-Toit repository to brush up on your authentication knowledge.
The movie below shows the contents of the cloud database. This data is automatically collected when measuring heart❤️rate using the  __r998372db.toit__

## Movie

[db.webm](https://github.com/user-attachments/assets/a549b548-352e-4ae1-b628-50c62ca06129)






