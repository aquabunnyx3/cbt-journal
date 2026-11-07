import StoreKit
import SwiftUI

/// One-time, non-consumable purchase that unlocks days 6–30.
/// Create a Non-Consumable in App Store Connect with exactly this Product ID.
enum PurchaseConfig {
    static let fullProgramID = "com.aquabunnygames.thoughtdrift.fullprogram"
    static let freeDays = 5
}

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var product: Product?
    @Published private(set) var hasFullAccess: Bool
    @Published private(set) var isPurchasing = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?
    private let cacheKey = "hasFullAccess"

    init() {
        // Cached so the app opens unlocked even before StoreKit answers.
        hasFullAccess = UserDefaults.standard.bool(forKey: cacheKey)
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
        Task {
            await loadProduct()
            await refreshEntitlements()
        }
    }

    deinit { updatesTask?.cancel() }

    func requiresPurchase(_ day: Int) -> Bool {
        day > PurchaseConfig.freeDays && !hasFullAccess
    }

    func loadProduct() async {
        do {
            product = try await Product.products(for: [PurchaseConfig.fullProgramID]).first
        } catch {
            product = nil
        }
    }

    func refreshEntitlements() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == PurchaseConfig.fullProgramID,
               transaction.revocationDate == nil {
                owned = true
            }
        }
        setAccess(owned)
    }

    func purchase() async {
        if product == nil { await loadProduct() }
        guard let product else {
            errorMessage = "The store isn't available right now. Please try again in a moment."
            return
        }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    setAccess(true)
                } else {
                    errorMessage = "We couldn't verify that purchase. Please try Restore Purchases."
                }
            case .pending:
                errorMessage = "Your purchase is pending approval. It will unlock automatically once approved."
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            // The user may cancel the sign-in sheet; entitlements are still checked below.
        }
        await refreshEntitlements()
        if !hasFullAccess {
            errorMessage = "No previous purchase was found for this Apple ID."
        }
    }

    private func setAccess(_ value: Bool) {
        hasFullAccess = value
        UserDefaults.standard.set(value, forKey: cacheKey)
    }
}

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.accent)
                        .padding(.top, 12)

                    VStack(spacing: 8) {
                        Text("Unlock the Full Program")
                            .font(.calm(.largeTitle, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Theme.ink)
                        Text("You've explored the first \(PurchaseConfig.freeDays) days. Keep going with the complete 30-day CBT journey.")
                            .font(.calm(.body))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Theme.muted)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        feature("calendar", "All 30 daily prompts and quotes")
                        feature("arrow.triangle.2.circlepath", "Weeks 2–4: Challenge, Reframe, Integrate")
                        feature("heart.text.square", "Every weekly check-in and milestone")
                        feature("lock.shield", "Entries stay private on your device")
                        feature("checkmark.seal", "One-time purchase — no subscription")
                    }
                    .card()

                    Button {
                        Task {
                            await purchases.purchase()
                            if purchases.hasFullAccess { dismiss() }
                        }
                    } label: {
                        if purchases.isPurchasing {
                            ProgressView().tint(.white)
                        } else if let product = purchases.product {
                            Text("Unlock for \(product.displayPrice)")
                        } else {
                            Text("Unlock Full Program")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(purchases.isPurchasing)

                    Button("Restore Purchases") {
                        Task {
                            await purchases.restore()
                            if purchases.hasFullAccess { dismiss() }
                        }
                    }
                    .font(.calm(.subheadline, weight: .medium))
                    .foregroundStyle(Theme.sage)

                    Text("Payment is charged to your Apple ID. The first \(PurchaseConfig.freeDays) days are always free.")
                        .font(.calm(.footnote))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.muted)
                }
                .padding(24)
                .readableWidth(560)
            }
            .calmBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { dismiss() }
                }
            }
            .task { if purchases.product == nil { await purchases.loadProduct() } }
            .alert("Purchase", isPresented: Binding(
                get: { purchases.errorMessage != nil },
                set: { if !$0 { purchases.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(purchases.errorMessage ?? "")
            }
        }
    }

    private func feature(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Theme.sage)
                .frame(width: 28)
            Text(text)
                .font(.calm(.body))
                .foregroundStyle(Theme.ink)
        }
    }
}

/// Small card shown where locked premium content would be.
struct UnlockCard: View {
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showPaywall = false
    var message = "Days \(PurchaseConfig.freeDays + 1)–30 are part of the full program."

    var body: some View {
        Button { showPaywall = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.sage)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock the full program")
                        .font(.calm(.headline))
                        .foregroundStyle(Theme.ink)
                    Text(message)
                        .font(.calm(.subheadline))
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.muted)
            }
            .card()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPaywall) { PaywallView().environmentObject(purchases) }
    }
}
