//
//  ViewController.swift
//  Json
//
//  Created by zhanghao on 2024/2/18.
//

import UIKit
import SwiftyRSA
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        公钥加密数据，私钥解密数据
//        重新生成私钥和公钥，leancloud中zitie_pdf中数据需要重新替换
//        let keyPair = try! SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
//        let privateKey = keyPair.privateKey
//        let publicKey = keyPair.publicKey
        
//        do {
//            let pem = try privateKey.pemString()
//            print(pem)
//        } catch  {
//            
//        }
//        
//        do {
//            let pem2 = try publicKey.pemString()
//            print(pem2)
//        } catch  {
//            
//        }
        // 获取 .plist 文件的路径
        let path = Bundle.main.path(forResource: "Keys", ofType: "plist")
        // 从 .plist 文件中获取密钥
        let dict = NSDictionary(contentsOfFile: path!)
        let key = dict?.value(forKey: "publicKey") as? String
        do {
            let publicKey = try PublicKey(pemEncoded: key!)
//            let encrypted = try EncryptedMessage(base64Encoded: data)
//            let clear = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
//            let string = try! clear.string(encoding: .utf8)
//            return publicKey
//              print(publicKey)
            begin(publicKey: publicKey)
        } catch  {}
    }

    func begin(publicKey:PublicKey) {
        let path = Bundle.main.path(forResource: "zitie_pdf", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        var dataArr = Array<Dictionary<String, Any>>()
        do {
            let data = try Data(contentsOf: url)
                let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let arr : Array<Dictionary> = jsonData as! Array<Dictionary<String, Any>>
            for dic in arr {
                let cover: String = dic["cover"] as! String
                let url : String = dic["url"] as! String
                let cover_jiami = jiami(str: cover, publicKey: publicKey)
                let url_jiami = jiami(str: url, publicKey: publicKey)
                var newDic = dic
                newDic["cover"] = cover_jiami
                newDic["url"] = url_jiami
                
                
                print("cover_jiami====\(cover_jiami)")
                print("url_jiami====\(url_jiami)")
                dataArr.append(newDic)
            }
//            print(jsonData)
        } catch let error as Error? {
            print("读取本地数据出现错误!",error as Any)
        }
        
        // 创建 JSON 数据
        let jsonData = try? JSONSerialization.data(withJSONObject: dataArr, options: [])
        // 本地文件路径
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("data.json")
//        print(fileURL)
        // 保存到本地
        do {
            try jsonData!.write(to: fileURL)
        } catch {
            print("Error writing file: \(error)")
        }
    }
    func jiami(str:String,publicKey:PublicKey) -> String {
        do {
            let pem = try publicKey.pemString()
            _ = try PublicKey(pemEncoded: pem)
            let clear = try ClearMessage(string: str, using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            let base64String = encrypted.base64String
//            print(base64String)
//            let jiemihou = decryptData(data: base64String)
//            print("jiemi=====\(jiemihou)")
            return base64String
        } catch _ as Error? {
            
        }
        return ""
    }
    
    func decryptData(data:String) -> String {
        // 获取 .plist 文件的路径
        let path = Bundle.main.path(forResource: "Keys", ofType: "plist")
        // 从 .plist 文件中获取密钥
        let dict = NSDictionary(contentsOfFile: path!)
        let key = dict?.value(forKey: "privateKey") as? String
        do {
            let privateKey = try PrivateKey(pemEncoded: key!)
            let encrypted = try EncryptedMessage(base64Encoded: data)
            let clear = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
            let string = try! clear.string(encoding: .utf8)
            return string
//            print(string2)
        } catch  {
        
        }
        return ""
    }
}


