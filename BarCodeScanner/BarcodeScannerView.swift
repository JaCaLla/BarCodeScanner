import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @State private var scannedCode: String?
    @State private var isScanning = true
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text("Scan a Barcode")
                .font(.largeTitle)
                .padding()

            ZStack {
                ScannerPreview(isScanning: $isScanning,
                               didFindBarcode: { value in
                    scannedCode = value
                    showAlert = true
                }).edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if let scannedCode = scannedCode {
                            Text("Scanned Code: \(scannedCode)")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }

            if !isScanning {
                Button("Start Scanning Again") {
                    self.isScanning = true
                    self.scannedCode = nil
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .onAppear {
            self.scannedCode = nil
            self.isScanning = true
        }
    }
}

struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannerView()
    }
}
