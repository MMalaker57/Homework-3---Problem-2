//
//  Neutron Scattering.swift
//  Homework 3 -  Problem 2
//
//  Created by Matthew Malaker on 2/7/22.
//

import Foundation

class Neutron_Scattering: NSObject, ObservableObject{
func createScatter(xPointInitial: Double, yPointInitial: Double, energyInitial: Double, meanFreePath: Double, energyToLose: Double)->(xPointFinal: Double, yPointFinal: Double,energyFinal: Double){
    
    if(energyInitial < energyToLose){
        return (xPointInitial, yPointInitial, 0)
    }
    else{
        let scatteringAngle = Double.random(in: 0...(2*Double.pi))
        let newXPoint = xPointInitial + meanFreePath*cos(scatteringAngle)
        let newYPoint = yPointInitial + meanFreePath*sin(scatteringAngle)
        let newEnergy = energyInitial-energyToLose


        return (newXPoint, newYPoint, newEnergy)
    }
}
    
    func inWall(xPoint: Double, yPoint: Double, lowerX: Double, upperX: Double, lowerY: Double, upperY: Double) -> Bool{
        if(xPoint > lowerX && xPoint < upperX && yPoint > lowerY && yPoint < upperY){
            return true
        }
        else{
            return false
        }
    }
    
    func createFullPath(initialXPoint: Double, initialYPoint: Double, initialEnergy: Double, meanFreePath: Double, lossFactor: Double, lowerXBound: Double, upperXBound: Double, lowerYBound: Double, upperYBound: Double)->[(xPoint: Double, yPoint: Double, energy: Double)]{
        //Setting a stupid value that will cause obvious behavior if used
        
        //We cannot know if the user passes a value for the loss factor that is between zero and one. We will correct any bad values of the loss factor.
        var lossFactorAdjusted = 9999999.0
        if(lossFactor > 1.0 ){
            lossFactorAdjusted = 1.0
        }
        if(lossFactor < 0.0){
            lossFactorAdjusted = 0.0
        }
        
        if(lossFactor < 1.0 && lossFactor > 0.0){
            lossFactorAdjusted = lossFactor
        }
        
        var currentX = initialXPoint
        var currentY = initialYPoint
        var currentEnergy = initialEnergy
        var isInWall = inWall(xPoint: currentX, yPoint: currentY, lowerX: lowerXBound, upperX: upperXBound, lowerY: lowerYBound, upperY: upperYBound)
        var energyLoss = initialEnergy * lossFactorAdjusted
        
        var path: [(xPoint: Double, yPoint: Double, energy: Double)]
        path.append((xPoint: currentX, yPoint: currentY, energy: currentEnergy))
        
        
        //We need to make sure that the first hit is in the box
        if(initialXPoint > lowerXBound && initialXPoint < upperXBound && initialYPoint > lowerYBound && initialYPoint < upperYBound){
            while isInWall{
                
                //Add current point to path array, then check if it will absorb or scatter
                //Check if absorbed
                if(currentEnergy <= energyLoss){
                    path[path.count-1].energy = 0
                    break
                }
                
                //If not absorbed, then calculate new point scattered to
                if (currentEnergy > energyLoss){
                    let newScatterPoint = createScatter(xPointInitial: currentX, yPointInitial: currentY, energyInitial: currentEnergy, meanFreePath: meanFreePath, energyToLose: energyLoss)
                    
                    
                    currentX = newScatterPoint.xPointFinal
                    currentY = newScatterPoint.yPointFinal
                    currentEnergy = newScatterPoint.energyFinal
                    path.append((xPoint: currentX, yPoint: currentY, energy: currentEnergy))
                    
                    //Check if new point is in wall. If not, the loop will simply stop
                    isInWall = inWall(xPoint: currentX, yPoint: currentY, lowerX: lowerXBound, upperX: upperXBound, lowerY: lowerYBound, upperY: upperYBound)
                }
            }
        }
        
    }
    
    
}
