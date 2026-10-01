import SwiftUI

struct ContentView: View {
    /// 「有一天，我看了四十四次日落！」
    static let goal = 44

    @AppStorage("sunset.today") private var todayCount = 0
    @AppStorage("sunset.total") private var totalCount = 0
    @AppStorage("sunset.day") private var dayKey = ""

    @State private var progress: Double = 0
    @State private var rotation: Double = 0
    @State private var isSetting = false
    @State private var showResetConfirm = false
    @Environment(\.scenePhase) private var scenePhase

    /// 每挪一次椅子，星球轉 1/44 圈；看完 44 次日落剛好繞星球一周。
    private var step: Double { 360 / Double(Self.goal) }

    var body: some View {
        ZStack {
            B612Scene(progress: progress, rotation: rotation)

            VStack(spacing: 0) {
                header

                SunsetRing(count: todayCount, goal: Self.goal)
                    .frame(width: 188, height: 188)
                    .padding(.top, 28)

                Text("一共看過 \(totalCount) 次日落")
                    .font(.footnote)
                    .tracking(1.5)
                    .opacity(0.7)
                    .padding(.top, 14)

                quote
                    .padding(.top, 26)

                Spacer(minLength: 0)

                actionButton
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .foregroundStyle(Color.cream)
            .shadow(color: .black.opacity(0.22), radius: 10, y: 2)
        }
        .sensoryFeedback(.success, trigger: todayCount) { old, new in new > old }
        .onAppear {
            rolloverIfNeeded()
            rotation = -Double(todayCount) * step
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { rolloverIfNeeded() }
        }
        .confirmationDialog("重新開始今天的日落？", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("重新開始", role: .destructive, action: resetToday)
            Button("取消", role: .cancel) {}
        } message: {
            Text("今天的次數會歸零，總次數會保留。")
        }
    }

    // MARK: - 畫面元件

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ASTEROID B-612")
                    .font(.system(.caption2, design: .serif).weight(.semibold))
                    .tracking(3.5)
                    .opacity(0.75)
                Text("小王子的日落")
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .tracking(2)
            }
            Spacer()
            Button {
                showResetConfirm = true
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .circle)
            .disabled(isSetting || todayCount == 0)
            .opacity(todayCount == 0 ? 0.5 : 1)
            .accessibilityLabel("重新開始今天的日落")
        }
        .padding(.top, 8)
    }

    private var quote: some View {
        Text(currentQuote)
            .font(.system(.callout, design: .serif))
            .italic()
            .multilineTextAlignment(.center)
            .lineSpacing(7)
            .frame(maxWidth: 320)
            .id(currentQuote)
            .transition(.opacity.combined(with: .offset(y: 8)))
            .animation(.easeInOut(duration: 0.9), value: currentQuote)
    }

    private var actionButton: some View {
        Button(action: watchSunset) {
            HStack(spacing: 10) {
                Image(systemName: buttonIcon)
                    .symbolEffect(.pulse, isActive: isSetting)
                Text(buttonTitle)
                    .tracking(1.5)
            }
            .font(.system(.headline, design: .serif))
            .padding(.horizontal, 30)
            .padding(.vertical, 17)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(Color.sunGold.opacity(isSetting ? 0.08 : 0.28)).interactive(), in: .capsule)
        .disabled(isSetting)
        .animation(.easeInOut(duration: 0.4), value: buttonTitle)
    }

    private var buttonTitle: String {
        if isSetting { return "太陽正在落下⋯" }
        return progress > 0.5 ? "把椅子往後挪幾步" : "看一次日落"
    }

    private var buttonIcon: String {
        if isSetting { return "sun.horizon.fill" }
        return progress > 0.5 ? "chair.fill" : "sunset.fill"
    }

    private var currentQuote: String {
        if todayCount == 0 { return Self.openingLine }
        if todayCount == Self.goal { return Self.finaleLine }
        if todayCount > Self.goal { return Self.beyondLine }
        return Self.quotes[(todayCount - 1) % Self.quotes.count]
    }

    // MARK: - 日落流程

    private func watchSunset() {
        guard !isSetting else { return }
        isSetting = true
        if progress > 0.5 {
            // 挪動椅子：星球轉一點，天空回到黃昏
            withAnimation(.easeInOut(duration: 1.8)) {
                progress = 0
                rotation -= step
            } completion: {
                sink()
            }
        } else {
            sink()
        }
    }

    private func sink() {
        withAnimation(.timingCurve(0.42, 0, 0.5, 1, duration: 6)) {
            progress = 1
        } completion: {
            rolloverIfNeeded()
            withAnimation(.spring(duration: 0.8)) {
                todayCount += 1
                totalCount += 1
            }
            isSetting = false
        }
    }

    private func resetToday() {
        withAnimation(.easeInOut(duration: 1.6)) {
            todayCount = 0
            progress = 0
            rotation = 0
        }
    }

    private func rolloverIfNeeded() {
        let today = Date.now.formatted(.iso8601.year().month().day())
        if dayKey != today {
            dayKey = today
            todayCount = 0
            rotation = 0
        }
    }

    // MARK: - 文字

    private static let openingLine = "當一個人很憂傷的時候，\n就會特別喜歡看日落。"
    private static let finaleLine = "第四十四次了。\n今天的你，一定很需要這些溫柔的黃昏吧。"
    private static let beyondLine = "星球已經繞了一整圈，\n夕陽還是願意再陪你一次。"

    private static let quotes = [
        "在這麼小的星球上，\n只要把椅子挪幾步，就能再看一次黃昏。",
        "真正重要的東西，\n用眼睛是看不見的。",
        "星星這麼美，\n是因為有一朵看不見的花。",
        "你為你的玫瑰花費的時間，\n讓她變得那麼重要。",
        "所有的大人都曾經是小孩，\n只是很少人記得。",
        "夜裡仰望星空的時候，\n會覺得每一顆星星都在笑。",
        "沙漠之所以美，\n是因為某處藏著一口井。",
        "如果你在下午四點來，\n我從三點就會開始覺得幸福。",
        "記得每天早上，\n替星球拔掉剛冒芽的猴麵包樹。",
        "要照顧好玫瑰，\n她只有四根刺可以保護自己。",
        "火山也要好好清理，\n它們才會溫柔地燃燒。",
    ]
}

/// 以 44 道刻度環繞的日落計數。
struct SunsetRing: View {
    let count: Int
    let goal: Int

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial.opacity(0.35))
                    .padding(22)

                ForEach(0..<goal, id: \.self) { i in
                    let lit = i < count
                    Capsule()
                        .fill(lit ? Color.sunGold : Color.cream.opacity(0.22))
                        .frame(width: 3, height: i % 11 == 0 ? 15 : 9)
                        .shadow(color: lit ? Color.sunGold.opacity(0.9) : .clear, radius: 4)
                        .offset(y: -side / 2 + 8)
                        .rotationEffect(.degrees(Double(i) / Double(goal) * 360))
                        .animation(.spring(duration: 0.6).delay(lit ? 0.05 : 0), value: lit)
                }

                VStack(spacing: 2) {
                    Text("\(count)")
                        .font(.system(size: 66, weight: .light, design: .serif))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: Double(count)))
                    Text(count >= goal ? "次 · 圓滿" : "/ \(goal) 次日落")
                        .font(.system(.footnote, design: .serif))
                        .tracking(2)
                        .opacity(0.8)
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("今天看了 \(count) 次日落，目標 \(goal) 次")
    }
}

#Preview {
    ContentView()
}
