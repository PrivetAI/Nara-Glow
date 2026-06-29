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
        case pressureRate(Double)       // additive to the bloom pressure-fill multiplier
        case bloomBurst(Double)         // additive to the bloom burst multiplier
        case bloomDuration(Double)      // +seconds to the bloom buff window
    }
    let id: Int
    let name: String
    let blurb: String
    let cost: Double
    let effect: Effect
}

// Permanent prestige nodes bought with Humus. Bounded, repeatable tiers.
struct HumusPerk: Identifiable {
    enum Effect {
        case globalSpores(Double)       // +X global bonus per tier (additive)
        case pressureSpeed(Double)      // +X pressure-fill multiplier per tier (additive)
        case bloomBurst(Double)         // +X bloom burst multiplier per tier (additive)
        case bloomDuration(Double)      // +X seconds bloom window per tier
        case slowDrain(Double)          // reduce substrate drain by X per tier (additive, capped)
        case driftYield(Double)         // +X Humus per Drift per tier (flat)
        case tapBonus(Double)           // +X tap multiplier per tier (additive)
        case offlineCap(Double)         // +X hours offline cap per tier
    }
    let id: Int
    let name: String
    let blurb: String
    let maxTier: Int
    let baseCost: Double                // Humus cost of the first tier; +1 per owned tier
    let effect: Effect
}

struct Achievement: Identifiable {
    let id: Int
    let title: String
    let desc: String
    let test: (SporeGame) -> Bool
}

enum SporeDefs {
    // Ten strains; ~×13 cost, ~×5.4 rate per tier. The 1.15 per-owned growth keeps the
    // total production a smooth, bounded curve (no tier-surge snowball).
    static let strains: [StrainKind] = [
        StrainKind(id: 0, name: "Pin Mold",     blurb: "The first white threads in the damp.",        baseCost: 15,              baseRate: 0.2),
        StrainKind(id: 1, name: "Cup Fungus",   blurb: "Tiny goblets cradling the dew.",              baseCost: 200,             baseRate: 1.1),
        StrainKind(id: 2, name: "Bracket Shelf",blurb: "Hard shelves climbing the dead bark.",        baseCost: 2_600,           baseRate: 5.5),
        StrainKind(id: 3, name: "Glowcap",      blurb: "A lantern that grew where the light died.",   baseCost: 33_000,          baseRate: 28),
        StrainKind(id: 4, name: "Veil Mycena",  blurb: "Pale bells veiled in cold fire.",             baseCost: 440_000,         baseRate: 150),
        StrainKind(id: 5, name: "Witch's Web",  blurb: "A luminous net strung through the rot.",      baseCost: 5_800_000,       baseRate: 820),
        StrainKind(id: 6, name: "Titan Bloom",  blurb: "A cathedral of gills, breathing spores.",     baseCost: 78_000_000,      baseRate: 4_500),
        StrainKind(id: 7, name: "Wraith Gill",  blurb: "A curtain of light that forgets it is dead.", baseCost: 1_000_000_000,   baseRate: 24_000),
        StrainKind(id: 8, name: "Ember Polypore",blurb:"Banked coals smouldering under the ash.",     baseCost: 13_000_000_000,  baseRate: 130_000),
        StrainKind(id: 9, name: "Cosmic Bloom", blurb: "Spores that seed the dark between stars.",    baseCost: 170_000_000_000, baseRate: 700_000),
    ]

    // Enzymes: global bonuses are ADDITIVE; per-strain ×3 are one-time and bounded by tiers.
    // Bloom enzymes feed additively into bounded bloom multipliers.
    static let enzymes: [EnzymeKind] = [
        EnzymeKind(id: 0, name: "Humic Acids",    blurb: "Richer rot. +25% to all spores.",        cost: 1_000,            effect: .globalYield(0.25)),
        EnzymeKind(id: 1, name: "Spore Print",    blurb: "Pin Mold spreads thrice as fast.",       cost: 1_400,            effect: .strainYield(strain: 0, mult: 3.0)),
        EnzymeKind(id: 2, name: "Luminous Touch", blurb: "Your touch wakes the glow. Tap ×3.",      cost: 9_000,            effect: .tapPower(3.0)),
        EnzymeKind(id: 3, name: "Chitin Weave",   blurb: "Tougher hyphae. +35% to all spores.",     cost: 22_000,           effect: .globalYield(0.35)),
        EnzymeKind(id: 4, name: "Gilled Bloom",   blurb: "Glowcaps yield thrice over.",            cost: 90_000,           effect: .strainYield(strain: 3, mult: 3.0)),
        EnzymeKind(id: 5, name: "Mycorrhizae",    blurb: "Roots trade in secret. +50% spores.",     cost: 260_000,          effect: .globalYield(0.50)),
        EnzymeKind(id: 6, name: "Veil Lace",      blurb: "Veil Mycena yield thrice over.",         cost: 1_600_000,        effect: .strainYield(strain: 4, mult: 3.0)),
        EnzymeKind(id: 7, name: "Lignin Burst",   blurb: "Wood unlocks its store. +75% spores.",    cost: 3_400_000,        effect: .globalYield(0.75)),
        EnzymeKind(id: 8, name: "Radiant Touch",  blurb: "A brighter hand. Tap ×4.",               cost: 14_000_000,       effect: .tapPower(4.0)),
        EnzymeKind(id: 9, name: "Hyphal Net",     blurb: "One mind in the soil. +100% spores.",     cost: 48_000_000,       effect: .globalYield(1.0)),
        // Bloom-interacting + late-tier enzymes
        EnzymeKind(id: 10, name: "Spore Pump",    blurb: "Pressure builds 30% faster.",            cost: 6_000_000,        effect: .pressureRate(0.30)),
        EnzymeKind(id: 11, name: "Burst Sac",     blurb: "Bloom release yields +40%.",             cost: 30_000_000,       effect: .bloomBurst(0.40)),
        EnzymeKind(id: 12, name: "Slow Glow",     blurb: "Bloom buff lasts 8s longer.",            cost: 120_000_000,      effect: .bloomDuration(8.0)),
        EnzymeKind(id: 13, name: "Wraith Silk",   blurb: "Wraith Gill yields thrice over.",        cost: 5_000_000_000,    effect: .strainYield(strain: 7, mult: 3.0)),
        EnzymeKind(id: 14, name: "Wood Wide Web", blurb: "The forest pools its light. +125%.",      cost: 10_000_000_000,   effect: .globalYield(1.25)),
        EnzymeKind(id: 15, name: "Ember Heart",   blurb: "Ember Polypore yields thrice over.",     cost: 60_000_000_000,   effect: .strainYield(strain: 8, mult: 3.0)),
        EnzymeKind(id: 16, name: "Radiant Crown", blurb: "A blazing hand. Tap ×5.",                cost: 3_000_000_000,    effect: .tapPower(5.0)),
        EnzymeKind(id: 17, name: "Bloom Cascade", blurb: "Pressure builds 50% faster.",            cost: 80_000_000_000,   effect: .pressureRate(0.50)),
        EnzymeKind(id: 18, name: "Cosmic Root",   blurb: "Roots reach the void. +150% spores.",     cost: 200_000_000_000,  effect: .globalYield(1.50)),
    ]

    // Humus perks — permanent, survive Drift.
    static let perks: [HumusPerk] = [
        HumusPerk(id: 0, name: "Deep Roots",     blurb: "+10% global spores per tier.",          maxTier: 5, baseCost: 1, effect: .globalSpores(0.10)),
        HumusPerk(id: 1, name: "Quick Pressure", blurb: "Bloom pressure fills +12% faster.",     maxTier: 5, baseCost: 2, effect: .pressureSpeed(0.12)),
        HumusPerk(id: 2, name: "Rich Bloom",     blurb: "Bloom burst +15% per tier.",            maxTier: 5, baseCost: 2, effect: .bloomBurst(0.15)),
        HumusPerk(id: 3, name: "Lasting Bloom",  blurb: "Bloom buff +3s per tier.",              maxTier: 5, baseCost: 2, effect: .bloomDuration(3.0)),
        HumusPerk(id: 4, name: "Slow Drain",     blurb: "Substrate drains 15% slower per tier.", maxTier: 3, baseCost: 3, effect: .slowDrain(0.15)),
        HumusPerk(id: 5, name: "Generous Drift", blurb: "+1 Humus per Drift, per tier.",          maxTier: 5, baseCost: 3, effect: .driftYield(1.0)),
        HumusPerk(id: 6, name: "Tap Mastery",    blurb: "+25% tap reward per tier.",             maxTier: 5, baseCost: 1, effect: .tapBonus(0.25)),
        HumusPerk(id: 7, name: "Long Memory",    blurb: "+2h offline collection per tier.",      maxTier: 4, baseCost: 2, effect: .offlineCap(2.0)),
    ]

    static let achievements: [Achievement] = [
        Achievement(id: 0,  title: "First Threads",   desc: "Earn 1K lifetime spores.")        { $0.totalEarned >= 1_000 },
        Achievement(id: 1,  title: "Spreading",       desc: "Earn 100K lifetime spores.")      { $0.totalEarned >= 100_000 },
        Achievement(id: 2,  title: "Thriving Log",    desc: "Earn 10M lifetime spores.")       { $0.totalEarned >= 10_000_000 },
        Achievement(id: 3,  title: "Billion Spores",  desc: "Earn 1B lifetime spores.")        { $0.totalEarned >= 1_000_000_000 },
        Achievement(id: 4,  title: "Glow Empire",     desc: "Earn 100B lifetime spores.")      { $0.totalEarned >= 100_000_000_000 },
        Achievement(id: 5,  title: "Boundless",       desc: "Earn 10T lifetime spores.")       { $0.totalEarned >= 10_000_000_000_000 },
        Achievement(id: 6,  title: "Colony Start",    desc: "Own 10 strains.")                 { $0.totalStrains >= 10 },
        Achievement(id: 7,  title: "Dense Mat",       desc: "Own 50 strains.")                 { $0.totalStrains >= 50 },
        Achievement(id: 8,  title: "Overgrowth",      desc: "Own 150 strains.")                { $0.totalStrains >= 150 },
        Achievement(id: 9,  title: "Full Codex",      desc: "Discover all 10 strains.")        { $0.everUnlocked.count >= SporeDefs.strains.count },
        Achievement(id: 10, title: "First Drift",     desc: "Drift once.")                     { $0.drifts >= 1 },
        Achievement(id: 11, title: "Seasoned Drifter",desc: "Drift 5 times.")                  { $0.drifts >= 5 },
        Achievement(id: 12, title: "Eternal Cycle",   desc: "Drift 15 times.")                 { $0.drifts >= 15 },
        Achievement(id: 13, title: "First Bloom",     desc: "Release a Bloom.")                { $0.bloomsReleased >= 1 },
        Achievement(id: 14, title: "Bloom Tender",    desc: "Release 25 Blooms.")              { $0.bloomsReleased >= 25 },
        Achievement(id: 15, title: "Bloom Master",    desc: "Release 100 Blooms.")             { $0.bloomsReleased >= 100 },
        Achievement(id: 16, title: "Busy Hands",      desc: "Touch the log 1,000 times.")      { $0.tapCount >= 1_000 },
        Achievement(id: 17, title: "Humus Hoard",     desc: "Gather 100 lifetime Humus.")      { $0.humusLifetime >= 100 },
    ]

    static let tapBase: Double = 1.0
    static let prestigeThreshold: Double = 1_000_000     // lifetime spores to unlock Drift
    static let humusPerDrift: Double = 0.04              // +4% permanent per lifetime Humus (additive)
    static let offlineCapSeconds: Double = 8 * 3600
    static let richnessFloorMult: Double = 0.4          // production never drops below 40%

    // Bloom tuning — bounded, no snowball.
    static let bloomBuffMult: Double = 2.5               // production ×2.5 while blooming
    static let bloomDurationBase: Double = 22            // seconds
    static let bloomBurstSeconds: Double = 30            // burst = ~30s of production
    static let pressureBase: Double = 0.008             // per-second baseline fill (~125s alone)
    static let pressureProdMax: Double = 0.008          // extra fill that saturates with production
    static let pressureProdScale: Double = 50           // production half-saturation for fill
    static let pressureTapGain: Double = 0.012          // pressure added per tap
}

// MARK: - Save

struct SporeSave: Codable {
    var spores: Double = 0
    var totalEarned: Double = 0
    var strainCounts: [Int] = Array(repeating: 0, count: 10)
    var purchasedEnzymes: [Int] = []
    var humus: Double = 0
    var humusLifetime: Double = 0
    var drifts: Int = 0
    var richness: Double = 1.0
    var everUnlocked: [Int] = []
    var lastActive: TimeInterval = 0
    var tapCount: Int = 0
    var pressure: Double = 0
    var bloomEnd: TimeInterval = 0
    var bloomsReleased: Int = 0
    var humusPerkLevels: [Int] = Array(repeating: 0, count: 8)
    var achievementsUnlocked: [Int] = []

    init() {}

    // SAVE SAFETY: decode every property with decodeIfPresent ?? default so adding fields
    // never throws on an old save (which would make `try?` return nil and wipe progress).
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        spores              = try c.decodeIfPresent(Double.self, forKey: .spores) ?? 0
        totalEarned         = try c.decodeIfPresent(Double.self, forKey: .totalEarned) ?? 0
        strainCounts        = try c.decodeIfPresent([Int].self, forKey: .strainCounts) ?? Array(repeating: 0, count: 10)
        purchasedEnzymes    = try c.decodeIfPresent([Int].self, forKey: .purchasedEnzymes) ?? []
        humus               = try c.decodeIfPresent(Double.self, forKey: .humus) ?? 0
        humusLifetime       = try c.decodeIfPresent(Double.self, forKey: .humusLifetime) ?? 0
        drifts              = try c.decodeIfPresent(Int.self, forKey: .drifts) ?? 0
        richness            = try c.decodeIfPresent(Double.self, forKey: .richness) ?? 1.0
        everUnlocked        = try c.decodeIfPresent([Int].self, forKey: .everUnlocked) ?? []
        lastActive          = try c.decodeIfPresent(TimeInterval.self, forKey: .lastActive) ?? 0
        tapCount            = try c.decodeIfPresent(Int.self, forKey: .tapCount) ?? 0
        pressure            = try c.decodeIfPresent(Double.self, forKey: .pressure) ?? 0
        bloomEnd            = try c.decodeIfPresent(TimeInterval.self, forKey: .bloomEnd) ?? 0
        bloomsReleased      = try c.decodeIfPresent(Int.self, forKey: .bloomsReleased) ?? 0
        humusPerkLevels     = try c.decodeIfPresent([Int].self, forKey: .humusPerkLevels) ?? Array(repeating: 0, count: 8)
        achievementsUnlocked = try c.decodeIfPresent([Int].self, forKey: .achievementsUnlocked) ?? []
    }
}

// MARK: - Game

final class SporeGame: ObservableObject {
    @Published var spores: Double = 0
    @Published var totalEarned: Double = 0
    @Published var strainCounts: [Int] = Array(repeating: 0, count: 10)
    @Published var purchasedEnzymes: Set<Int> = []
    @Published var humus: Double = 0                 // spendable balance
    @Published var humusLifetime: Double = 0         // total ever gathered (drives the flat multiplier)
    @Published var drifts: Int = 0
    @Published var richness: Double = 1.0
    @Published var everUnlocked: Set<Int> = []
    @Published var tapCount: Int = 0
    @Published var pressure: Double = 0              // 0...1 spore pressure
    @Published var bloomEnd: TimeInterval = 0        // wall-clock end of the active bloom buff
    @Published var bloomsReleased: Int = 0
    @Published var humusPerkLevels: [Int] = Array(repeating: 0, count: 8)
    @Published var achievementsUnlocked: Set<Int> = []

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
        return dir.appendingPathComponent("spore_save.json")
    }()

    init() {
        load()
        lastTick = Date().timeIntervalSince1970
        syncUnlocked()
    }

    // MARK: Perk aggregates

    private func perkSum(_ pick: (HumusPerk.Effect) -> Double?) -> Double {
        var total = 0.0
        for p in SporeDefs.perks {
            let tier = perkTier(p.id)
            if tier == 0 { continue }
            if let v = pick(p.effect) { total += v * Double(tier) }
        }
        return total
    }

    func perkTier(_ id: Int) -> Int {
        guard id >= 0 && id < humusPerkLevels.count else { return 0 }
        return humusPerkLevels[id]
    }
    func perkCost(_ p: HumusPerk) -> Double { p.baseCost + Double(perkTier(p.id)) }
    func canBuyPerk(_ p: HumusPerk) -> Bool { perkTier(p.id) < p.maxTier && humus >= perkCost(p) }

    var perkGlobalSpores: Double  { perkSum { if case let .globalSpores(v) = $0 { return v }; return nil } }
    var perkPressureSpeed: Double { perkSum { if case let .pressureSpeed(v) = $0 { return v }; return nil } }
    var perkBloomBurst: Double    { perkSum { if case let .bloomBurst(v) = $0 { return v }; return nil } }
    var perkBloomDuration: Double { perkSum { if case let .bloomDuration(v) = $0 { return v }; return nil } }
    var perkDrainReduction: Double { min(0.8, perkSum { if case let .slowDrain(v) = $0 { return v }; return nil }) }
    var perkDriftYield: Double    { perkSum { if case let .driftYield(v) = $0 { return v }; return nil } }
    var perkTapBonus: Double      { perkSum { if case let .tapBonus(v) = $0 { return v }; return nil } }
    var perkOfflineHours: Double  { perkSum { if case let .offlineCap(v) = $0 { return v }; return nil } }

    // MARK: Enzyme aggregates

    var globalBonus: Double {
        var b = 0.0
        for e in SporeDefs.enzymes where purchasedEnzymes.contains(e.id) {
            if case let .globalYield(v) = e.effect { b += v }
        }
        return b + perkGlobalSpores
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
        return m * (1.0 + perkTapBonus)
    }

    private var enzymePressureRate: Double {
        var v = 0.0
        for e in SporeDefs.enzymes where purchasedEnzymes.contains(e.id) {
            if case let .pressureRate(x) = e.effect { v += x }
        }
        return v
    }
    private var enzymeBloomBurst: Double {
        var v = 0.0
        for e in SporeDefs.enzymes where purchasedEnzymes.contains(e.id) {
            if case let .bloomBurst(x) = e.effect { v += x }
        }
        return v
    }
    private var enzymeBloomDuration: Double {
        var v = 0.0
        for e in SporeDefs.enzymes where purchasedEnzymes.contains(e.id) {
            if case let .bloomDuration(x) = e.effect { v += x }
        }
        return v
    }

    // MARK: Derived

    var humusMultiplier: Double { 1.0 + humusLifetime * SporeDefs.humusPerDrift }

    // Production multiplier from substrate richness — tapers but never zeroes.
    var richnessMultiplier: Double {
        return SporeDefs.richnessFloorMult + (1.0 - SporeDefs.richnessFloorMult) * max(0, min(1, richness))
    }

    var globalMultiplier: Double { (1.0 + globalBonus) * humusMultiplier }

    // Base rate ignoring richness and bloom (used for shop "+x/s each" display).
    var baseSporesPerSecond: Double {
        var rate = 0.0
        for s in SporeDefs.strains {
            let n = strainCounts[s.id]
            if n == 0 { continue }
            rate += Double(n) * s.baseRate * strainMultiplier(s.id)
        }
        return rate * globalMultiplier
    }

    // Steady production (richness applied, no bloom) — drives burst & pressure.
    var steadyProduction: Double { baseSporesPerSecond * richnessMultiplier }

    var bloomActive: Bool { bloomEnd > Date().timeIntervalSince1970 }
    var bloomMultiplier: Double { bloomActive ? SporeDefs.bloomBuffMult : 1.0 }
    var bloomRemaining: Double { max(0, bloomEnd - Date().timeIntervalSince1970) }
    var pressureReady: Bool { pressure >= 1.0 }

    var sporesPerSecond: Double { steadyProduction * bloomMultiplier }

    func perStrainRate(_ s: StrainKind) -> Double {
        s.baseRate * strainMultiplier(s.id) * globalMultiplier
    }

    var tapReward: Double { (SporeDefs.tapBase + sporesPerSecond * 0.05) * tapMultiplier }

    // Bloom math
    var pressureMultiplier: Double { 1.0 + enzymePressureRate + perkPressureSpeed }
    var bloomBurstMultiplier: Double { 1.0 + enzymeBloomBurst + perkBloomBurst }
    var bloomBuffDuration: Double { SporeDefs.bloomDurationBase + enzymeBloomDuration + perkBloomDuration }
    func bloomBurstAmount() -> Double { max(10, steadyProduction * SporeDefs.bloomBurstSeconds * bloomBurstMultiplier) }

    var offlineCapSeconds: Double { SporeDefs.offlineCapSeconds + perkOfflineHours * 3600 }

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

    // Humus GAINED on the next drift (incremental).
    func humusGain() -> Double {
        guard totalEarned >= SporeDefs.prestigeThreshold else { return 0 }
        return floor(sqrt(totalEarned / SporeDefs.prestigeThreshold) * 2.0) + perkDriftYield
    }
    var canDrift: Bool { humusGain() >= 1 }

    // MARK: Actions

    func buyStrain(_ s: StrainKind) {
        let cost = strainCost(s)
        guard spores >= cost else { return }
        spores -= cost
        strainCounts[s.id] += 1
        everUnlocked.insert(s.id)
        checkAchievements()
        throttledSave()
    }

    func buyEnzyme(_ e: EnzymeKind) {
        guard canBuyEnzyme(e) else { return }
        spores -= e.cost
        purchasedEnzymes.insert(e.id)
        throttledSave()
    }

    func buyPerk(_ p: HumusPerk) {
        guard canBuyPerk(p) else { return }
        humus -= perkCost(p)
        humusPerkLevels[p.id] += 1
        save()
    }

    func tap() {
        let r = tapReward
        spores += r
        totalEarned += r
        tapCount += 1
        pressure = min(1.0, pressure + SporeDefs.pressureTapGain * pressureMultiplier)
        checkAchievements()
    }

    func releaseBloom() {
        guard pressureReady else { return }
        let burst = bloomBurstAmount()
        spores += burst
        totalEarned += burst
        pressure = 0
        bloomEnd = Date().timeIntervalSince1970 + bloomBuffDuration
        bloomsReleased += 1
        checkAchievements()
        save()
    }

    func drift() {
        guard canDrift else { return }
        let gain = humusGain()
        humus += gain
        humusLifetime += gain
        drifts += 1
        spores = 0
        totalEarned = 0
        strainCounts = Array(repeating: 0, count: SporeDefs.strains.count)
        purchasedEnzymes = []
        richness = 1.0
        pressure = 0
        bloomEnd = 0
        // keep: humus, humusLifetime, drifts, everUnlocked, perks, achievements, blooms
        checkAchievements()
        save()
    }

    func resetAll() {
        spores = 0; totalEarned = 0
        strainCounts = Array(repeating: 0, count: SporeDefs.strains.count)
        purchasedEnzymes = []
        humus = 0; humusLifetime = 0; drifts = 0; richness = 1.0
        everUnlocked = []
        tapCount = 0
        pressure = 0; bloomEnd = 0; bloomsReleased = 0
        humusPerkLevels = Array(repeating: 0, count: SporeDefs.perks.count)
        achievementsUnlocked = []
        offlineSummary = nil
        save()
    }

    private func syncUnlocked() {
        for i in 0..<strainCounts.count where strainCounts[i] > 0 { everUnlocked.insert(i) }
    }

    private func checkAchievements() {
        for a in SporeDefs.achievements where !achievementsUnlocked.contains(a.id) {
            if a.test(self) {
                achievementsUnlocked.insert(a.id)
                humus += 1   // small bounded reward (spendable only)
            }
        }
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
            let drain = (baseSporesPerSecond / max(1, SporeDefs.prestigeThreshold)) * dt * 0.015 * (1.0 - perkDrainReduction)
            richness = max(0, richness - drain)
        }
        // Spore pressure fills over time (saturating with production) until full.
        if pressure < 1.0 {
            let prod = baseSporesPerSecond
            let prodComponent = SporeDefs.pressureProdMax * (prod / (prod + SporeDefs.pressureProdScale))
            let rate = (SporeDefs.pressureBase + prodComponent) * pressureMultiplier
            pressure = min(1.0, pressure + rate * dt)
        }
        checkAchievements()
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
        let cap = offlineCapSeconds
        let capped = elapsed > cap
        let used = min(elapsed, cap)
        // Offline uses steady production only (no bloom buff while away).
        let earned = steadyProduction * used
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
        s.humus = humus; s.humusLifetime = humusLifetime
        s.drifts = drifts; s.richness = richness
        s.everUnlocked = Array(everUnlocked)
        s.lastActive = lastActive; s.tapCount = tapCount
        s.pressure = pressure; s.bloomEnd = bloomEnd; s.bloomsReleased = bloomsReleased
        s.humusPerkLevels = humusPerkLevels
        s.achievementsUnlocked = Array(achievementsUnlocked)
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
        humus = s.humus
        // Migration: old saves had no lifetime field — seed it from the prior absolute humus.
        humusLifetime = s.humusLifetime > 0 ? s.humusLifetime : s.humus
        drifts = s.drifts
        richness = s.richness > 0 ? min(1, s.richness) : 1.0
        everUnlocked = Set(s.everUnlocked.filter { $0 >= 0 && $0 < SporeDefs.strains.count })
        tapCount = s.tapCount
        pressure = max(0, min(1, s.pressure))
        bloomEnd = s.bloomEnd
        bloomsReleased = s.bloomsReleased
        var perks = s.humusPerkLevels
        while perks.count < SporeDefs.perks.count { perks.append(0) }
        if perks.count > SporeDefs.perks.count { perks = Array(perks.prefix(SporeDefs.perks.count)) }
        // clamp to max tiers
        for i in 0..<perks.count { perks[i] = max(0, min(perks[i], SporeDefs.perks[i].maxTier)) }
        humusPerkLevels = perks
        achievementsUnlocked = Set(s.achievementsUnlocked.filter { $0 >= 0 && $0 < SporeDefs.achievements.count })
        lastActive = s.lastActive > 0 ? s.lastActive : Date().timeIntervalSince1970
    }
}
