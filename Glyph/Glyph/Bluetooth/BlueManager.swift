//
//  BlueServer.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import CoreBluetooth

class BlueManager: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    // Outlet for sliders
    var redSlider: Int = 0
    var greenSlider: Int = 0
    var blueSlider: Int = 0
//    var batteryPercentLabel: Any!
    
    // Characteristics
    private var redChar: CBCharacteristic?
    private var greenChar: CBCharacteristic?
    private var blueChar: CBCharacteristic?
    private var battChar: CBCharacteristic?
    
    
    func startup() {
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", ParticlePeripheral.particleLEDServiceUUID);
            centralManager.scanForPeripherals(withServices: [ParticlePeripheral.particleLEDServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // We've found it so stop scan
        self.centralManager.stopScan()
        
        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)
        
    }
    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to your Particle Board")
            peripheral.discoverServices([ParticlePeripheral.particleLEDServiceUUID,ParticlePeripheral.batteryServiceUUID]);
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral {
            print("Disconnected")
            
//            redSlider.isEnabled = false
//            greenSlider.isEnabled = false
//            blueSlider.isEnabled = false
//
//            redSlider.value = 0
//            greenSlider.value = 0
//            blueSlider.value = 0
            
            self.peripheral = nil
            
            // Start scanning again
            print("Central scanning for", ParticlePeripheral.particleLEDServiceUUID);
            centralManager.scanForPeripherals(withServices: [ParticlePeripheral.particleLEDServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ParticlePeripheral.particleLEDServiceUUID {
                    print("LED service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([ParticlePeripheral.redLEDCharacteristicUUID,
                                                        ParticlePeripheral.greenLEDCharacteristicUUID,
                                                        ParticlePeripheral.blueLEDCharacteristicUUID], for: service)
                }
                if( service.uuid == ParticlePeripheral.batteryServiceUUID ) {
                    print("Battery service found")
                    peripheral.discoverCharacteristics([ParticlePeripheral.batteryCharacteristicUUID], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("Enabling notify ", characteristic.uuid)
        
        if error != nil {
            print("Enable notify error")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if( characteristic == battChar ) {
            print("Battery:", characteristic.value![0])
            
//            batteryPercentLabel.text = "\(characteristic.value![0])%"
        }
    }
    
    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ParticlePeripheral.redLEDCharacteristicUUID {
                    print("Red LED characteristic found")
                    
                    // Set the characteristic
                    redChar = characteristic
                    
                    // Unmask red slider
//                    redSlider.isEnabled = true
                } else if characteristic.uuid == ParticlePeripheral.greenLEDCharacteristicUUID {
                    print("Green LED characteristic found")
                    
                    // Set the characteristic
                    greenChar = characteristic
                    
                    // Unmask green slider
//                    greenSlider.isEnabled = true
                } else if characteristic.uuid == ParticlePeripheral.blueLEDCharacteristicUUID {
                    print("Blue LED characteristic found");
                    
                    // Set the characteristic
                    blueChar = characteristic
                    
                    // Unmask blue slider
//                    blueSlider.isEnabled = true
                } else if characteristic.uuid == ParticlePeripheral.batteryCharacteristicUUID {
                    print("Battery characteristic found");
                    
                    // Set the char
                    battChar = characteristic
                    
                    // Subscribe to the char.
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    private func writeLEDValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
        // Check if it has the write property
        if characteristic.properties.contains(.writeWithoutResponse) && peripheral != nil {
            peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        }
    }
    
    func redChanged(_ sender: Any) {
        print("red:", redSlider);
        let slider:UInt8 = UInt8(redSlider)
        writeLEDValueToChar(withCharacteristic: redChar!, withValue: Data([slider]))
        
    }
    
    func greenChanged(_ sender: Any) {
        print("green:", greenSlider);
        let slider:UInt8 = UInt8(greenSlider)
        writeLEDValueToChar(withCharacteristic: greenChar!, withValue: Data([slider]))
    }
    
    func blueChanged(_ sender: Any) {
        print("blue:", blueSlider);
        let slider:UInt8 = UInt8(blueSlider)
        writeLEDValueToChar(withCharacteristic: blueChar!, withValue: Data([slider]))
        
    }
}
