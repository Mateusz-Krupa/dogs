import SwiftUI

/// Provenance panel shared by puppy guides and the behaviour cards that carry
/// evidence. The citations are readable offline; a `Link` only opens a browser
/// when the owner taps it, so loading this screen never touches the network.
struct GuidanceEvidenceView: View {
    let evidence: GuidanceEvidence

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("problems.sources")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.blue)
                .textCase(.uppercase)
            ForEach(evidence.sources, id: \.url) { source in
                VStack(alignment: .leading, spacing: 2) {
                    if let url = URL(string: source.url) {
                        Link(source.title, destination: url)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.blue)
                    } else {
                        // The validator rejects unparseable URLs at load; this
                        // branch only keeps a future regression from crashing
                        // the screen instead of showing the title as text.
                        Text(source.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.ink)
                    }
                    Text(source.url)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            HStack(spacing: 6) {
                Text("problems.verifiedOn")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.muted)
                Text(evidence.verifiedOn)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }
}
