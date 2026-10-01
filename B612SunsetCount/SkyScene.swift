import SwiftUI

/// 星球與太陽的版面配置。
struct SceneLayout {
    let size: CGSize
    let radius: CGFloat
    let center: CGPoint
    let scale: CGFloat

    init(size: CGSize) {
        self.size = size
        radius = max(min(size.width, size.height) * 0.95, size.width * 0.6)
        center = CGPoint(x: size.width / 2, y: size.height * 0.72 + radius)
        scale = min(max(radius / 380, 0.8), 1.7)
    }

    var top: CGFloat { center.y - radius }

    func surfaceY(atX x: CGFloat) -> CGFloat {
        let dx = x - center.x
        return center.y - sqrt(max(radius * radius - dx * dx, 0))
    }
}

/// B-612 的整個日落場景。progress: 0 = 金色黃昏、1 = 星夜；rotation: 星球轉動的角度。
struct B612Scene: View, Animatable {
    var progress: Double
    var rotation: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(progress, rotation) }
        set {
            progress = newValue.first
            rotation = newValue.second
        }
    }

    var body: some View {
        GeometryReader { geo in
            let layout = SceneLayout(size: geo.size)
            let palette = ScenePalette(progress: progress)
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    LinearGradient(
                        stops: [
                            .init(color: palette.skyTop, location: 0),
                            .init(color: palette.skyUpper, location: 0.38),
                            .init(color: palette.skyLower, location: 0.62),
                            .init(color: palette.skyHorizon, location: 0.76),
                        ],
                        startPoint: .top, endPoint: .bottom
                    )

                    StarField(progress: progress, time: t)

                    RingedPlanet()
                        .frame(width: 46 * layout.scale, height: 46 * layout.scale)
                        .position(x: layout.size.width * 0.16, y: layout.size.height * 0.36)
                        .opacity(0.25 + smoothstep(0.3, 1, progress) * 0.55)

                    sun(layout: layout, palette: palette)

                    clouds(layout: layout, palette: palette, time: t)

                    planet(layout: layout, palette: palette, time: t)
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    // MARK: - 太陽

    @ViewBuilder
    private func sun(layout: SceneLayout, palette: ScenePalette) -> some View {
        let sunX = layout.center.x + min(layout.radius * 0.42, layout.size.width * 0.3)
        let horizon = layout.surfaceY(atX: sunX)
        let sunR = 30 * layout.scale
        let start = horizon - layout.size.height * 0.17
        let end = horizon + sunR * 1.5
        let sunY = start + (end - start) * min(progress / 0.68, 1)
        let glowY = min(sunY, horizon)
        let fade = 1 - smoothstep(0.55, 1, progress)

        // 大片的暖色光暈
        Rectangle()
            .fill(EllipticalGradient(colors: [palette.glow.opacity(0.85), palette.glow.opacity(0)],
                                     center: .center, startRadiusFraction: 0, endRadiusFraction: 0.5))
            .frame(width: sunR * 16, height: sunR * 10)
            .position(x: sunX, y: glowY)
            .opacity(0.35 + fade * 0.65)

        Circle()
            .fill(palette.sun.opacity(0.45))
            .frame(width: sunR * 3.2, height: sunR * 3.2)
            .blur(radius: 18 * layout.scale)
            .position(x: sunX, y: sunY)
            .opacity(fade)

        Circle()
            .fill(RadialGradient(colors: [palette.sunCore, palette.sun],
                                 center: .center, startRadius: 0, endRadius: sunR))
            .frame(width: sunR * 2, height: sunR * 2)
            .shadow(color: palette.sun.opacity(0.9), radius: 14)
            .position(x: sunX, y: sunY)
    }

    // MARK: - 雲

    @ViewBuilder
    private func clouds(layout: SceneLayout, palette: ScenePalette, time: Double) -> some View {
        let w = layout.size.width
        let h = layout.size.height
        let wisps: [(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, speed: Double)] = [
            (0.22, 0.50, 0.55, 0.016, 0.05),
            (0.78, 0.44, 0.45, 0.012, 0.04),
            (0.62, 0.56, 0.70, 0.020, 0.03),
            (0.30, 0.60, 0.40, 0.010, 0.06),
        ]
        ForEach(wisps.indices, id: \.self) { i in
            let c = wisps[i]
            Capsule()
                .fill(LinearGradient(colors: [palette.cloud.opacity(0), palette.cloud, palette.cloud.opacity(0)],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(width: c.width * w, height: max(c.height * h, 6))
                .blur(radius: 4)
                .position(x: c.x * w + sin(time * c.speed + Double(i) * 2) * 24, y: c.y * h)
                .opacity(0.75 - progress * 0.35)
        }
    }

    // MARK: - 星球 B-612

    @ViewBuilder
    private func planet(layout: SceneLayout, palette: ScenePalette, time: Double) -> some View {
        let r = layout.radius
        let s = layout.scale
        let lit = 1 - smoothstep(0.4, 1, progress)

        // 大氣光暈
        Circle()
            .fill(palette.skyHorizon.opacity(0.7))
            .frame(width: r * 2 + 30, height: r * 2 + 30)
            .blur(radius: 26)
            .position(layout.center)
            .opacity(0.4 + lit * 0.6)

        Circle()
            .fill(RadialGradient(colors: [palette.planetLight, palette.planetDark],
                                 center: UnitPoint(x: 0.66, y: 0.02),
                                 startRadius: 0, endRadius: r * 1.3))
            .overlay(
                Circle().stroke(
                    LinearGradient(colors: [Color.sunGold.opacity(0.9 * lit), .clear],
                                   startPoint: .topTrailing, endPoint: UnitPoint(x: 0.35, y: 0.25)),
                    lineWidth: 2.5)
            )
            .frame(width: r * 2, height: r * 2)
            .position(layout.center)

        // 隨著挪椅子而轉動的星球表面
        ZStack {
            ForEach(Self.craters.indices, id: \.self) { i in
                let c = Self.craters[i]
                OnPlanet(radius: r, angle: c.angle, depth: c.depth * s) {
                    Ellipse()
                        .fill(palette.planetDark.opacity(0.55))
                        .overlay(Ellipse().stroke(Color.white.opacity(0.06), lineWidth: 1).offset(y: 1))
                        .frame(width: c.size * s, height: c.size * 0.38 * s)
                }
            }

            OnPlanet(radius: r, angle: 19, depth: 2) {
                RoseUnderGlass(palette: palette).frame(width: 30 * s, height: 46 * s)
            }
            OnPlanet(radius: r, angle: -20, depth: 2) {
                Volcano(palette: palette, time: time).frame(width: 36 * s, height: 44 * s)
            }
            OnPlanet(radius: r, angle: -27, depth: 2) {
                Volcano(palette: palette, time: time + 1.3).frame(width: 30 * s, height: 37 * s)
            }
            OnPlanet(radius: r, angle: 62, depth: 2) {
                Volcano(palette: palette, time: time, active: false).frame(width: 32 * s, height: 39 * s)
            }
            OnPlanet(radius: r, angle: 216, depth: 2) {
                Volcano(palette: palette, time: time + 0.6).frame(width: 36 * s, height: 44 * s)
            }
            ForEach([11.0, 48, 110, 170, 250, 300], id: \.self) { angle in
                OnPlanet(radius: r, angle: angle, depth: 1) {
                    BaobabSprout(palette: palette).frame(width: 14 * s, height: 16 * s)
                }
            }
            ForEach([-13.0, 6, 27, 84, 135, 190, 232, 275, 320], id: \.self) { angle in
                OnPlanet(radius: r, angle: angle, depth: 1) {
                    GrassTuft(palette: palette).frame(width: 14 * s, height: 10 * s)
                }
            }
        }
        .frame(width: r * 2, height: r * 2)
        .rotationEffect(.degrees(rotation))
        .position(layout.center)

        // 小王子坐在星球頂端偏左，望向夕陽
        OnPlanet(radius: r, angle: -5, depth: 1) {
            PrinceOnChair(palette: palette, time: time).frame(width: 80 * s, height: 92 * s)
        }
        .frame(width: r * 2, height: r * 2)
        .position(layout.center)
    }

    private static let craters: [(angle: Double, depth: CGFloat, size: CGFloat)] = [
        (-30, 70, 46), (-8, 150, 70), (14, 48, 30), (36, 120, 56), (58, 70, 34),
        (-56, 140, 60), (90, 90, 50), (150, 80, 44), (205, 110, 58), (260, 70, 40), (310, 130, 64),
    ]
}

/// 把內容放到星球表面指定角度的位置（0° 為正上方）。
struct OnPlanet<Content: View>: View {
    let radius: CGFloat
    let angle: Double
    var depth: CGFloat = 0
    @ViewBuilder var content: Content

    var body: some View {
        content
            .alignmentGuide(.top) { d in d[.bottom] - depth }
            .frame(width: radius * 2, height: radius * 2, alignment: .top)
            .rotationEffect(.degrees(angle))
    }
}

/// 遠方一顆帶環的小行星。
struct RingedPlanet: View {
    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let ring = CGRect(x: 0, y: w * 0.38, width: w, height: w * 0.24)
            let body = CGRect(x: w * 0.25, y: w * 0.25, width: w * 0.5, height: w * 0.5)
            ctx.translateBy(x: w / 2, y: w / 2)
            ctx.rotate(by: .degrees(-18))
            ctx.translateBy(x: -w / 2, y: -w / 2)

            let ringPath = Path(ellipseIn: ring)
            ctx.stroke(ringPath, with: .color(Color.cream.opacity(0.45)), lineWidth: 1.2)

            ctx.fill(Path(ellipseIn: body),
                     with: .linearGradient(Gradient(colors: [Color(red: 0.97, green: 0.80, blue: 0.70),
                                                             Color(red: 0.52, green: 0.40, blue: 0.62)]),
                                           startPoint: CGPoint(x: body.maxX, y: body.minY),
                                           endPoint: CGPoint(x: body.minX, y: body.maxY)))

            // 前半圈的環蓋在星球上
            var front = ctx
            front.clip(to: Path(CGRect(x: 0, y: ring.midY, width: w, height: w)))
            front.stroke(ringPath, with: .color(Color.cream.opacity(0.75)), lineWidth: 1.2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// 隨夜色浮現、會閃爍的星星，偶爾劃過一顆流星。
struct StarField: View {
    let progress: Double
    let time: Double

    private struct Star {
        let x: Double, y: Double, size: Double, brightness: Double, speed: Double, phase: Double
    }

    private static let stars: [Star] = {
        var seed: UInt64 = 612
        func next() -> Double {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return Double(seed >> 11) / Double(1 << 53)
        }
        return (0..<140).map { _ in
            let big = next() < 0.12
            return Star(x: next(), y: pow(next(), 1.3) * 0.72,
                        size: big ? 1.4 + next() * 1.0 : 0.5 + next() * 0.8,
                        brightness: 0.5 + next() * 0.5,
                        speed: 0.8 + next() * 2.4, phase: next() * 6.28)
        }
    }()

    var body: some View {
        Canvas { ctx, size in
            let visible = smoothstep(0.3, 0.95, progress)
            guard visible > 0.01 else { return }

            for star in Self.stars {
                let p = CGPoint(x: star.x * size.width, y: star.y * size.height)
                let twinkle = 0.55 + 0.45 * sin(time * star.speed + star.phase)
                ctx.opacity = visible * twinkle * star.brightness
                let r = star.size
                ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                         with: .color(Color(red: 1, green: 0.97, blue: 0.9)))
                if r > 1.6 {
                    var sparkle = Path()
                    sparkle.move(to: CGPoint(x: p.x - r * 3.2, y: p.y))
                    sparkle.addLine(to: CGPoint(x: p.x + r * 3.2, y: p.y))
                    sparkle.move(to: CGPoint(x: p.x, y: p.y - r * 3.2))
                    sparkle.addLine(to: CGPoint(x: p.x, y: p.y + r * 3.2))
                    ctx.opacity *= 0.5
                    ctx.stroke(sparkle, with: .color(.white), lineWidth: 0.6)
                }
            }

            // 流星：每 8 秒一顆
            let period = 8.0
            let local = time.truncatingRemainder(dividingBy: period)
            let duration = 0.9
            if local < duration, visible > 0.6 {
                let n = floor(time / period)
                let sx = (0.25 + 0.6 * abs(sin(n * 12.9898))) * size.width
                let sy = (0.06 + 0.2 * abs(sin(n * 78.233))) * size.height
                let f = local / duration
                let head = CGPoint(x: sx - f * 160, y: sy + f * 90)
                let tail = CGPoint(x: head.x + 70, y: head.y - 40)
                var path = Path()
                path.move(to: tail)
                path.addLine(to: head)
                ctx.opacity = visible * sin(f * .pi)
                ctx.stroke(path,
                           with: .linearGradient(Gradient(colors: [.white.opacity(0), .white]),
                                                 startPoint: tail, endPoint: head),
                           style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            }
        }
    }
}
