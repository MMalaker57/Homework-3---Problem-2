//
//  DrawingView.swift
//  Monte Carlo Integration
//
//  Created by Jeff Terry on 12/31/20.
//

import SwiftUI

struct drawingView: View {
    
    @Binding var redLayer : [(xPoint: Double, yPoint: Double)]
    @Binding var upperX: Double
    @Binding var upperY: Double
//    @Binding var blueLayer : [(xPoint: Double, yPoint: Double)]
    
    var body: some View {
    
        
        ZStack{
        
            drawIntegral(upperXBound: upperX, upperYBound: upperY, drawingPoints: redLayer)
                .stroke(Color.red, lineWidth: 1)
            
//            drawIntegral(drawingPoints: blueLayer )
//                .stroke(Color.blue)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fill)
        
    }
}

struct DrawingView_Previews: PreviewProvider {
    
    @State static var redLayer : [(xPoint: Double, yPoint: Double)] = [(-5.0, 5.0), (5.0, 5.0), (0.0, 0.0), (0.0, 5.0)]
    @State static var upperX: Double = 10.0
    @State static var upperY: Double = 10.0
    @State static var blueLayer : [(xPoint: Double, yPoint: Double)] = [(-5.0, -5.0), (5.0, -5.0), (4.5, 0.0)]
    
    static var previews: some View {
       
        
        drawingView(redLayer: $redLayer, upperX: $upperX, upperY: $upperY)
            .aspectRatio(1, contentMode: .fill)
            //.drawingGroup()
           
    }
}



struct drawIntegral: Shape {
    
    var upperXBound: Double
    var upperYBound: Double
    let smoothness : CGFloat = 1.0
    var drawingPoints: [(xPoint: Double, yPoint: Double)] = []///Array of tuples
    
    func path(in rect: CGRect) -> Path {
        
               
        // draw from the center of our rectangle
        var path = Path()
        if drawingPoints.isEmpty{
            return path
        }
        
//        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let hScale = rect.width/upperXBound
        let vScale = rect.height/upperYBound
        path.move(to: CGPoint(x: drawingPoints[0].xPoint*Double(hScale), y: drawingPoints[0].yPoint*Double(hScale)))

        // Create the Path for the display
        
        for item in drawingPoints {
            path.addLine(to: CGPoint(x: item.xPoint*Double(hScale), y: item.yPoint*Double(vScale)))
            path.addRect(CGRect(x: item.xPoint*Double(hScale), y: item.yPoint*Double(vScale), width: 2.0, height: 2.0 ))
        }
        
        return (path)
    }
}
