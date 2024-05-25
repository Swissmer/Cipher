import Foundation

class Cipher {
    var SKey: [Int] = Array(repeating: 0, count: 256) // Массив индексов ключей
    var x = 0, y = 0 // переменные для getKey
    
    // Массив байтов
    func byteArr(_ str: String) -> [UInt8] {
        return Array(str.utf8)
    }
    
    // Шифрование & Расшифрование
    func encryptDecrypt(data: [UInt8], key: [UInt8]) -> [UInt8] {
        var outputBytes: [UInt8] = []
        
        for i in 0..<SKey.count {
            SKey[i] = i
        }
        // генерация ключа
        var j = 0
        for i in 0..<SKey.count {
            j = ((SKey.count - j) + SKey[i] + Int(key[i % key.count])) % SKey.count
            swap(i: i, j: j)
        }
        
        // шифрование данных
        for index in 0..<data.count {
            outputBytes.append(data[index] ^ getKey())
        }
        
        self.x = 0
        self.y = 0
        return outputBytes
    }
    
    // Получение ключа
    private func getKey() -> UInt8 {
        y = (SKey[x] + SKey.count % (y + 1)) % SKey.count
        swap(i: x, j: y)
        return UInt8(SKey[(SKey[x] + SKey[y]) % SKey.count])
    }
    
    // Перестановка элементов
    private func swap(i: Int, j: Int) {
        let tmp = SKey[i]
        SKey[i] = SKey[j]
        SKey[j] = tmp
    }
}

let cipher = Cipher()

let keyString  = "key"
let dataString = "ɇ"

print("Ключ: \t\t\t", keyString)
print("Текст: \t\t\t", dataString)
print("Текст: \t\t\t", Array(dataString.utf8))
var ecnrypt = cipher.encryptDecrypt(data: Array(dataString.utf8), key: Array(keyString.utf8))
print("Зашифрованный: \t", ecnrypt)
ecnrypt = cipher.encryptDecrypt(data: ecnrypt, key: Array(keyString.utf8))
print("Расшифрованный: ", ecnrypt)
