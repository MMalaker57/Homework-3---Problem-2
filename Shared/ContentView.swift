//
//  ContentView.swift
//  Shared
//
//  Created by Matthew Malaker on 2/7/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var lowerXBoundString = ""
    @State var upperXBoundString = ""
    @State var lowerYBoundString = ""
    @State var upperYBoundString = ""
    @State var lowerXBound = 0.0
    @State var upperXBound = 0.0
    @State var lowerYBound = 0.0
    @State var upperYBound = 0.0
    
    @State var beamXPositionString = ""
    @State var beamYPositionString = ""
    @State var beamXPosition = 0.0
    @State var beamYPosition = 0.0
    
    @State var beamEnergyString = ""
    @State var beamEnergy = 0.0
    @State var beamLossFactorString = ""
    @State var beamLossFactor = 0.0
    @State var MFPString = ""
    @State var MFP = 1.0
    @State var numPathsString = ""
    @State var numPaths = 1
    @State var pathsStructure: (pathList: [[(xPoint: Double, yPoint: Double, energy: Double)]], escapedRatio: Double)
    @State var drawnPath = [(xPoint: Double, yPoint: Double, energy: Double)]()
    
    @ObservedObject var neutron_beam = Neutron_Scattering()
    
    //IMPORTANT THINGS
    //This app needs to take the lower and upper bounds for x and y, the starting coordinates for the beam, the starting energy of the beam, and the loss factor.
    // The loss factor is simply the proportion of th initial energy that will be lost every iteration
    var body: some View {
       
        VStack{
            //Stack for x bounds
            HStack{
                
                    Text("Enter Upper X Bound")
                    TextField("",text: $upperXBoundString, onCommit: {upperXBound = Double(upperXBoundString) ?? 0})
                        .padding(.horizontal)
                        .frame(width: 150)
                        .padding(.top, 30)
                        .padding(.bottom)
                    
                
                    Text("Enter Upper Y Bound")
                    TextField("",text: $upperYBoundString, onCommit: {upperYBound = Double(upperYBoundString) ?? 0})
                        .padding(.horizontal)
                        .frame(width: 150)
                        .padding(.top, 30)
                        .padding(.bottom)
                    
                
            }
            
            HStack{
                VStack{
                Text("Enter Beam X Position")
                TextField("",text: $beamXPositionString, onCommit: {beamXPosition = Double(beamXPositionString) ?? 0})
                    .padding(.horizontal)
                    .frame(width: 150)
                    .padding(.top, 30)
                    .padding(.bottom)
                }
                
                VStack{
                    Text("Enter Beam Y Position")
                    TextField("",text: $beamYPositionString, onCommit: {beamYPosition = Double(beamYPositionString) ?? 0})
                        .padding(.horizontal)
                        .frame(width: 150)
                        .padding(.top, 30)
                        .padding(.bottom)
                    
                }
            }
            HStack{
                VStack{
                Text("Enter Beam Energy")
                TextField("",text: $beamEnergyString, onCommit: {beamEnergy = Double(beamEnergyString) ?? 0})
                    .padding(.horizontal)
                    .frame(width: 150)
                    .padding(.top, 30)
                    .padding(.bottom)
                }
                
                VStack{
                    Text("Enter Energy Loss Factor")
                    TextField("",text: $beamLossFactorString, onCommit: {beamLossFactor = Double(beamLossFactorString) ?? 0})
                        .padding(.horizontal)
                        .frame(width: 150)
                        .padding(.top, 30)
                        .padding(.bottom)
                    
                }
                VStack{
                Text("Enter Mean Free Path")
                TextField("",text: $MFPString, onCommit: {MFP = Double(MFPString) ?? 0})
                    .padding(.horizontal)
                    .frame(width: 150)
                    .padding(.top, 30)
                    .padding(.bottom)
                }
            }
            
            HStack{
                
                VStack{
                    Text("Enter Number of Paths")
                    TextField("",text: $numPathsString, onCommit: {numPaths = Int(numPathsString) ?? 1})
                        .padding(.horizontal)
                        .frame(width: 150)
                        .padding(.top, 30)
                        .padding(.bottom)
                }
                
                
            }
            Button("Calculate", action: {Task.init{await pathsStructure = calculateMassOfPaths(passedNumberofPaths: numPaths)}})
                .padding()
//            Button("Draw", action: )
        }
        Divider()
//        drawingView(redLayer:)
//                .padding()
//                .aspectRatio(1, contentMode: .fit)
//                .drawingGroup()
            // Stop the window shrinking to zero.
            Spacer()
        
    }
    
    //Below is where all the plotting stuff and path generation
    
    //Create a ton of paths and see if they end in an escape or absorb
    
    //By a ton, I really mean a lot. Like 10^6
    func calculateMassOfPaths(passedNumberofPaths: Int) async-> (pathList: [[(xPoint: Double, yPoint: Double, energy: Double)]], escapedRatio: Double){
        var numberOfPaths = abs(passedNumberofPaths) //Never trust the user to return only positive numbers
        if numberOfPaths < 1{
            numberOfPaths = 1
        }
        
        
        let listOfPaths = await withTaskGroup(of: [(xPoint: Double, yPoint: Double, energy: Double)].self, returning: [[(xPoint: Double, yPoint: Double, energy: Double)]].self, body: {taskGroup in
            //var PathList: [[(xPoint: Double, yPoint: Double, energy: Double)]]
            //Create each path up to the desired number
            for i in stride(from: 0, to: numberOfPaths, by: 1){
                taskGroup.addTask {
                    let path = await neutron_beam.createFullPath(initialXPoint: beamXPosition, initialYPoint: beamYPosition, initialEnergy: beamEnergy, meanFreePath: MFP, lossFactor: beamLossFactor, lowerXBound: lowerXBound, upperXBound: upperXBound, lowerYBound: lowerYBound, upperYBound: upperYBound)
                    return path
                }
                            
            }
            //In other cases, we would have to sort this data, but we are simply generating a large number of random paths. The index of each path is irrelevant
            var interimResults = [[(xPoint: Double, yPoint: Double, energy: Double)]]()
            for await result in taskGroup{
                interimResults.append(result)
            }
            return interimResults
        })
        //After we have all of the paths, we need to determine how many escaped.
        var escaped = 0
        drawnPath = listOfPaths.last ?? [(0.0,0.0,0.0)]
        for i in listOfPaths{
            if i.last?.energy ?? 0.0 > 0.0{
                escaped+=1
            }
        }
        
        return(pathList: listOfPaths, escapedRatio: Double(escaped)/Double(numberOfPaths))
    }
    
    func drawPath(path: [(xPoint: Double, yPoint: Double)]){
        
        var pathToDraw = [(xPoint: Double, yPoint: Double)]()
        for i in path{
            pathToDraw.append((i.xPoint,i.yPoint))
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(pathsStructure: (pathList: [[(xPoint: 0.0, yPoint: 0.0, energy: 0.0)]], escapedRatio: 1.0))
    }
}
