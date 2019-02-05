//
//  BLEController.swift
//  Target_MB
//
//  Created by Timmy Gouin on 12/13/17.
//  Copyright © 2017 Timmy Gouin. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreData

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

func Endian_change(org:UInt32) -> UInt32 {
    var org2=org
    var new:UInt32=0
    for i in 1...4 {
        new*=256
        new+=org2%256
        org2=org2/256
    }
    return new
}

extension String {
    func hextoFloat() -> Float {
        var toInt = Int32(truncatingIfNeeded: strtol(self, nil, 16))
        var float:Float32!
        memcpy(&float, &toInt, MemoryLayout.size(ofValue: float))
        //        print("\(float)")
        return float
    }
}
//extension String {
//    func asciiValueOfString() -> [UInt32] {
//
//        var retVal = [UInt32]()
//        for val in self.unicodeScalars {
//            retVal.append(UInt32(val))
//        }
//        return retVal
//    }
//}


class BLEController: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //CoreBluetooth Properties
    var centralManager:CBCentralManager!
    var sensorTile:CBPeripheral?
    static var shouldAutoconnect = true
    static var MAX_VALUE: Double = 655000000.0
    static var PERIPHERAL_UUID = "peripheral_uuid"
    //    static var SERVICE_UUID = "00000000-0001-11E1-9AB4-0002A5D5C51B" //for SensorTile
    //    static var CHARACTERISTIC_UUID = "00000100-0001-11E1-AC36-0002A5D5C51B" //for SensorTile
    //static var SERVICE_UUID = "0000FFE0-0000-1000-8000-00805F9B34FB" //HM-10
    static var SERVICE_UUID = "0xFFE0" //HM-10
    static var CHARACTERISTIC_UUID = "0xFFE1"//HM-10
    var serviceUUID = CBUUID(string: BLEController.SERVICE_UUID)
    var characteristicUUID = CBUUID(string: BLEController.CHARACTERISTIC_UUID)
    var state:String?
    var data_packet = NSMutableData()
    var data_string = Data()
    var max: Int32 = 0
    
    var sensorTileName = "SensorTile"
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let nc = NotificationCenter.default
        if let savedPeripheralUUID = UserDefaults.standard.string(forKey: BLEController.PERIPHERAL_UUID){
            if (BLEController.shouldAutoconnect && peripheral.identifier.uuidString == savedPeripheralUUID) {
                self.connect(peripheral: peripheral)
                nc.post(name:Notification.Name(rawValue:"SavedDeviceConnecting"), object: nil)
            }
        }
        //        nc.post(name:Notification.Name(rawValue:"DeviceFound"), object: peripheral)
        if let name = peripheral.name {
            print("NAME:")
            print("\(name)")
            if name == "YostLabsMBLE" {
                //                      if name == "AM1V340" {
                sensorTile = peripheral
                guard let unwrappedPeripheral = sensorTile else { return }
                unwrappedPeripheral.delegate = self
                centralManager.connect(unwrappedPeripheral, options: nil)
                
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //TODO: save peripheral for auto connect
        let defaults = UserDefaults.standard
        defaults.set(peripheral.identifier.uuidString, forKey: BLEController.PERIPHERAL_UUID)
        _ = UIApplication.shared.delegate
        
        peripheral.discoverServices([serviceUUID])
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        
        for characteristic in characteristics {
            if characteristic.uuid == characteristicUUID {
                
                
                guard sensorTile != nil else { return }
                peripheral.setNotifyValue(true, for: characteristic)
                
                
                let setstream:[UInt8] = [0x3a ,0x38, 0x30, 0x2c, 0x31 ,0x2c ,0x32, 0x35, 0x35, 0x2c, 0x32, 0x35 ,0x35 ,0x2c, 0x32, 0x35 ,0x35 ,0x2c ,0x32 ,0x35, 0x35 ,0x2c, 0x32, 0x35, 0x35 ,0x2c, 0x32 ,0x35, 0x35, 0x2c, 0x32, 0x35 ,0x35, 0x5c, 0x6e];
                let setbaud:[UInt8] = [0x3a, 0x32, 0x33, 0x31, 0x2c, 0x39, 0x36 ,0x30, 0x30, 0x5c, 0x6e];
                let setdelay:[UInt8] = [0x3a, 0x38, 0x32, 0x2c ,0x35 ,0x30, 0x30, 0x30 ,0x30,0x30,0x2c ,0x32, 0x32, 0x35, 0x32, 0x32, 0x35, 0x32, 0x32, 0x35, 0x32, 0x32, 0x35, 0x2c, 0x31, 0x30 ,0x30, 0x30 ,0x5c, 0x6e];
                let savemode:[UInt8] = [0x3a, 0x32, 0x32, 0x35 ,0x5c ,0x6e];
                let softreset:[UInt8] = [0x3a, 0x32 ,0x32, 0x36, 0x5c, 0x6e];
                let startData:[UInt8] = [0x3a, 0x38, 0x35, 0x5c, 0x6e];
                let startTimeLengthData:[UInt8] = [0x3a, 0x38, 0x35, 0x5c, 0x6e];
                let startbin:[UInt8] = [0xf9, 0x55 ,0x55];
                let setstreambin:[UInt8] = [0xf7, 0x50, 0x01, 0x51];
                let setdelaybin:[UInt8] = [0xf7, 0x52, 0x7a, 0x51];
                let eulerbin:[UInt8] = [0xf9,0x01,0x01]
                let eulerascii:[UInt8] = [0x3a,0x31,0x5c,0x6e]
                let setheader:[UInt8] = [0xf7,0xdd,0x00,0x00,0x00,0x42,0x1f]
                
                let setstreambyte = Data(bytes: setstream)
                let setbaudbyte = Data(bytes: setbaud)
                let setdelaybyte = Data(bytes: setdelay)
                let savemodebyte = Data(bytes: savemode)
                let resetbyte = Data(bytes: softreset)
                let startDatabyte = Data(bytes: startData)
                let startbinbyte = Data(bytes: startbin)
                let startstreambin = Data(bytes: setstreambin)
                let eulerbinbyte = Data(bytes: eulerbin)
                let eulerasciibyte = Data(bytes: eulerascii)
                let setheaderbyte = Data(bytes:setheader)
                
                //                peripheral.writeValue(setstreambyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                //                peripheral.writeValue(eulerbinbyte, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
                peripheral.writeValue(setheaderbyte, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
                peripheral.writeValue(startbinbyte, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
                //               peripheral.writeValue(setbaudbyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                //                peripheral.writeValue(setdelaybyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                //  peripheral.writeValue(savemodebyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                //                peripheral.writeValue(resetbyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                
                
                //                peripheral.writeValue(startbinbyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                
                print(peripheral)
                print(characteristic)
                print(service)
                return
            }
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if var value = characteristic.value {
            //let data = NSMutableData(data: value)
            //data_packet.appendData(data)
            data_string.append(value)
            var raw:UInt32=0
            var hex_string=""
            var timestamp:Float=0;
            var yaw:Float=0;
            var pitch:Float=0;
            var roll:Float=0;
            var droll:Double=0;
            var dpitch:Double=0;
            var dyaw:Double=0;
            if(data_string.count>16){
                let data = NSMutableData(data: data_string);
                data_string=Data()
                data.getBytes(&raw, range: NSMakeRange(5,4))
                raw=Endian_change(org:raw)
                hex_string=String(format:"%02X",raw)
                print(hex_string)
                yaw = hex_string.hextoFloat()
                data.getBytes(&raw, range: NSMakeRange(9,4))
                raw=Endian_change(org:raw)
                hex_string=String(format:"%02X",raw)
                print(hex_string)
                pitch = hex_string.hextoFloat()
                data.getBytes(&raw, range: NSMakeRange(13,4))
                raw=Endian_change(org:raw)
                hex_string=String(format:"%02X",raw)
                print(hex_string)
                roll = hex_string.hextoFloat()
                dyaw = (Double)(yaw*180/3.141529)
                droll = (Double)(roll*180/3.141529)
                dpitch = (Double)(pitch*180/3.141529)
            }
            
        
           
            let euler = Euler(yaw: dyaw, pitch: dpitch, roll: droll)
            let nc = NotificationCenter.default
            nc.post(name:Notification.Name(rawValue:"DeviceData"), object: euler)
            
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            state = "Bluetooth on this device is powered on."
        case .poweredOff:
            state = "Bluetooth on this device is currently powered off."
        case .unsupported:
            state = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            state = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            state = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            state = "The state of the BLE Manager is unknown."
        }
    }
    
    func startScan() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    func connect(peripheral: CBPeripheral) {
        stopScan()
        BLEController.shouldAutoconnect = true
        sensorTile = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
        
        
    }
    
}

