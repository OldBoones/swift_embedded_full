// LED-Strip or LED-Matrix can be handled here.
// TODO: Implement common functionality for LED strips and matrices
// TODO: Make a base class with common functionality and overwrite functions and properties for different matrices/stripes
// TODO: Implement a way to set the refresh mode for the LED strip
// TODO: Make the whole ledStrip class more modular and reusable
// TODO: Manage the LEDStrip asynchronously (with DispatchQueue?)

struct LedStrip {
  enum RefreshMode: Equatable {
    case onUpdate
    case onFinish
    case onDemand
    case onStep
    case delayed(ms: UInt64)  // TODO: Write a async function to handle delayed refresh
  }

  public let matrix: LedMatrix8x32
  private let handle: led_strip_handle_t
  public var brightness: Float = 1.0
  public var maxLeds: Int { matrix.ledCount }

  init(gpioPin: Int, maxLeds: Int) {
    self.matrix = LedMatrix8x32()

    var handle = led_strip_handle_t(bitPattern: 0)
    var stripConfig = led_strip_config_t(
      strip_gpio_num: Int32(gpioPin),
      max_leds: UInt32(maxLeds),
      led_model: LED_MODEL_WS2812,
      color_component_format: LED_STRIP_COLOR_COMPONENT_FMT_GRB_CONST,
      flags: .init(invert_out: 0)
    )
    var spiConfig = led_strip_spi_config_t(
      clk_src: SPI_CLK_SRC_DEFAULT,
      spi_bus: SPI2_HOST,
      flags: .init(with_dma: 1)
    )
    guard led_strip_new_spi_device(&stripConfig, &spiConfig, &handle) == ESP_OK,
      let handle = handle
    else { fatalError("cannot configure spi device") }
    self.handle = handle
  }

  //MARK: Colors
  func getColor(from rgb: (UInt8, UInt8, UInt8)) -> Color {
    return Color(r: rgb.0, g: rgb.1, b: rgb.2)
  }
  func getColor(r: UInt8, g: UInt8, b: UInt8) -> Color {
    return Color(r: r, g: g, b: b)
  }

  struct Color {
    func withBrightness(_ value: Float) -> Color {
      return Color(
        r: UInt8(Float(r) * value),
        g: UInt8(Float(g) * value),
        b: UInt8(Float(b) * value)
      )
    }
    static let white = Color(r: 255, g: 255, b: 255)
    static let darkRed = Color(r: 3, g: 0, b: 0)
    static let darkGreen = Color(r: 0, g: 3, b: 0)
    static let darkBlue = Color(r: 0, g: 0, b: 3)
    static let darkYellow = Color(r: 3, g: 3, b: 0)
    static let darkPurple = Color(r: 3, g: 0, b: 3)
    static let darkCyan = Color(r: 0, g: 3, b: 3)
    static let darkOrange = Color(r: 3, g: 1, b: 0)

    static let lightWhite = Color(r: 16, g: 16, b: 16)
    static let lightRed = Color(r: 16, g: 0, b: 0)
    static let lightGreen = Color(r: 0, g: 16, b: 0)
    static let lightBlue = Color(r: 0, g: 0, b: 16)
    static let lightYellow = Color(r: 16, g: 16, b: 0)
    static let lightPurple = Color(r: 16, g: 0, b: 16)
    static let lightCyan = Color(r: 0, g: 16, b: 16)
    static let lightOrange = Color(r: 16, g: 8, b: 0)
    static let lightPink = Color(r: 16, g: 0, b: 8)

    static let mediumWhite = Color(r: 50, g: 50, b: 50)
    static let mediumRed = Color(r: 50, g: 0, b: 0)
    static let mediumGreen = Color(r: 0, g: 50, b: 0)
    static let mediumBlue = Color(r: 0, g: 0, b: 50)
    static let mediumYellow = Color(r: 50, g: 50, b: 0)
    static let mediumPurple = Color(r: 50, g: 0, b: 50)
    static let mediumCyan = Color(r: 0, g: 50, b: 50)
    static let mediumOrange = Color(r: 50, g: 25, b: 0)
    static let mediumPink = Color(r: 50, g: 0, b: 25)

    static let brightWhite = Color(r: 255, g: 255, b: 255)
    static let brightRed = Color(r: 255, g: 0, b: 0)
    static let brightGreen = Color(r: 0, g: 255, b: 0)
    static let brightBlue = Color(r: 0, g: 0, b: 255)
    static let brightYellow = Color(r: 255, g: 255, b: 0)
    static let brightPurple = Color(r: 255, g: 0, b: 255)
    static let brightCyan = Color(r: 0, g: 255, b: 255)
    static let brightOrange = Color(r: 255, g: 128, b: 0)
    static let brightPink = Color(r: 255, g: 0, b: 128)

    // random colors
    static var darkRandom: Color {
      Color(
        r: .random(in: 0...5), g: .random(in: 0...5), b: .random(in: 0...5))
    }
    static var lightRandom: Color {
      Color(
        r: .random(in: 0...16), g: .random(in: 0...16), b: .random(in: 0...16))
    }
    static var mediumRandom: Color {
      Color(
        r: .random(in: 15...50), g: .random(in: 15...50), b: .random(in: 15...50))
    }

    static let off = Color(r: 0, g: 0, b: 0)

    var r, g, b: UInt8

    static func colorWheel(from color: Color, steps: Int, to: Color, rainbowMode: Bool = false)
      -> [Color]
    {
      // Rainbow: HSL-Interpolation, Hue von color zu to, S und L fix
      // TODO: Implement HSL interpolation
      // TODO: Move Colormanagement to separate file
      guard steps > 1 else { return [color, to] }
      var result: [Color] = []
      if rainbowMode {
        // Rainbow: HSL-Interpolation, Hue von color zu to, S und L fix
        func rgbToHsl(_ c: Color) -> (h: Float, s: Float, l: Float) {
          let r = Float(c.r) / 255.0
          let g = Float(c.g) / 255.0
          let b = Float(c.b) / 255.0
          let maxV = max(r, g, b)
          let minV = min(r, g, b)
          let l = (maxV + minV) / 2
          var h: Float = 0
          var s: Float = 0
          if maxV != minV {
            let d = maxV - minV
            s = l > 0.5 ? d / (2 - maxV - minV) : d / (maxV + minV)
            if maxV == r {
              h = (g - b) / d + (g < b ? 6 : 0)
            } else if maxV == g {
              h = (b - r) / d + 2
            } else {
              h = (r - g) / d + 4
            }
            h /= 6
          }
          return (h, s, l)
        }
        func hslToRgb(h: Float, s: Float, l: Float) -> Color {
          var r: Float = l
          var g: Float = l
          var b: Float = l
          if s != 0 {
            func hue2rgb(p: Float, q: Float, t: Float) -> Float {
              var t = t
              if t < 0 { t += 1 }
              if t > 1 { t -= 1 }
              if t < 1 / 6 { return p + (q - p) * 6 * t }
              if t < 1 / 2 { return q }
              if t < 2 / 3 { return p + (q - p) * (2 / 3 - t) * 6 }
              return p
            }
            let q = l < 0.5 ? l * (1 + s) : l + s - l * s
            let p = 2 * l - q
            r = hue2rgb(p: p, q: q, t: h + 1 / 3)
            g = hue2rgb(p: p, q: q, t: h)
            b = hue2rgb(p: p, q: q, t: h - 1 / 3)
          }
          return Color(r: UInt8(r * 255), g: UInt8(g * 255), b: UInt8(b * 255))
        }
        let hslStart = rgbToHsl(color)
        let hslEnd = rgbToHsl(to)
        for i in 0..<steps {
          let t = Float(i) / Float(steps - 1)
          // Hue im Kreis interpolieren
          var dh = hslEnd.h - hslStart.h
          if abs(dh) > 0.5 { dh -= (dh > 0 ? 1 : -1) }
          let h = hslStart.h + dh * t
          let s = hslStart.s + (hslEnd.s - hslStart.s) * t
          let l = hslStart.l + (hslEnd.l - hslStart.l) * t
          result.append(hslToRgb(h: h, s: s, l: l))
        }
      } else {
        // Linear RGB interpolation
        for i in 0..<steps {
          let t = Float(i) / Float(steps - 1)
          let r = UInt8(Float(color.r) + (Float(to.r) - Float(color.r)) * t)
          let g = UInt8(Float(color.g) + (Float(to.g) - Float(color.g)) * t)
          let b = UInt8(Float(color.b) + (Float(to.b) - Float(color.b)) * t)
          result.append(Color(r: r, g: g, b: b))
        }
      }
      return result
    }
  }

  // MARK: Drawings
  func setMessage(
    msg: String, color: Color, xPos: Int = 0, yPos: Int = 0, clean: Bool = true,
    refresh: RefreshMode = .onDemand
  ) {
    var indices = matrix.getMessagePixels(msg: msg, xPos: xPos)
    if indices.count > matrix.ledCount {
      indices = Array(indices[0..<matrix.ledCount])
    }

    if clean {
      clear()
    }

    for idx in indices {
      setPixel(index: idx, color: color)
      if refresh == .onUpdate {
        led_strip_refresh(handle)
      }
    }

    if refresh == .onFinish {
      led_strip_refresh(handle)
    }
  }

  func setMessageLong(
    msg: String, color: Color, stepDuration: UInt64 = 200, refresh: RefreshMode = .onStep,
    repeats: Int = 3
  ) {
    // Laufschrift: Text startet ganz rechts und scrollt nach links aus der Matrix
    let fontWidth = matrix.fontWidth
    let spaceWidth = matrix.spaceWidth
    let maxColumns = matrix.width
    let msgPixelLen = msg.utf8.count * (fontWidth + spaceWidth)
    // Startposition: Text beginnt ganz rechts außerhalb der Matrix
    let startX = maxColumns
    // Endposition: Text ist ganz links aus der Matrix verschwunden
    let endX = -(msgPixelLen)
    for rep in 0..<repeats {
      log("Laufschrift '\(msg)' Wiederholung \(rep + 1)/\(repeats)", .info)
      for xPos in stride(from: startX, through: endX, by: -1) {
        clear()
        let indices = matrix.getMessagePixels(msg: msg, xPos: xPos)
        for idx in indices {
          setPixel(index: idx, color: color)
        }
        led_strip_refresh(handle)
        MCU.Time.wait(ms: stepDuration)
      }
    }
  }

  func fill(with color: Color, refresh: RefreshMode = .onFinish, stepDuration: UInt64 = 0) {
    for i in 0..<matrix.ledCount {
      setPixel(index: i, color: color)
      if refresh == .onUpdate {
        led_strip_refresh(handle)
      }
      if stepDuration > 0 {
        MCU.Time.wait(ms: stepDuration)
      }
    }
    if refresh == .onFinish || refresh == .onStep {
      led_strip_refresh(handle)
    }
  }

  func columnWalk(with color: Color, refresh: RefreshMode = .onStep, stepDuration: UInt64 = 100) {
    for col in 0..<matrix.width {
      for row in 0..<matrix.height {
        let index = matrix.getIndex(x: col, y: row)
        setPixel(index: index, color: color)
        if refresh == .onUpdate {
          led_strip_refresh(handle)
          wait(stepDuration)
        }
      }
      if refresh == .onStep {
        led_strip_refresh(handle)
      }
      wait(stepDuration)
    }
    if refresh == .onFinish {
      led_strip_refresh(handle)
    }
  }

  func rowWalk(with color: Color, refresh: RefreshMode = .onStep, stepDuration: UInt64 = 100) {
    for row in 0..<matrix.height {
      for col in 0..<matrix.width {
        let index = matrix.getIndex(x: col, y: row)
        setPixel(index: index, color: color)
        if refresh == .onUpdate {
          led_strip_refresh(handle)
        }
      }
      if refresh == .onStep {
        led_strip_refresh(handle)
      }
      MCU.Time.wait(ms: stepDuration)
    }
    if refresh == .onFinish {
      led_strip_refresh(handle)
    }
  }

  func fadeColors(
    from: Color, to: Color, steps: Int, rainbowMode: Bool = false, refresh: RefreshMode = .onStep,
    stepDuration: UInt64 = 50
  ) {
    let colors = Color.colorWheel(from: from, steps: steps, to: to, rainbowMode: rainbowMode)
    for color in colors {
      fill(with: color, refresh: refresh)
      MCU.Time.wait(ms: stepDuration)
    }
  }

  // MARK: Bridged Functions

  func setPixel(index: Int, color: Color) {
    led_strip_set_pixel(
      handle, UInt32(index), UInt32(color.r), UInt32(color.g), UInt32(color.b))
  }

  func refresh() { led_strip_refresh(handle) }

  func clear() { led_strip_clear(handle) }

  /// Verschiebt die Pixel-Indices um x und y auf der Matrix und gibt die neuen Indices zurück
  /// - Parameters:
  ///   - pixels: Array von Pixel-Indizes
  ///   - x: Offset in x-Richtung
  ///   - y: Offset in y-Richtung
  /// - Returns: Array der verschobenen Pixel-Indizes
  func offset(pixels: [Int], x: Int, y: Int) -> [Int] {
    return pixels.compactMap { idx in
      let (origX, origY) = matrix.getXY(index: idx)
      let newX = origX + x
      let newY = origY + y
      // Prüfe, ob die neuen Koordinaten im gültigen Bereich liegen
      guard newX >= 0, newX < matrix.width, newY >= 0, newY < matrix.height else { return nil }
      return matrix.getIndex(x: newX, y: newY)
    }
  }
}