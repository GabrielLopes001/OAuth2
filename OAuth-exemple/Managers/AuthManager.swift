//
//  AuthManager.swift
//  OAuth-exemple
//
//  Created by Gabriel Lopes on 22/10/24.
//

import Foundation

class AuthManager {
    // singleton
    static let shared = AuthManager()
    
    // chaves API
    struct Constans {
        static let clientID = ""
        static let clientSecret = ""
        static let tokenAPIURL = "endpoint_para_gerar_access_token"
        static let scopes = "scopes_de_acesso"
        static let redirectURL = "url_redirecionamento"
    }
    
    private init() {}
    
    // criando a URL de autenticacao com parametros pedidos pelo API (Spotify)
    public var signInURL: URL? {
        let base = "url_base_de_autenticacao"
        let string = "\(base)?response_type=code&client_id=\(Constans.clientID)&scope=\(Constans.scopes)&redirect_uri=\(Constans.redirectURL)"
        
        return URL(string: string)
    }
    
    // verificando se possui token
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    // buscando o token
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    // buscando o refresh token
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    
    // buscando a data de expiracao do token
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    // se devemos renovar o token
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        
        let minutes: TimeInterval =  300
        let current = Date()
        
        return current.addingTimeInterval(minutes) >= expirationDate
    }
    
    // usando o Code ja extraído para fazer autenticacao
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        guard let url = URL(string: Constans.tokenAPIURL) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
     
        // transformando o token em base64 para usar como authorization no header
        let basicToken = Constans.clientID+":"+Constans.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let basicToken64 = data?.base64EncodedString() else {
            completion(false)
            return
        }
        
        // setando os headers
        request.setValue("Basic \(basicToken64)", forHTTPHeaderField: "Authorization")
        request.setValue("", forHTTPHeaderField: "Content-type")
        
        // criando os parametros obrigatorios da API
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "parametro", value: "valor")
        ]
        
        // setando o body
        request.httpBody = components.query?.data(using: .utf8)
        
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                
                let result = try JSONDecoder().decode(AuthReponse.self, from: data)
                
                // salvando o resultado localmente para nao precisa autenticar novamente
                self?.cacheToken(result: result)
                completion(true)
                
            } catch {
                
            }
        }
        
        task.resume()
    }
    
    public func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard shouldRefreshToken else {
            completion(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        // refresh the token
         // faz a mesma chamada do codigo de autenticaçao, mudando apenas a URL e parametros de acordo com a API
    }
    
    private func cacheToken(result: AuthReponse) {
        // Salvando os dados de autenticacao com UserDefault (pode mudar)
        
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        
        // Salvando o refresh token se ele vier no result
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(result.refresh_token, forKey: "refresh_token")
        }
        
        // Convertentando o expire que vem em segundo para uma data para maior facilidade
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
}
