// MCU.swift
// Pinout reference: https://wiki.seeedstudio.com/XIAO_ESP32C
// https://www.seeedstudio.com/blog/2023/11/08/getting-started-with-the-seeed-xiao-esp32c6/
// 
// Created by Heiko Ritter on every now and then.
// 

// MCU.Pin is coded for Seeed XIAO ESP32C6 board
// Modify the pin numbers to match your board if needed.
public struct MCU {
    private init() {}

    struct Pin {
        static let USER_LED: Int32 = 15
        static let D0: Int32 = 0

    }
}