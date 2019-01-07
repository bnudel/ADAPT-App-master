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
    static var SERVICE_UUID = "0000FFE0-0000-1000-8000-00805F9B34FB" //HM-10
    //    static var SERVICE_UUID = "0xFFE0" //HM-10
    static var CHARACTERISTIC_UUID = "0xFFE1"//HM-10
    var serviceUUID = CBUUID(string: BLEController.SERVICE_UUID)
    var characteristicUUID = CBUUID(string: BLEController.CHARACTERISTIC_UUID)
    var state:String?
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
                
                
                guard let unwrappedPeripheral = sensorTile else { return }
                peripheral.setNotifyValue(true, for: characteristic)
                
                
                let setstream:[UInt8] = [0x3a ,0x38, 0x30, 0x2c, 0x31 ,0x2c ,0x32, 0x35, 0x35, 0x2c, 0x32, 0x35 ,0x35 ,0x2c, 0x32, 0x35 ,0x35 ,0x2c ,0x32 ,0x35, 0x35 ,0x2c, 0x32, 0x35, 0x35 ,0x2c, 0x32 ,0x35, 0x35, 0x2c, 0x32, 0x35 ,0x35, 0x5c, 0x6e];
                let setbaud:[UInt8] = [0x3a, 0x32, 0x33, 0x31, 0x2c, 0x39, 0x36 ,0x30, 0x30, 0x5c, 0x6e];
                let setdelay:[UInt8] = [0x3a, 0x38, 0x32, 0x2c ,0x35 ,0x30, 0x30, 0x30 ,0x2c ,0x32, 0x32, 0x35, 0x32, 0x32, 0x35, 0x32, 0x32, 0x35, 0x32, 0x32, 0x35, 0x2c, 0x31, 0x30 ,0x30, 0x30 ,0x5c, 0x6e];
                let savemode:[UInt8] = [0x3a, 0x32, 0x32, 0x35 ,0x5c ,0x6e];
                let softreset:[UInt8] = [0x3a, 0x32 ,0x32, 0x36, 0x5c, 0x6e];
                let startData:[UInt8] = [0x3a, 0x38, 0x35, 0x5c, 0x6e];
                let startTimeLengthData:[UInt8] = [0x3a, 0x38, 0x35, 0x5c, 0x6e];
                
                let setstreambyte = Data(bytes: setstream)
                let setbaudbyte = Data(bytes: setbaud)
                let setdelaybyte = Data(bytes: setdelay)
                let savemodebyte = Data(bytes: savemode)
                let resetbyte = Data(bytes: softreset)
                let startDatabyte = Data(bytes: startData)
                let startTimeLengthDatabyte = Data(bytes: startTimeLengthData)
                
                //              peripheral.writeValue(setstreambyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                //               peripheral.writeValue(setbaudbyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                //                     peripheral.writeValue(setdelaybyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                //                peripheral.writeValue(savemodebyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                //                peripheral.writeValue(resetbyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                peripheral.writeValue(startTimeLengthDatabyte, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                print(peripheral)
                print(characteristic)
                print(service)
                return
            }
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if var value = characteristic.value {
            let data = NSData(data: value)
            
            //            print("Value data: \(value)")
            print("Sensor data: \(value.hexEncodedString())")
            //            print(value.count)
            //            var stop:UInt16 = 0
            //            data.getBytes(&stop, range: NSMakeRange(0, 2))
            //            print(value.count)
            
            //Need to parse based on 0a (line break) - 10 and 2c (comma) - 44
            //parse values
            var x:Int = 0
            var found = false
            var i:Int = 0
            
            //                var timestamp:UInt16 = 0
            //                var yaw:Int16 = 0
            //                var pitch:Int16 = 0
            //                var roll:Int16 = 0
            var yawstring = ""
            var pitchstring = ""
            var rollstring = ""
            
            
            var d:Int16 = 0
            print(value.count)
            
            while x < value.count{
                data.getBytes(&d, range: NSMakeRange(x,1))
//                print("Index: \(x) , Data: \(d)")
                
                
                if found == true{
                    if d == 44{
                        x = x + 1
                        i = i + 1
                        
                    }else {
                        if d == 10{
                            found = false
                            x = x + 1
                        }else{
                            if i == 0{
                                yawstring.append(String(d))
                            }
                            if i == 1{
                                pitchstring.append(String(d))                            }
                            if i == 2{
                                rollstring.append(String(d))                            }
                            x = x+1
                        }
                    }
                }else if d == 10{
                    found = true
                    x = x + 1
                }else{
                    x = x + 1
                }
            }
            
            //                            var timestamp = Int(
            let yawA = Array(yawstring)
            let pitchA = Array(pitchstring)
            let rollA = Array(rollstring)
            
            var yawAstring: Array<String> = Array(repeating: "", count: yawstring.count/2)
            var pitchAstring: Array<String> = Array(repeating: "", count: pitchstring.count/2)
            var rollAstring: Array<String> = Array(repeating: "", count: rollstring.count/2)
            
            var c:Int = 0
            
            while c < yawA.count{
                let index1 = yawA[c]
                let index2 = yawA[c+1]
                let i = [index1 , index2]
                yawAstring[c/2] = String(i)
                c = c + 2
            }
            c = 0
            while c < pitchA.count{
                let index1 = pitchA[c]
                let index2 = pitchA[c+1]
                let i = [index1 , index2]
                pitchAstring[c/2] = String(i)
                c = c + 2
            }
            c = 0
            while c < rollA.count{
                let index1 = rollA[c]
                let index2 = rollA[c+1]
                let i = [index1 , index2]
                rollAstring[c/2] = String(String(i))
                c = c + 2
            }
            print(yawAstring)
            print(pitchAstring)
            print(rollAstring)
            //            while c < yawA.count/2{
            //
            //                yawA(c) = [Character](yawstring(c)+(yawstring(c+1)))
            //
            //            }
            //
            //
            //            print("raw yaw data: \(yaw)")
            ////            print("double yaw data: \(dYaw)")
            //
            //            print("raw pitch data: \(pitch)")
            ////            print("double pitch data: \(dPitch)")
            //
            //            print("raw roll data: \(roll)")
            //            print("double roll data: \(dRoll)")
            
            //            let dYaw = Double(yaw)/100
            //            let dPitch = Double(pitch)/100
            //            let dRoll = Double(roll)/100
            //                var yawCHEST:Int16 = 0
            //                data.getBytes(&yawCHEST, range: NSMakeRange(8, 2))
            //
            //                var pitchCHEST:Int16 = 0
            //                data.getBytes(&pitchCHEST, range: NSMakeRange(10, 2))
            //
            //                var rollCHEST:Int16 = 0
            //                data.getBytes(&rollCHEST, range: NSMakeRange(12, 2))
            //
            
            //var qS:Int32 = 0
            //data.getBytes(&qS, range: NSMakeRange(14, 4))
            //                var dQi = Double(qI)
            //                var dQj = Double(qJ)
            //                var dQk = Double(qK)
            //                var dQs = Double(qS)
            //                if (qI > max) {
            //                    max = qI
            //                }
            //                if (qJ > max) {
            //                    max = qJ
            //                }
            //                if (qK > max) {
            //                    max = qK
            //                }
            //                if (qS > max) {
            //                    max = qS
            //                }
            
            
            //                var dYaw = Double(yaw)
            //                var dPitch = Double(pitch)
            //                var dRoll = Double(roll)
            
            //                print("raw yaw data: \(yaw)")
            //                print("double yaw data: \(dYaw)")
            //
            //                print("raw pitch data: \(pitch)")
            //                print("double pitch data: \(dPitch)")
            //
            //                print("raw roll data: \(roll)")
            //                print("double roll data: \(dRoll)")
            
            //                var dYawCHEST = Double(yawCHEST)
            //                var dPitchCHEST = Double(pitchCHEST)
            //                var dRollCHEST = Double(rollCHEST)
            //print("MAX \(max)")
            //let normalized = sqrt(dQi * dQi + dQj * dQj + dQk * dQk)
            //                dYaw /= 100.0
            //                dPitch /= 100.0
            //                dRoll /= 100.0
            
            //                print(dYaw)
            //                print(dPitch)
            //                print(dRoll)
            //                dYawCHEST /= 100.0
            //                dPitchCHEST /= 100.0
            //                dRollCHEST /= 100.0
            //                dQi /= BLEController.MAX_VALUE
            //                dQj /= BLEController.MAX_VALUE
            //                dQk /= BLEController.MAX_VALUE
            //                dQs /= BLEController.MAX_VALUE
            //                print("Timestamp: \(timestamp) Qi: \(dQi) Qj: \(dQj) Qk: \(dQk) Qs: \(dQs)")
            //print("Timestamp: \(timestamp) Yaw: \(dYaw) Pitch: \(dPitch) Roll: \(dRoll)")
            //let quaternion = Quaternion(x: dQi, y: dQj, z: dQk, w: dQs)
            //let euler = Utilities.quatToEuler(quat: quaternion)
//                           let euler = Euler(yaw: sYaw, pitch: sPitch, roll: sRoll)
            ////                print(euler)
            ////                let eulerCHEST = Euler(yaw: dYawCHEST, pitch: dPitchCHEST, roll: dRollCHEST)
            //
            //                //print("Euler Angles: yaw: \(euler.yaw) pitch: \(euler.pitch) roll: \(euler.roll)")
            //                let nc = NotificationCenter.default
            ////                nc.post(name:Notification.Name(rawValue:"DeviceDataCHEST"), object: eulerCHEST)
            //                nc.post(name:Notification.Name(rawValue:"DeviceData"), object: euler)
            
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

