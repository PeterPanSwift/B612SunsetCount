import SwiftUI

/// 小王子坐在椅子上望向右邊的夕陽，圍巾在風中飄。
struct PrinceOnChair: View {
    let palette: ScenePalette
    let time: Double

    var body: some View {
        Canvas { ctx, size in
            ctx.scaleBy(x: size.width / 80, y: size.height / 92)
            let sil = palette.silhouette.color
            let line = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)

            // 圍巾：從脖子往左後方飄動
            var scarf = Path()
            let segments = 12
            var upper: [CGPoint] = []
            var lower: [CGPoint] = []
            for i in 0...segments {
                let f = Double(i) / Double(segments)
                let x = 33 - f * 34
                let wave = sin(time * 3.2 - f * 5) * 3.2 * f
                let y = 38 - f * 4 + wave
                let half = 2.6 * (1 - f * 0.55)
                upper.append(CGPoint(x: x, y: y - half))
                lower.append(CGPoint(x: x, y: y + half))
            }
            scarf.move(to: upper[0])
            upper.dropFirst().forEach { scarf.addLine(to: $0) }
            lower.reversed().forEach { scarf.addLine(to: $0) }
            scarf.closeSubpath()
            ctx.fill(scarf, with: .color(palette.gold))

            // 椅子
            var chair = Path()
            chair.move(to: CGPoint(x: 20, y: 34))
            chair.addLine(to: CGPoint(x: 22, y: 62))
            chair.addLine(to: CGPoint(x: 22, y: 90))
            chair.move(to: CGPoint(x: 22, y: 62))
            chair.addLine(to: CGPoint(x: 48, y: 62))
            chair.addLine(to: CGPoint(x: 48, y: 90))
            chair.move(to: CGPoint(x: 21, y: 46))
            chair.addLine(to: CGPoint(x: 26, y: 46))
            ctx.stroke(chair, with: .color(sil), style: line)

            // 腿與靴子
            var legs = Path()
            legs.move(to: CGPoint(x: 33, y: 58))
            legs.addLine(to: CGPoint(x: 51, y: 58))
            legs.addLine(to: CGPoint(x: 53, y: 82))
            ctx.stroke(legs, with: .color(sil), style: StrokeStyle(lineWidth: 5.5, lineCap: .round, lineJoin: .round))
            let boot = Path(roundedRect: CGRect(x: 50, y: 80, width: 10, height: 5), cornerRadius: 2.5)
            ctx.fill(boot, with: .color(sil))

            // 外套
            var coat = Path()
            coat.move(to: CGPoint(x: 29, y: 39))
            coat.addQuadCurve(to: CGPoint(x: 39, y: 39), control: CGPoint(x: 34, y: 36))
            coat.addLine(to: CGPoint(x: 45, y: 61))
            coat.addQuadCurve(to: CGPoint(x: 24, y: 61), control: CGPoint(x: 34, y: 64))
            coat.closeSubpath()
            ctx.fill(coat, with: .color(palette.coat))

            // 手臂搭在膝上
            var arm = Path()
            arm.move(to: CGPoint(x: 37, y: 43))
            arm.addQuadCurve(to: CGPoint(x: 48, y: 55), control: CGPoint(x: 42, y: 52))
            ctx.stroke(arm, with: .color(palette.coat), style: StrokeStyle(lineWidth: 4, lineCap: .round))

            // 頭
            ctx.fill(Path(ellipseIn: CGRect(x: 27, y: 23, width: 14, height: 15)), with: .color(sil))

            // 金色頭髮
            var hair = Path()
            hair.move(to: CGPoint(x: 41.5, y: 28.5))
            hair.addQuadCurve(to: CGPoint(x: 38, y: 21.5), control: CGPoint(x: 42, y: 23))
            let tufts: [(CGFloat, CGFloat)] = [(39, 18.5), (35.5, 21), (33.5, 17.5), (31.5, 21), (27, 19), (28, 23), (22.5, 24), (26.5, 27), (23.5, 30.5), (27, 30.5)]
            tufts.forEach { hair.addLine(to: CGPoint(x: $0.0, y: $0.1)) }
            hair.addQuadCurve(to: CGPoint(x: 41.5, y: 28.5), control: CGPoint(x: 33, y: 25))
            hair.closeSubpath()
            ctx.fill(hair, with: .color(palette.gold))
        }
    }
}

/// 玻璃罩下的玫瑰。
struct RoseUnderGlass: View {
    let palette: ScenePalette

    var body: some View {
        Canvas { ctx, size in
            ctx.scaleBy(x: size.width / 30, y: size.height / 46)
            let sil = palette.silhouette.color

            var stem = Path()
            stem.move(to: CGPoint(x: 15, y: 46))
            stem.addQuadCurve(to: CGPoint(x: 15, y: 22), control: CGPoint(x: 13, y: 34))
            ctx.stroke(stem, with: .color(sil), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))

            var leaves = Path()
            leaves.move(to: CGPoint(x: 14.5, y: 36))
            leaves.addQuadCurve(to: CGPoint(x: 7, y: 31), control: CGPoint(x: 9, y: 36))
            leaves.addQuadCurve(to: CGPoint(x: 14.5, y: 36), control: CGPoint(x: 12, y: 31))
            leaves.move(to: CGPoint(x: 14.5, y: 30))
            leaves.addQuadCurve(to: CGPoint(x: 22, y: 26), control: CGPoint(x: 21, y: 30))
            leaves.addQuadCurve(to: CGPoint(x: 14.5, y: 30), control: CGPoint(x: 17, y: 26))
            ctx.fill(leaves, with: .color(sil))

            // 花苞
            var bloom = Path()
            bloom.move(to: CGPoint(x: 9.5, y: 16))
            bloom.addQuadCurve(to: CGPoint(x: 15, y: 24), control: CGPoint(x: 9, y: 23))
            bloom.addQuadCurve(to: CGPoint(x: 20.5, y: 16), control: CGPoint(x: 21, y: 23))
            bloom.addLine(to: CGPoint(x: 18, y: 12.5))
            bloom.addLine(to: CGPoint(x: 15.5, y: 15))
            bloom.addLine(to: CGPoint(x: 13, y: 11.5))
            bloom.addLine(to: CGPoint(x: 11.5, y: 14))
            bloom.closeSubpath()
            ctx.fill(bloom, with: .color(palette.rose))

            // 玻璃罩
            var dome = Path()
            dome.move(to: CGPoint(x: 3, y: 46))
            dome.addLine(to: CGPoint(x: 3, y: 14))
            dome.addArc(center: CGPoint(x: 15, y: 14), radius: 12, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            dome.addLine(to: CGPoint(x: 27, y: 46))
            ctx.fill(dome, with: .color(.white.opacity(0.07)))
            ctx.stroke(dome, with: .color(.white.opacity(0.38)), lineWidth: 0.9)
            let knob = Path(ellipseIn: CGRect(x: 13, y: -0.5, width: 4, height: 3))
            ctx.fill(knob, with: .color(.white.opacity(0.4)))

            var shine = Path()
            shine.addArc(center: CGPoint(x: 15, y: 14), radius: 9, startAngle: .degrees(200), endAngle: .degrees(250), clockwise: false)
            ctx.stroke(shine, with: .color(.white.opacity(0.55)), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
        }
    }
}

/// 小小的火山，活火山會冒出一點煙。
struct Volcano: View {
    let palette: ScenePalette
    let time: Double
    var active = true

    var body: some View {
        Canvas { ctx, size in
            ctx.scaleBy(x: size.width / 36, y: size.height / 44)
            let sil = palette.silhouette

            if active {
                for k in 0..<4 {
                    let phase = (time * 0.35 + Double(k) / 4).truncatingRemainder(dividingBy: 1)
                    let y = 22 - phase * 22
                    let x = 18 + sin(phase * 4 + time) * 3 + phase * 6
                    let r = 2.5 + phase * 4
                    ctx.opacity = (1 - phase) * 0.35
                    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                             with: .color(.white))
                }
                ctx.opacity = 1
            }

            var cone = Path()
            cone.move(to: CGPoint(x: 0, y: 44))
            cone.addQuadCurve(to: CGPoint(x: 11, y: 27), control: CGPoint(x: 8, y: 40))
            cone.addLine(to: CGPoint(x: 25, y: 27))
            cone.addQuadCurve(to: CGPoint(x: 36, y: 44), control: CGPoint(x: 28, y: 40))
            cone.closeSubpath()
            ctx.fill(cone, with: .color(sil.color))

            let rim = active ? RGB(0xFF7A3D).mix(sil, 0.45) : sil.mix(RGB(0xFFFFFF), 0.08)
            ctx.fill(Path(ellipseIn: CGRect(x: 11, y: 25.5, width: 14, height: 3.5)), with: .color(rim.color))
        }
    }
}

/// 剛冒芽的猴麵包樹。
struct BaobabSprout: View {
    let palette: ScenePalette

    var body: some View {
        Canvas { ctx, size in
            ctx.scaleBy(x: size.width / 16, y: size.height / 18)
            let c = palette.silhouette.color
            var p = Path()
            p.move(to: CGPoint(x: 8, y: 18))
            p.addLine(to: CGPoint(x: 8, y: 8))
            ctx.stroke(p, with: .color(c), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            var leaves = Path()
            for (dx, dy) in [(-6.0, -2.0), (6.0, -2.0), (0.0, -7.0)] {
                leaves.move(to: CGPoint(x: 8, y: 8))
                leaves.addQuadCurve(to: CGPoint(x: 8 + dx, y: 8 + dy), control: CGPoint(x: 8 + dx * 0.2 - 2, y: 8 + dy * 0.9 - 1))
                leaves.addQuadCurve(to: CGPoint(x: 8, y: 8), control: CGPoint(x: 8 + dx * 0.9 + 1, y: 8 + dy * 0.2 + 1))
            }
            ctx.fill(leaves, with: .color(c))
        }
    }
}

/// 一小叢草。
struct GrassTuft: View {
    let palette: ScenePalette

    var body: some View {
        Canvas { ctx, size in
            ctx.scaleBy(x: size.width / 14, y: size.height / 10)
            var p = Path()
            for (x, tipX, tipY) in [(5.0, 1.0, 1.0), (7.0, 7.0, 0.0), (9.0, 13.0, 2.0)] {
                p.move(to: CGPoint(x: x - 1, y: 10))
                p.addQuadCurve(to: CGPoint(x: tipX, y: tipY), control: CGPoint(x: x, y: 5))
                p.addQuadCurve(to: CGPoint(x: x + 1, y: 10), control: CGPoint(x: x + 0.5, y: 5))
            }
            ctx.fill(p, with: .color(palette.silhouette.color))
        }
    }
}
