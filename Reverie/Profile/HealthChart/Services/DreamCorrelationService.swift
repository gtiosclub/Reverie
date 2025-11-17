import Foundation

struct DreamCorrelationInsight {
    let metric: HealthMetric
    let optimalValue: String
    
    var message: String {
        switch metric {
        case .sleep:
            return "You're most likely to dream when you get \(optimalValue) of sleep"
        case .exercise:
            return "You're most likely to dream when you exercise for \(optimalValue)"
        case .steps:
            return "You're most likely to dream when you take \(optimalValue)"
        case .calories:
            return "You're most likely to dream when you burn \(optimalValue)"
        }
    }
}

class DreamCorrelationService {
    static let shared = DreamCorrelationService()
    
    /// Finds optimal values for ALL health metrics
    func findAllOptimalValues(
        dreams: [DreamFrequencyChartModel],
        healthData: [DailyHealthData]
    ) -> [HealthMetric: DreamCorrelationInsight] {
        
        print("find optimal vals called")
        // Convert to aligned weekly data
        let alignedData = alignDreamsWithHealth(dreams: dreams, healthData: healthData)
        
        guard !alignedData.isEmpty else { return [:] }
        
        // Calculate optimal ranges for each metric
        let sleepInsight = calculateOptimalRange(
            metric: .sleep,
            data: alignedData,
            formatValue: { String(format: "%.1f hours", $0) }
        )
        
        let exerciseInsight = calculateOptimalRange(
            metric: .exercise,
            data: alignedData,
            formatValue: { String(format: "%.0f minutes", $0) }
        )
        
        let stepsInsight = calculateOptimalRange(
            metric: .steps,
            data: alignedData,
            formatValue: { String(format: "%.0f steps", $0) }
        )
        
        let caloriesInsight = calculateOptimalRange(
            metric: .calories,
            data: alignedData,
            formatValue: { String(format: "%.0f calories", $0) }
        )
        
        return [
            .sleep: sleepInsight,
            .exercise: exerciseInsight,
            .steps: stepsInsight,
            .calories: caloriesInsight
        ]
    }
    
    private func alignDreamsWithHealth(
        dreams: [DreamFrequencyChartModel],
        healthData: [DailyHealthData]
    ) -> [(dreamCount: Int, sleepDuration: Double, exerciseMinutes: Double, steps: Int, caloriesBurned: Double)] {
        
        let calendar = Calendar.current
        
        // Create a lookup for dreams by week
        let dreamsByWeek = Dictionary(grouping: dreams) { dream in
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dream.date))!
        }
        
        // Align with health data
        return healthData.compactMap { health in
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: health.date))!
            
            guard let dreamData = dreamsByWeek[weekStart]?.first else {
                return nil
            }
            
            return (
                dreamCount: dreamData.count,
                sleepDuration: health.sleepDuration,
                exerciseMinutes: health.exerciseMinutes,
                steps: health.steps,
                caloriesBurned: health.caloriesBurned
            )
        }
    }
    
    private func calculateOptimalRange(
        metric: HealthMetric,
        data: [(dreamCount: Int, sleepDuration: Double, exerciseMinutes: Double, steps: Int, caloriesBurned: Double)],
        formatValue: (Double) -> String
    ) -> DreamCorrelationInsight {
        
        // Extract metric values and dream counts
        var metricValues: [Double] = []
        var dreamCounts: [Int] = []
        
        for entry in data {
            let value: Double
            switch metric {
            case .sleep:
                value = entry.sleepDuration / 3600.0 // Convert to hours
            case .exercise:
                value = entry.exerciseMinutes
            case .steps:
                value = Double(entry.steps)
            case .calories:
                value = entry.caloriesBurned
            }
            
            metricValues.append(value)
            dreamCounts.append(entry.dreamCount)
        }
        
        guard metricValues.count > 2 else {
            return DreamCorrelationInsight(metric: metric, optimalValue: "N/A")
        }
        
        // Find the value range with highest average dream count
        let sortedPairs = zip(metricValues, dreamCounts).sorted { $0.0 < $1.0 }
        
        // Group into tertiles (low, medium, high)
        let tertileSize = max(1, sortedPairs.count / 3)
        let lowTertile = Array(sortedPairs.prefix(tertileSize))
        let midTertile = Array(sortedPairs.dropFirst(tertileSize).prefix(tertileSize))
        let highTertile = Array(sortedPairs.suffix(from: min(sortedPairs.count, tertileSize * 2)))
        
        let avgDreamsLow = lowTertile.isEmpty ? 0 : lowTertile.map { Double($0.1) }.reduce(0, +) / Double(lowTertile.count)
        let avgDreamsMid = midTertile.isEmpty ? 0 : midTertile.map { Double($0.1) }.reduce(0, +) / Double(midTertile.count)
        let avgDreamsHigh = highTertile.isEmpty ? 0 : highTertile.map { Double($0.1) }.reduce(0, +) / Double(highTertile.count)
        
        // Find which tertile has highest dream frequency
        let maxAvg = max(avgDreamsLow, avgDreamsMid, avgDreamsHigh)
        let optimalTertile: [(Double, Int)]
        
        if maxAvg == avgDreamsLow && !lowTertile.isEmpty {
            optimalTertile = lowTertile
        } else if maxAvg == avgDreamsMid && !midTertile.isEmpty {
            optimalTertile = midTertile
        } else {
            optimalTertile = highTertile
        }
        
        // Calculate the average value in the optimal range
        let optimalValue = optimalTertile.isEmpty ? 0 : optimalTertile.map { $0.0 }.reduce(0, +) / Double(optimalTertile.count)
        
        return DreamCorrelationInsight(
            metric: metric,
            optimalValue: formatValue(optimalValue)
        )
    }
}
