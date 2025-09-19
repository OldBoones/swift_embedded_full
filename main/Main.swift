//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// The code will blink an LED on GPIO8. To change the pin, modify Led(gpioPin: 8)
@_cdecl("app_main")
func main() {
  let blinkDelayMs: UInt32 = 500
  var high15 = false
  print("Hello from Swift on ESP32-C6!")

  let pin15 = GPIO(pin: 15, direction: .output)
  pin15.write(high15)
  vTaskDelay(blinkDelayMs * 10 / (1000 / UInt32(configTICK_RATE_HZ)))
  log("where is my log?", .error)
  //var ledValue: Bool = false
  //let led = Led(gpioPin: 8)
  pin15.write(!high15)
  vTaskDelay(blinkDelayMs * 10 / (1000 / UInt32(configTICK_RATE_HZ)))
  log("starting main loop", .info)
  while true {
    high15.toggle()
    pin15.write(high15)
    log ("Toggling pin 15 to \(high15)", .warn)
    //led.setLed(value: ledValue)
    //ledValue.toggle()  // Toggle the boolean value
    vTaskDelay(blinkDelayMs / (500 / UInt32(configTICK_RATE_HZ)))
    //log("Nee echt, wieder eine Schleife durchlaufen", level: .debug)
  }
}
