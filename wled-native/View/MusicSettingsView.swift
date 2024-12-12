//
//  MusicSettingsView.swift
//  wled-native
//
//  Created by Micah Kimel on 12/9/24.
//

import SwiftUI

struct MusicSettingsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var startAudioCaptureButtonActive: Bool
    
    @EnvironmentObject var myAudio: AudioIntensityManager
    
    
    @State private var selectedColorHigh1 = Color.red
    @State private var selectedColorLow1 = Color.red
    
    @State private var selectedColorHigh2 = Color.green
    @State private var selectedColorLow2 = Color.green
    
    @State private var selectedColorHigh3 = Color.blue
    @State private var selectedColorLow3 = Color.blue
    
    var body: some View {
        VStack{
            ScrollView{
                if (startAudioCaptureButtonActive) {
                    // Set to capture Screen or Mic input
                    Toggle("Toggle Screen Audio / Mic Audio", isOn: $myAudio.isScreenAudio)
                    if myAudio.isScreenAudio {
                        Text("Screen Audio On")
                    } else {
                        Text("Mic Audio On")
                    }
                    
                    // Set how often to send updates
                    TextField("Update Time Rate", text: Binding<String>(get: {
                        String(format: "%.2f", self.myAudio.updateTime)
                    }, set: {
                        self.myAudio.updateTime = Float($0) ?? 0.0
                    }))
                    .keyboardType(.decimalPad)
                    
                    // Set min Intensity
                    TextField("Audio Min Intensity", text: Binding<String>(get: {
                        String(format: "%.2f", self.myAudio.minIntensity)
                    }, set: {
                        self.myAudio.minIntensity = Float($0) ?? 0.0
                    }))
                    .keyboardType(.decimalPad)
                    
                    // Color Updates
                    Stepper("Colors: \(myAudio.ColorCount)", value: $myAudio.ColorCount, in: 0...3)
                    
                    // Set basic color transitions
                    if myAudio.ColorCount > 0 {
                        ColorPicker("Select First Color Low Intensity", selection: $selectedColorLow1)
                            .onChange(of: selectedColorLow1) { newValue in
                                let uiColor: UIColor = UIColor(selectedColorLow1)
                                
                                var red: CGFloat = 0
                                var green: CGFloat = 0
                                var blue: CGFloat = 0
                                var alpha: CGFloat = 0
                                
                                uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                                
                                myAudio.rgbValuesLow1 = [Int64(red * 255), Int64(green * 255), Int64(blue * 255)]
                            }
                        
                        ColorPicker("Select First Color High Intensity", selection: $selectedColorHigh1)
                            .onChange(of: selectedColorHigh1) { newValue in
                                let uiColor: UIColor = UIColor(selectedColorHigh1)
                                
                                var red: CGFloat = 0
                                var green: CGFloat = 0
                                var blue: CGFloat = 0
                                var alpha: CGFloat = 0
                                
                                uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                                
                                myAudio.rgbValuesHigh1 = [Int64(red * 255), Int64(green * 255), Int64(blue * 255)]
                            }
                    }
                    if myAudio.ColorCount > 1 {
                        ColorPicker("Select First Color Low Intensity", selection: $selectedColorLow2)
                            .onChange(of: selectedColorLow2) { newValue in
                                let uiColor: UIColor = UIColor(selectedColorLow2)
                                
                                var red: CGFloat = 0
                                var green: CGFloat = 0
                                var blue: CGFloat = 0
                                var alpha: CGFloat = 0
                                
                                uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                                
                                myAudio.rgbValuesLow2 = [Int64(red * 255), Int64(green * 255), Int64(blue * 255)]
                            }
                        
                        ColorPicker("Select First Color High Intensity", selection: $selectedColorHigh2)
                            .onChange(of: selectedColorHigh2) { newValue in
                                let uiColor: UIColor = UIColor(selectedColorHigh2)
                                
                                var red: CGFloat = 0
                                var green: CGFloat = 0
                                var blue: CGFloat = 0
                                var alpha: CGFloat = 0
                                
                                uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                                
                                myAudio.rgbValuesHigh2 = [Int64(red * 255), Int64(green * 255), Int64(blue * 255)]
                            }
                    }
                    if myAudio.ColorCount > 2 {
                        ColorPicker("Select First Color Low Intensity", selection: $selectedColorLow3)
                            .onChange(of: selectedColorLow3) { newValue in
                                let uiColor: UIColor = UIColor(selectedColorLow3)
                                
                                var red: CGFloat = 0
                                var green: CGFloat = 0
                                var blue: CGFloat = 0
                                var alpha: CGFloat = 0
                                
                                uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                                
                                myAudio.rgbValuesLow3 = [Int64(red * 255), Int64(green * 255), Int64(blue * 255)]
                            }
                        
                        ColorPicker("Select First Color High Intensity", selection: $selectedColorHigh3)
                            .onChange(of: selectedColorHigh3) { newValue in
                                let uiColor: UIColor = UIColor(selectedColorHigh3)
                                
                                var red: CGFloat = 0
                                var green: CGFloat = 0
                                var blue: CGFloat = 0
                                var alpha: CGFloat = 0
                                
                                uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                                
                                myAudio.rgbValuesHigh3 = [Int64(red * 255), Int64(green * 255), Int64(blue * 255)]
                            }
                    }
                    
                }
            }
        }
    }
}

