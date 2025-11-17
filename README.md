# R99-TOIT

The repository contains two applications in the __Toit__ language from __Toitware__, which allow access to a __BLE__ device, connection to its services, and reading the required information.

## Introduction

The device I'm trying to access via __BLE__ is a very inexpensive Chinese __smart ring__ marketed as a __smart health care__ device. In addition to __fitness__ information, it can measure several parameters such as __oxygen__, __heart rate__, and __blood pressure__. According to the info from __nRF__ application, the __heart rate service__ (__0x180D__) is __accessable__ on device, and this parameter can be measured, readed, and for  instance saved to a __cloud database__ using the __REST API__.

<img width="1204" height="1600" alt="r99" src="https://github.com/user-attachments/assets/70205bae-a4fc-4d7e-ac14-2f2d0ab583e6" />

## Brief description

The main application module is the __r998372.toit__ file. The following it's components are worth noting:

> Class MeasurementHR_R998372 with a public __measure_ function, which allows you to measure and read the __heart rate__ and a result field: a map (hash table) containing the measurement result.

> The functions of this class that support the measurement process are listed below:

* __find_and_connect__ - searches for a device using the function
* __find-with-service__, which scans BLE nearby devices and, if successful, returns a __ble.RemoteScannedDevice object.

> Next, an attempt is made to connect to the found device and measure the __heart_rate__ using the function

* __connect_device__

> __Note__: access to __heart_rate__ is by subscription, not by reading.

That's all there is to it. It's not much different from the process of accessing __BLE__ devices in __Android__ apps using packages like __flutter_reactive_ble__. It's just a bit simpler.

## Time

If the measured value is expected to have a timestamp, then it's necessary to somehow obtain the local time corresponding to the moment of measurement.

## Saving data to the cloud




