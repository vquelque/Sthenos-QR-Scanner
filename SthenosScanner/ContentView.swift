//
//  ContentView.swift
//  SthenosScanner
//
//  Created by Valentin Quelquejay on 05.02.21.
//

import SwiftUI

struct AlertID: Identifiable {
    var id: AlertType
    
    enum AlertType {
        case userNotFound
        case otherError
    }
}

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @State private var QRScannerisPresented: Bool = false
    @State private var alertId: AlertID?
    @State private var fetching = false
    @State private var userID: String?
    @State private var user: User?
    
    var body: some View {
        
        if (!fetching) {
        NavigationView{
            Form{
                Section(header: Text("Profil membre")){
                    Text("\(user?.firstName ?? "")")
                    Text("\(user?.lastName ?? "")")
                    Text("\(user?.genderString ?? "")")
                    if let birthdate =  self.user?.birthdate {
                        Text(birthdate, style: .date)
                    }
                
                
                }
                Section(header: Text("abonnement")){
                    Text("\(user?.validSubscription ?? "")")
                }
                Section(header: Text("Entrées journalière")){
                    if let purchasedEntry = self.user?.purchasedEntry {
                        Text(purchasedEntry, style: .date)
                    }
                }
            }.toolbar(content: {
                ToolbarItem(placement: .principal){
                    Text("Infos Membre")
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Scan") {
                            self.QRScannerisPresented = true
                        }
                }
            }).alert(item: $alertId) {(alertId) -> Alert in
                return createAlert(alertId: alertId)
            }
        }.sheet(isPresented: $QRScannerisPresented) {
            BarCodeScanner(userID:$userID, user:$user, fetching: $fetching, isPresented: $QRScannerisPresented, alertId:$alertId)
        }.onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                //open QR Scanner when app is resumed
                self.QRScannerisPresented = true
                return
            case .background:
                return
            case .inactive:
                return
            @unknown default:
              return
            }
          }
        } else {
            ProgressView()
        }
            
    }
    
    private func createAlert(alertId: AlertID) -> Alert {
        switch alertId.id {
            case .userNotFound:
                return Alert(title: Text("L'utilistateur n'existe pas"))
            case .otherError:
                return Alert(title: Text("Erreur API"))
            }
        }
}



#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
