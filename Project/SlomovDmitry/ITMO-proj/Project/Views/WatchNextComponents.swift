import SwiftUI

// Общие элементы оформления (стекло)
struct WatchNextBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.07, green: 0.13, blue: 0.22),
                     Color(red: 0.02, green: 0.04, blue: 0.09)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct WatchNextPosterView: View {
    let url: URL?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty:
                if url != nil {
                    SwiftUI.Rectangle()
                        .fill(.white.opacity(0.06))
                        .overlay { ProgressView().tint(.mint) }
                } else {
                    placeholder
                }
            case .failure:
                placeholder
            @unknown default:
                placeholder
            }
        }
        .frame(width: width, height: height)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        SwiftUI.Rectangle()
            .fill(.white.opacity(0.06))
            .overlay {
                Image(systemName: "film")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.3))
            }
    }
}

struct WatchNextShowRow: View {
    let show: WatchNextShow
    @AppStorage("watchnext.showRatings") private var showRatings = true

    var body: some View {
        HStack(spacing: 14) {
            WatchNextPosterView(url: show.imageURL, width: 70, height: 100)

            VStack(alignment: .leading, spacing: 8) {
                Text(show.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if !show.genres.isEmpty {
                    Text(show.genres.prefix(2).joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 12) {
                    Text("\(show.kindTitle) · \(show.year)").foregroundStyle(.secondary)
                    if showRatings, show.rating?.average != nil {
                        Label(show.ratingText, systemImage: "star.fill")
                            .foregroundStyle(.mint)
                    }
                }
                .font(.caption)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
