// LedMatrix8x32 als struct, implementiert LedMatrix-Protokoll
struct LedMatrix8x32 {
    let width: Int = 32
    let height: Int = 8
    let spaceWidth: Int = 1
    let spaceHeight: Int = 0
    let fontWidth: Int = 4
    let fontHeight: Int = 8
    var ledCount: Int { width * height }

    // 26 Buchstaben (A-Z), dann 10 Ziffern (0-9)
    private let font4x8: [[UInt8]] = [
        [0b0110, 0b1001, 0b1001, 0b1111, 0b1001, 0b1001, 0b1001, 0b0000],  // A
        [0b1110, 0b1001, 0b1001, 0b1110, 0b1001, 0b1001, 0b1110, 0b0000],  // B
        [0b0111, 0b1000, 0b1000, 0b1000, 0b1000, 0b1000, 0b0111, 0b0000],  // C
        [0b1110, 0b1001, 0b1001, 0b1001, 0b1001, 0b1001, 0b1110, 0b0000],  // D
        [0b1111, 0b1000, 0b1000, 0b1110, 0b1000, 0b1000, 0b1111, 0b0000],  // E
        [0b1111, 0b1000, 0b1000, 0b1110, 0b1000, 0b1000, 0b1000, 0b0000],  // F
        [0b0111, 0b1000, 0b1000, 0b1011, 0b1001, 0b1001, 0b0111, 0b0000],  // G
        [0b1001, 0b1001, 0b1001, 0b1111, 0b1001, 0b1001, 0b1001, 0b0000],  // H
        [0b1111, 0b0010, 0b0010, 0b0010, 0b0010, 0b0010, 0b1111, 0b0000],  // I
        [0b0001, 0b0001, 0b0001, 0b0001, 0b1001, 0b1001, 0b0110, 0b0000],  // J
        [0b1001, 0b1010, 0b1100, 0b1000, 0b1100, 0b1010, 0b1001, 0b0000],  // K
        [0b1000, 0b1000, 0b1000, 0b1000, 0b1000, 0b1000, 0b1111, 0b0000],  // L
        [0b1001, 0b1111, 0b1111, 0b1001, 0b1001, 0b1001, 0b1001, 0b0000],  // M
        [0b1001, 0b1101, 0b1101, 0b1011, 0b1011, 0b1001, 0b1001, 0b0000],  // N
        [0b0110, 0b1001, 0b1001, 0b1001, 0b1001, 0b1001, 0b0110, 0b0000],  // O
        [0b1110, 0b1001, 0b1001, 0b1110, 0b1000, 0b1000, 0b1000, 0b0000],  // P
        [0b0110, 0b1001, 0b1001, 0b1001, 0b1011, 0b1001, 0b0111, 0b0000],  // Q
        [0b1110, 0b1001, 0b1001, 0b1110, 0b1010, 0b1001, 0b1001, 0b0000],  // R
        [0b0111, 0b1000, 0b1000, 0b0110, 0b0001, 0b0001, 0b1110, 0b0000],  // S
        [0b1111, 0b0010, 0b0010, 0b0010, 0b0010, 0b0010, 0b0010, 0b0000],  // T
        [0b1001, 0b1001, 0b1001, 0b1001, 0b1001, 0b1001, 0b0110, 0b0000],  // U
        [0b1001, 0b1001, 0b1001, 0b1001, 0b1001, 0b0110, 0b0100, 0b0000],  // V
        [0b1001, 0b1001, 0b1001, 0b1001, 0b1111, 0b1111, 0b1001, 0b0000],  // W
        [0b1001, 0b1001, 0b0110, 0b0100, 0b0110, 0b1001, 0b1001, 0b0000],  // X
        [0b1001, 0b1001, 0b0110, 0b0100, 0b0100, 0b0100, 0b0100, 0b0000],  // Y
        [0b1111, 0b0001, 0b0010, 0b0100, 0b1000, 0b1000, 0b1111, 0b0000],  // Z
        // Ziffern 0-9
        [0b0110, 0b1001, 0b1001, 0b1001, 0b1001, 0b1001, 0b0110, 0b0000],  // 0
        [0b0010, 0b0110, 0b1010, 0b0010, 0b0010, 0b0010, 0b0111, 0b0000],  // 1
        [0b0110, 0b1001, 0b0001, 0b0010, 0b0100, 0b1000, 0b1111, 0b0000],  // 2
        [0b1110, 0b0001, 0b0010, 0b0110, 0b0001, 0b1001, 0b0110, 0b0000],  // 3
        [0b0001, 0b0011, 0b0101, 0b1001, 0b1111, 0b0001, 0b0001, 0b0000],  // 4
        [0b1111, 0b1000, 0b1110, 0b0001, 0b0001, 0b1001, 0b0110, 0b0000],  // 5
        [0b0110, 0b1000, 0b1110, 0b1001, 0b1001, 0b1001, 0b0110, 0b0000],  // 6
        [0b1111, 0b0001, 0b0010, 0b0100, 0b0100, 0b0100, 0b0100, 0b0000],  // 7
        [0b0110, 0b1001, 0b0110, 0b1001, 0b1001, 0b1001, 0b0110, 0b0000],  // 8
        [0b0110, 0b1001, 0b1001, 0b0111, 0b0001, 0b0001, 0b0110, 0b0000],  // 9

        // SPACE (2 Spalten breit)
        [0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000],  // ' ' (erste Hälfte)
        [0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000],  // ' ' (zweite Hälfte)
        // Sonderzeichen: Leerzeichen, Bindestrich, Ausrufezeichen, Punkt, Komma, Doppelpunkt, Fragezeichen, Unterstrich, Gleichheitszeichen, Plus, Stern, Slash, Prozent, Klammern, etc.
        // SPACE
        [0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000],  // ' '
        // !
        [0b0010, 0b0010, 0b0010, 0b0010, 0b0010, 0b0000, 0b0010, 0b0000],  // '!'
        // "
        [0b0101, 0b0101, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000],  // '"'
        // #
        [0b0101, 0b1111, 0b0101, 0b0101, 0b1111, 0b0101, 0b0101, 0b0000],  // '#'
        // $
        [0b0010, 0b0111, 0b1010, 0b0110, 0b0011, 0b1010, 0b0111, 0b0010],  // '$'
        // %
        [0b1100, 0b1101, 0b0001, 0b0010, 0b0100, 0b1011, 0b0011, 0b0000],  // '%'
        // &
        [0b0110, 0b1001, 0b1010, 0b0100, 0b1010, 0b1001, 0b0110, 0b0000],  // '&'
        // '
        [0b0010, 0b0010, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000],  // '''
        // (
        [0b0001, 0b0010, 0b0100, 0b0100, 0b0100, 0b0010, 0b0001, 0b0000],  // '('
        // )
        [0b1000, 0b0100, 0b0010, 0b0010, 0b0010, 0b0100, 0b1000, 0b0000],  // ')'
        // *
        [0b0000, 0b0101, 0b0010, 0b1111, 0b0010, 0b0101, 0b0000, 0b0000],  // '*'
        // +
        [0b0000, 0b0010, 0b0010, 0b1111, 0b0010, 0b0010, 0b0000, 0b0000],  // '+'
        // ,
        [0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0010, 0b0010, 0b0100],  // ','
        // -
        [0b0000, 0b0000, 0b0000, 0b1111, 0b0000, 0b0000, 0b0000, 0b0000],  // '-'
        // .
        [0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0010, 0b0010, 0b0000],  // '.'
        // /
        [0b0001, 0b0010, 0b0010, 0b0100, 0b0100, 0b1000, 0b1000, 0b0000],  // '/'
        // :
        [0b0000, 0b0010, 0b0010, 0b0000, 0b0000, 0b0010, 0b0010, 0b0000],  // ':'
        // ;
        [0b0000, 0b0010, 0b0010, 0b0000, 0b0000, 0b0010, 0b0010, 0b0100],  // ';'
        // <
        [0b0001, 0b0010, 0b0100, 0b1000, 0b0100, 0b0010, 0b0001, 0b0000],  // '<'
        // =
        [0b0000, 0b1111, 0b0000, 0b1111, 0b0000, 0b0000, 0b0000, 0b0000],  // '='
        // >
        [0b1000, 0b0100, 0b0010, 0b0001, 0b0010, 0b0100, 0b1000, 0b0000],  // '>'
        // ?
        [0b0110, 0b1001, 0b0001, 0b0010, 0b0010, 0b0000, 0b0010, 0b0000],  // '?'
        // @
        [0b0110, 0b1001, 0b0001, 0b0111, 0b1011, 0b1011, 0b0110, 0b0000],  // '@'
        // [
        [0b0110, 0b0100, 0b0100, 0b0100, 0b0100, 0b0100, 0b0110, 0b0000],  // '['
        // \
        [0b1000, 0b1000, 0b0100, 0b0100, 0b0010, 0b0010, 0b0001, 0b0000],  // '\'
        // ]
        [0b0110, 0b0010, 0b0010, 0b0010, 0b0010, 0b0010, 0b0110, 0b0000],  // ']'
        // ^
        [0b0010, 0b0101, 0b1001, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000],  // '^'
        // _
        [0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b1111, 0b0000],  // '_'
        // `
        [0b0100, 0b0010, 0b0001, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000],  // '`'
    ]

    /// Returns the pixel indices for a single ASCII character (A-Z, 0-9) on an 8x32 matrix.
    /// - Parameter character: ASCII code (e.g., 65 for 'A')
    /// - Parameter xOffset: Starting column (default: 0)
    /// - Returns: Array with the indices of the pixels to be set

    // Liefert die Pixel-Indizes für ein Zeichen (Protokoll)
    func getCharacterPixels(char: Character, xPos: Int, yPos: Int = 0) -> [Int] {
        let code = UInt8(truncatingIfNeeded: char.unicodeScalars.first?.value ?? 32)
        return getCharacterArray(character: code, xOffset: xPos, yOffset: yPos)
    }

    // Liefert die Pixel-Indizes für eine Zeichenkette (Protokoll)
    func getMessagePixels(msg: String, xPos: Int, yOffset: Int = 0) -> [Int] {
        var indices: [Int] = []
        var x = xPos
        for scalar in msg.unicodeScalars {
            let code = UInt8(truncatingIfNeeded: scalar.value)
            indices += getCharacterArray(character: code, xOffset: x, yOffset: yOffset)
            x += fontWidth + spaceWidth
            if x >= width { break }
        }
        return indices
    }

    // Mapping von (x, y) auf Index (Protokoll)

    func getIndexXY(x: Int, y: Int) -> Int {
        guard x >= 0 && x < width && y >= 0 && y < height else { return -1 }
        let base = x * height
        if x % 2 == 0 {
            return base + (height - 1 - y)
        } else {
            return base + y
        }
    }

    /// Umkehrfunktion: Berechnet (x, y) aus einem Index
    func getXY(index: Int) -> (x: Int, y: Int) {
        let x = index / height
        let base = x * height
        let offset = index - base
        let y: Int
        if x % 2 == 0 {
            y = height - 1 - offset
        } else {
            y = offset
        }
        return (x, y)
    }

    func getIndex(x: Int, y: Int) -> Int {
        return getIndexXY(x: x, y: y)
    }

    // Hilfsfunktion für ein Zeichen (wie bisher)
    func getCharacterArray(character: UInt8, xOffset: Int = 0, yOffset: Int = 0) -> [Int] {
        var indices: [Int] = []
        var code = character
        if code >= 97 && code <= 122 { code -= 32 }
        let bitmap: [UInt8]?
        if code >= 0x41 && code <= 0x5A {
            // A-Z
            bitmap = font4x8[Int(code - 0x41)]
        } else if code >= 0x30 && code <= 0x39 {
            // 0-9
            bitmap = font4x8[26 + Int(code - 0x30)]
        } else if code == 0x20 {
            // SPACE
            bitmap = font4x8[36]
        } else if code >= 0x21 && code <= 0x60 {
            // Sonderzeichen von '!' (0x21) bis '`' (0x60)
            let specialIndex = 37 + Int(code - 0x21)
            if specialIndex < font4x8.count {
                bitmap = font4x8[specialIndex]
            } else {
                bitmap = nil
            }
        } else {
            bitmap = nil
        }
        if let bitmap = bitmap {
            for col in (0..<fontWidth).reversed() {
                let x = xOffset + (fontWidth - 1 - col)
                if x >= width { break }
                for row in 0..<fontHeight {
                    let bit = (bitmap[row] >> col) & 0x1
                    if bit == 1 {
                        let y = fontHeight - 1 - row + yOffset
                        if y < 0 || y >= height { continue }
                        let idx = getIndex(x: x, y: y)
                        if idx >= 0 { indices.append(idx) }
                    }
                }
            }
        }
        return indices
    }
}

/// Gibt die Pixel-Indizes für eine Zeichenkette (A-Z, 0-9) auf einer 8x32 Matrix zurück.
/// - Parameter msg: String (nur A-Z, 0-9, a-z)
/// - Parameter xPos: Startspalte (Standard: 0)
/// - Returns: Array mit den Indizes der zu setzenden Pixel für die gesamte Zeichenkette