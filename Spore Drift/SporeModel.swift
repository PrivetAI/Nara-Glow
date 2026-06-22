import Foundation
import SwiftUI

// MARK: - Static definitions

struct StrainKind: Identifiable {
    let id: Int
    let name: String
    let blurb: String
    let baseCost: Double
    let baseRate: Double   // spores/sec per unit at multiplier 1.0
}

struct EnzymeKind: Identifiable {
    enum Effect {
        case globalYield(Double)        // additive to the global bonus (e.g. 0.25 = +25%)
        case strainYield(strain: Int, mult: Double)
        case tapPower(Double)
    }
    let id: Int
    let name: String
    let blurb: String
    let cost: Double
    let effect: Effect
}

enum SporeDefs {
    // Seven strains; ~×13 cost, ~×5.4 rate per tier. The 1.15 per-owned growth keeps the
    // total production a smooth, bounded curve (no tier-surge snowball).
    static let strains: [StrainKind] = [
        StrainKind(id: 0, name: "Pin Mold",     blurb: "The first white threads in the damp.",        baseCost: 15,         baseRate: 0.2),
        StrainKind(id: 1, name: "Cup Fungus",   blurb: "Tiny goblets cradling the dew.",              baseCost: 200,        baseRate: 1.1),
        StrainKind(id: 2, name: "Bracket Shelf",blurb: "Hard shelves climbing the dead bark.",        baseCost: 2_600,      baseRate: 5.5),
        StrainKind(id: 3, name: "Glowcap",      blurb: "A lantern that grew where the light died.",   baseCost: 33_000,     baseRate: 28),
        StrainKind(id: 4, name: "Veil Mycena",  blurb: "Pale bells veiled in cold fire.",             baseCost: 440_000,    baseRate: 150),
        StrainKind(id: 5, name: "Witch's Web",  blurb: "A luminous net strung through the rot.",      baseCost: 5_800_000,  baseRate: 820),
        StrainKind(id: 6, name: "Titan Bloom",  blurb: "A cathedral of gills, breathing spores.",     baseCost: 78_000_000, baseRate: 4_500),
    ]

    // Enzymes: global bonuses are ADDITIVE; per-strain ×3 are one-time and bounded by tiers.
    static let enzymes: [EnzymeKind] = [
        EnzymeKind(id: 0, name: "Humic Acids",    blurb: "Richer rot. +25% to all spores.",       cost: 1_000,       effect: .globalYield(0.25)),
        EnzymeKind(id: 1, name: "Spore Print",    blurb: "Pin Mold spreads thrice as fast.",      cost: 1_400,       effect: .strainYield(strain: 0, mult: 3.0)),
        EnzymeKind(id: 2, name: "Luminous Touch", blurb: "Your touch wakes the glow. Tap ×3.",     cost: 9_000,       effect: .tapPower(3.0)),
        EnzymeKind(id: 3, name: "Chitin Weave",   blurb: "Tougher hyphae. +35% to all spores.",    cost: 22_000,      effect: .globalYield(0.35)),
        EnzymeKind(id: 4, name: "Gilled Bloom",   blurb: "Glowcaps yield thrice over.",           cost: 90_000,      effect: .strainYield(strain: 3, mult: 3.0)),
        EnzymeKind(id: 5, name: "Mycorrhizae",    blurb: "Roots trade in secret. +50% spores.",    cost: 260_000,     effect: .globalYield(0.50)),
        EnzymeKind(id: 6, name: "Veil Lace",      blurb: "Veil Mycena yield thrice over.",        cost: 1_600_000,   effect: .strainYield(strain: 4, mult: 3.0)),
        EnzymeKind(id: 7, name: "Lignin Burst",   blurb: "Wood unlocks its store. +75% spores.",   cost: 3_400_000,   effect: .globalYield(0.75)),
        EnzymeKind(id: 8, name: "Radiant Touch",  blurb: "A brighter hand. Tap ×4.",              cost: 14_000_000,  effect: .tapPower(4.0)),
        EnzymeKind(id: 9, name: "Hyphal Net",     blurb: "One mind in the soil. +100% spores.",    cost: 48_000_000,  effect: .globalYield(1.0)),
    ]

    static let tapBase: Double = 1.0
    static let prestigeThreshold: Double = 1_000_000     // lifetime spores to unlock Drift
    static let humusPerDrift: Double = 0.04              // +4% permanent per Humus (additive)
    static let offlineCapSeconds: Double = 8 * 3600
    static let richnessFloorMult: Double = 0.4          // production never drops below 40%
}

// MARK: - Save

struct SporeSave: Codable {
    var spores: Double = 0
    var totalEarned: Double = 0
    var strainCounts: [Int] = [0,0,0,0,0,0,0]
    var purchasedEnzymes: [Int] = []
    var humus: Double = 0
    var drifts: Int = 0
    var richness: Double = 1.0
    var everUnlocked: [Int] = []
    var lastActive: TimeInterval = 0
    var tapCount: Int = 0
}

// MARK: - Game

final class SporeGame: ObservableObject {
    @Published var spores: Double = 0
    @Published var totalEarned: Double = 0
    @Published var strainCounts: [Int] = [0,0,0,0,0,0,0]
    @Published var purchasedEnzymes: Set<Int> = []
    @Published var humus: Double = 0
    @Published var drifts: Int = 0
    @Published var richness: Double = 1.0
    @Published var everUnlocked: Set<Int> = []
    @Published var tapCount: Int = 0

    @Published var offlineSummary: OfflineSummary? = nil

    private var lastActive: TimeInterval = Date().timeIntervalSince1970
    private var lastTick: TimeInterval = Date().timeIntervalSince1970
    private var lastSave: TimeInterval = 0
    private var timer: Timer?

    struct OfflineSummary: Identifiable {
        let id = UUID()
        let earned: Double
        let seconds: Double
        let capped: Bool
    }

    private let saveURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("sporedrift_save.json")
    }()

    init() {
        load()
        lastTick = Date().timeIntervalSince1970
        syncUnlocked()
    }

    // MARK: Derived

    var globalBonus: Double {
        var b = 0.0
        for e in SporeDefs.enzymes where purchasedEnzymes.contains(e.id) {
            if case let .globalYield(v) = e.effect { b += v }
        }
        return b
    }

    func strainMultiplier(_ strain: Int) -> Double {
        var m = 1.0
        for e in SporeDefs.enzymes where purchasedEnzymes.contains(e.id) {
            if case let .strainYield(s, v) = e.effect, s == strain { m *= v }
        }
        return m
    }

    var tapMultiplier: Double {
        var m = 1.0
        for e in SporeDefs.enzymes where purchasedEnzymes.contains(e.id) {
            if case let .tapPower(v) = e.effect { m *= v }
        }
        return m
    }

    var humusMultiplier: Double { 1.0 + humus * SporeDefs.humusPerDrift }

    // Production multiplier from substrate richness — tapers but never zeroes.
    var richnessMultiplier: Double {
        return SporeDefs.richnessFloorMult + (1.0 - SporeDefs.richnessFloorMult) * max(0, min(1, richness))
    }

    var globalMultiplier: Double { (1.0 + globalBonus) * humusMultiplier }

    // Base rate ignoring richness (used for shop "+x/s each" display).
    var baseSporesPerSecond: Double {
        var rate = 0.0
        for s in SporeDefs.strains {
            let n = strainCounts[s.id]
            if n == 0 { continue }
            rate += Double(n) * s.baseRate * strainMultiplier(s.id)
        }
        return rate * globalMultiplier
    }

    var sporesPerSecond: Double { baseSporesPerSecond * richnessMultiplier }

    func perStrainRate(_ s: StrainKind) -> Double {
        s.baseRate * strainMultiplier(s.id) * globalMultiplier
    }

    var tapReward: Double { (SporeDefs.tapBase + sporesPerSecond * 0.05) * tapMultiplier }

    func strainCost(_ s: StrainKind) -> Double {
        (s.baseCost * pow(1.15, Double(strainCounts[s.id]))).rounded()
    }
    func canBuyStrain(_ s: StrainKind) -> Bool { spores >= strainCost(s) }
    func canBuyEnzyme(_ e: EnzymeKind) -> Bool { !purchasedEnzymes.contains(e.id) && spores >= e.cost }

    func strainVisible(_ s: StrainKind) -> Bool {
        s.id == 0 || strainCounts[max(0, s.id - 1)] > 0 || strainCounts[s.id] > 0
    }

    var totalStrains: Int { strainCounts.reduce(0, +) }
    var prestigeUnlocked: Bool { totalEarned >= SporeDefs.prestigeThreshold }
    func pendingHumus() -> Double {
        guard totalEarned >= SporeDefs.prestigeThreshold else { return 0 }
        return floor(sqrt(totalEarned / SporeDefs.prestigeThreshold) * 2.0)
    }
    var canDrift: Bool { pendingHumus() > humus }

    // MARK: Actions

    func buyStrain(_ s: StrainKind) {
        let cost = strainCost(s)
        guard spores >= cost else { return }
        spores -= cost
        strainCounts[s.id] += 1
        everUnlocked.insert(s.id)
        throttledSave()
    }

    func buyEnzyme(_ e: EnzymeKind) {
        guard canBuyEnzyme(e) else { return }
        spores -= e.cost
        purchasedEnzymes.insert(e.id)
        throttledSave()
    }

    func tap() {
        let r = tapReward
        spores += r
        totalEarned += r
        tapCount += 1
    }

    func drift() {
        guard canDrift else { return }
        let newHumus = pendingHumus()
        humus = newHumus
        drifts += 1
        spores = 0
        totalEarned = 0
        strainCounts = [0,0,0,0,0,0,0]
        purchasedEnzymes = []
        richness = 1.0
        // keep: humus, drifts, everUnlocked
        save()
    }

    func resetAll() {
        spores = 0; totalEarned = 0
        strainCounts = [0,0,0,0,0,0,0]
        purchasedEnzymes = []
        humus = 0; drifts = 0; richness = 1.0
        everUnlocked = []
        tapCount = 0
        offlineSummary = nil
        save()
    }

    private func syncUnlocked() {
        for i in 0..<strainCounts.count where strainCounts[i] > 0 { everUnlocked.insert(i) }
    }

    // MARK: Tick

    func startTicking() {
        timer?.invalidate()
        let t = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }
    func stopTicking() { timer?.invalidate(); timer = nil }

    private func tick() {
        let now = Date().timeIntervalSince1970
        let dt = max(0, now - lastTick)
        lastTick = now
        guard dt > 0 else { return }
        let gain = sporesPerSecond * dt
        if gain > 0 {
            spores += gain
            totalEarned += gain
            // Substrate richness drains gently with production (richer strains drain faster).
            let drain = (baseSporesPerSecond / max(1, SporeDefs.prestigeThreshold)) * dt * 0.015
            richness = max(0, richness - drain)
        }
        if now - lastSave > 15 { save() }
    }

    // MARK: Scene phase

    func handleBackground() {
        // Pitfall: stamp lastActive ONLY on .background (never .inactive).
        lastActive = Date().timeIntervalSince1970
        save()
    }

    func handleForeground() {
        creditOffline()
        lastTick = Date().timeIntervalSince1970
        save()
    }

    private func creditOffline() {
        let now = Date().timeIntervalSince1970
        guard lastActive > 0 else { lastActive = now; return }
        let elapsed = now - lastActive
        guard elapsed > 5 else { return }
        let capped = elapsed > SporeDefs.offlineCapSeconds
        let used = min(elapsed, SporeDefs.offlineCapSeconds)
        let earned = sporesPerSecond * used
        if earned > 0 {
            spores += earned
            totalEarned += earned
            offlineSummary = OfflineSummary(earned: earned, seconds: used, capped: capped)
        }
        lastActive = now
    }

    // MARK: Persistence

    private func throttledSave() {
        let now = Date().timeIntervalSince1970
        if now - lastSave > 2 { save() }
    }

    func save() {
        lastSave = Date().timeIntervalSince1970
        var s = SporeSave()
        s.spores = spores; s.totalEarned = totalEarned
        s.strainCounts = strainCounts
        s.purchasedEnzymes = Array(purchasedEnzymes)
        s.humus = humus; s.drifts = drifts; s.richness = richness
        s.everUnlocked = Array(everUnlocked)
        s.lastActive = lastActive; s.tapCount = tapCount
        if let data = try? JSONEncoder().encode(s) {
            try? data.write(to: saveURL, options: .atomic)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let s = try? JSONDecoder().decode(SporeSave.self, from: data) else {
            lastActive = Date().timeIntervalSince1970
            return
        }
        spores = s.spores; totalEarned = s.totalEarned
        var counts = s.strainCounts
        while counts.count < SporeDefs.strains.count { counts.append(0) }
        if counts.count > SporeDefs.strains.count { counts = Array(counts.prefix(SporeDefs.strains.count)) }
        strainCounts = counts
        purchasedEnzymes = Set(s.purchasedEnzymes)
        humus = s.humus; drifts = s.drifts
        richness = s.richness > 0 ? min(1, s.richness) : 1.0
        everUnlocked = Set(s.everUnlocked.filter { $0 >= 0 && $0 < SporeDefs.strains.count })
        tapCount = s.tapCount
        lastActive = s.lastActive > 0 ? s.lastActive : Date().timeIntervalSince1970
    }
}
