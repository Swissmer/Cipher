import Foundation
import CryptoKit

func generatePrivateKey() -> P256.KeyAgreement.PrivateKey {
    let privateKey = P256.KeyAgreement.PrivateKey()
    return privateKey
}

func generatePublicKey(privateKey: P256.KeyAgreement.PrivateKey) -> P256.KeyAgreement.PublicKey {
    return privateKey.publicKey
}


func exportPrivateKey(_ privateKey: P256.KeyAgreement.PrivateKey) -> String {
    let rawPrivateKey = privateKey.rawRepresentation
    let privateKeyBase64 = rawPrivateKey.base64EncodedString()
    let percentEncodedPrivateKey = privateKeyBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    return percentEncodedPrivateKey
}

func importPrivateKey(_ privateKey: String) throws -> P256.KeyAgreement.PrivateKey {
    let privateKeyBase64 = privateKey.removingPercentEncoding!
    let rawPrivateKey = Data(base64Encoded: privateKeyBase64)!
    return try P256.KeyAgreement.PrivateKey(rawRepresentation: rawPrivateKey)
}

func deriveSymmetricKey(privateKey: P256.KeyAgreement.PrivateKey, publicKey: P256.KeyAgreement.PublicKey) throws -> SymmetricKey {
    let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
    
    let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
        using: SHA256.self,
        salt: "My Key Agreement Salt".data(using: .utf8)!,
        sharedInfo: Data(),
        outputByteCount: 32
    )
    
    return symmetricKey
}

func encrypt(text: String, symmetricKey: SymmetricKey) throws -> String {
    let textData = text.data(using: .utf8)!
    let encrypted = try AES.GCM.seal(textData, using: symmetricKey)
    return encrypted.combined!.base64EncodedString()
}

func decrypt(text: String, symmetricKey: SymmetricKey) -> String {
    do {
        guard let data = Data(base64Encoded: text) else {
            return "Could not decode text: \(text)"
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
        
        guard let text = String(data: decryptedData, encoding: .utf8) else {
            return "Could not decode data: \(decryptedData)"
        }
        
        return text
    } catch let error {
        return "Error decrypting message: \(error.localizedDescription)"
    }
}


//// Генерация случайного ключа для участника A
//let privateKeyA = P256.KeyAgreement.PrivateKey()
//
//// Генерация открытого ключа для участника A
//let publicKeyA = privateKeyA.publicKey
//
//// Генерация случайного ключа для участника B
//let privateKeyB = P256.KeyAgreement.PrivateKey()
//
//// Генерация открытого ключа для участника B
//let publicKeyB = privateKeyB.publicKey
//
//// Вычисление общего секретного ключа на стороне A
//let sharedSecretA = try! privateKeyA.sharedSecretFromKeyAgreement(with: publicKeyB)
//
//// Вычисление общего секретного ключа на стороне B
//let sharedSecretB = try! privateKeyB.sharedSecretFromKeyAgreement(with: publicKeyA)
//
//// Проверка совпадения общего секретного ключа на обеих сторонах
//print(sharedSecretA == sharedSecretB)
//
//print("Общий секретный ключ: \(sharedSecretA)")
//
//let sharedSecretString = sharedSecretA.withUnsafeBytes { Data($0) }.map { String(format: "%02x", $0) }.joined()
//print(sharedSecretString.count)
