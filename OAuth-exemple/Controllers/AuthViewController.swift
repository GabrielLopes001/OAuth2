//
//  AuthViewController.swift
//  OAuth-exemple
//
//  Created by Gabriel Lopes on 22/10/24.
//

import SwiftUI
import WebKit

struct AuthViewController: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    AuthViewController()
}

struct WebView: UIViewRepresentable, WKNavigationDelegate {

    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: config)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = AuthManager.shared.signInURL else {
            return
        }
        
        uiView.load(URLRequest(url: url))
    }
    
    
    // criar alguma forma de ao autenticar extrair o Code da URL para que possamos gerar o access_token
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        
        // Extraindo o parametro "Code" da URL
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value else  {
            return
        }
        
        webView.isHidden = true

        // Chamando a funcao que de fato autentica o usuario
        AuthManager.shared.exchangeCodeForToken(code: code) { sucess in
            return true
        }
    }
}
