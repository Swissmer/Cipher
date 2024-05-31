import Foundation

class Cipher {
    var SBlock: [Int] = Array(repeating: 0, count: 256) // S-block
    
    // Шифрование & Расшифрование
    func encryptDecrypt(data: [UInt8], key: [UInt8]) -> [UInt8] {
        var outputBytes: [UInt8] = []
        
        generationSBlock(key: key)
        
        var indexForSwapKey1 = 0
        var indexForSwapKey2 = 0
        // шифрование данных
        for index in 0..<data.count {
            indexForSwapKey1 = index
            outputBytes.append(data[index] ^ getKey(indexForSwapKey1: indexForSwapKey1, indexForSwapKey2: &indexForSwapKey2))
        }
        
        return outputBytes
    }
    
    // генерация S-блока
    private func generationSBlock(key: [UInt8]) {
        for i in 0..<SBlock.count {
            SBlock[i] = i
        }
        
        var j = 0
        for i in 0..<SBlock.count {
            j = ((SBlock.count - j) + SBlock[i] + Int(key[i % key.count])) % SBlock.count
            swap(i: i, j: j)
        }
    }
    
    // Получение ключа
    private func getKey(indexForSwapKey1: Int, indexForSwapKey2: inout Int) -> UInt8 {
        indexForSwapKey2 = (SBlock[indexForSwapKey1] + SBlock.count % (indexForSwapKey2 + 1)) % SBlock.count
        swap(i: indexForSwapKey1, j: indexForSwapKey2)
        return UInt8(SBlock[(SBlock[indexForSwapKey1] + SBlock[indexForSwapKey2]) % SBlock.count])
    }
    
    // Перестановка элементов
    private func swap(i: Int, j: Int) {
        let tmp = SBlock[i]
        SBlock[i] = SBlock[j]
        SBlock[j] = tmp
    }
}

let cipher = Cipher()

let keyString  = "key"
let dataString = "Daniil Semenov!"

print("Ключ: \t\t\t", keyString)
print("Текст: \t\t\t", dataString)
print("Текст: \t\t\t", Array(dataString.utf8))

var ciphertext = cipher.encryptDecrypt(data: Array(dataString.utf8), key: Array(keyString.utf8))
print("Зашифрованный: \t", ciphertext)

var decryptedText = cipher.encryptDecrypt(data: ciphertext, key: Array(keyString.utf8))
print("Расшифрованный: ", decryptedText)
