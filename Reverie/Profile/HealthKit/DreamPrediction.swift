//
//  DreamPrediction.swift
//  Reverie
//
//  Created by Shreeya Garg on 11/16/25.
//

import SwiftUI
import Foundation


struct DreamPrediction {
    let startTime: Date
    let endTime: Date
    let confidence: Double // 0.0 to 1.0
    let reasoning: String
    let wasLogged: Bool
}

class Predictor {
    func predictDreamTimes(
        sleepSegments: [HealthKitManager.SleepSegment],
        heartRateData: [HealthKitManager.DataPoint],
        completion: @escaping ([DreamPrediction]) -> Void
    ) {
        print("predict dream times function called")
        var predictions: [DreamPrediction] = []
        
        // 1. Find all REM periods (dreams most likely occur during REM)
        let remSegments = sleepSegments.filter { $0.stage == "REM" }
        
        for remSegment in remSegments {
            // Get heart rate during this REM period
            let hrDuringREM = heartRateData.filter { point in
                point.date >= remSegment.start && point.date <= remSegment.end
            }
            
            // Calculate HR variability during this REM period
            let hrVariability = calculateVariability(hrDuringREM)
            
            // REM duration factor (longer REM = higher dream probability)
            let durationMinutes = remSegment.hours * 60
            let durationFactor = min(durationMinutes / 20.0, 1.0) // Peak at 20+ minutes
            
            // HR variability factor (more variable = more likely vivid dream)
            let variabilityFactor = min(hrVariability / 10.0, 1.0) // Normalize to 0-1
            
            // Time of night factor (later REM = longer, more vivid dreams)
            let hoursSinceStart = remSegment.start.timeIntervalSince(sleepSegments.first?.start ?? remSegment.start) / 3600.0
            let timeOfNightFactor = min(hoursSinceStart / 6.0, 1.0) // Peak after 6 hours
            
            // Combined confidence score
            let confidence = (durationFactor * 0.4 + variabilityFactor * 0.3 + timeOfNightFactor * 0.3)
            
            // Only include predictions with reasonable confidence
            if confidence > 0.3 {
                let reasoning = buildReasoning(
                    duration: durationMinutes,
                    variability: hrVariability,
                    timeOfNight: hoursSinceStart
                )
                
                predictions.append(DreamPrediction(
                    startTime: remSegment.start,
                    endTime: remSegment.end,
                    confidence: confidence,
                    reasoning: reasoning,
                    wasLogged: false // Will be updated if user logged a dream
                ))
            }
        }
        
        // 2. Look for "micro-arousals" - brief awakenings that might indicate dream recall
        let awakeSegments = sleepSegments.filter { $0.stage == "Awake" }
        
        for awakeSegment in awakeSegments {
            // Only consider brief awakenings (30 seconds to 5 minutes)
            let durationMinutes = awakeSegment.hours * 60
            guard durationMinutes > 0.5 && durationMinutes < 5 else { continue }
            
            // Check if there was REM immediately before this awakening
            if let previousSegment = sleepSegments.first(where: {
                $0.end.timeIntervalSince(awakeSegment.start) < 60 && $0.stage == "REM"
            }) {
                // High probability of dream recall if awakening from REM
                predictions.append(DreamPrediction(
                    startTime: previousSegment.start,
                    endTime: awakeSegment.start,
                    confidence: 0.75,
                    reasoning: "Brief awakening from REM sleep suggests potential dream recall moment",
                    wasLogged: false
                ))
            }
        }
        
        // 3. Sort by time and merge overlapping predictions
        predictions.sort { $0.startTime < $1.startTime }
        predictions = mergeOverlappingPredictions(predictions)
        
        print("predictions:")
        print(predictions)
        DispatchQueue.main.async {
            completion(predictions)
        }
    }
    
    // Helper function to calculate heart rate variability
    private func calculateVariability(_ points: [HealthKitManager.DataPoint]) -> Double {
        guard points.count > 1 else { return 0 }
        
        let values = points.map { $0.value }
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        return sqrt(variance) // Standard deviation
    }
    
    // Helper to build human-readable reasoning
    private func buildReasoning(duration: Double, variability: Double, timeOfNight: Double) -> String {
        var reasons: [String] = []
        
        if duration >= 15 {
            reasons.append("Extended REM period (\(Int(duration)) min)")
        }
        if variability > 8 {
            reasons.append("Elevated heart rate variability")
        }
        if timeOfNight > 4 {
            reasons.append("Occurred in later sleep cycles")
        }
        
        if reasons.isEmpty {
            return "REM sleep period with dream potential"
        } else {
            return reasons.joined(separator: " • ")
        }
    }
    
    // Merge overlapping or very close predictions
    private func mergeOverlappingPredictions(_ predictions: [DreamPrediction]) -> [DreamPrediction] {
        guard predictions.count > 1 else { return predictions }
        
        var merged: [DreamPrediction] = []
        var current = predictions[0]
        
        for i in 1..<predictions.count {
            let next = predictions[i]
            
            // If predictions overlap or are within 5 minutes, merge them
            if next.startTime.timeIntervalSince(current.endTime) < 300 {
                // Take the higher confidence and combine reasoning
                current = DreamPrediction(
                    startTime: current.startTime,
                    endTime: next.endTime,
                    confidence: max(current.confidence, next.confidence),
                    reasoning: current.reasoning,
                    wasLogged: current.wasLogged || next.wasLogged
                )
            } else {
                merged.append(current)
                current = next
            }
        }
        merged.append(current)
        
        return merged
    }
}
