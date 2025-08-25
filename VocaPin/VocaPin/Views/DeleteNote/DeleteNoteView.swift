import SwiftUI

struct DeleteNoteView: View {
    @Binding var isPresented: Bool
    let note: Note
    let onDelete: () -> Void
    /// Pass UIImage(named: "…"); nil means no image and no reserved space
    let hero: UIImage?

    init(
        isPresented: Binding<Bool>,
        note: Note,
        onDelete: @escaping () -> Void,
        hero: UIImage? = nil
    ) {
        self._isPresented = isPresented
        self.note = note
        self.onDelete = onDelete
        self.hero = hero
    }

    private let dialogMaxWidth: CGFloat = 320

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: hero == nil ? 10 : 14) {
                Text("Delete Note")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.black)
                    .padding(.top, 10)

                // Only shows if the UIImage exists; otherwise takes zero space
                if let hero {
                    Image(uiImage: hero)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120) // slightly smaller than before
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 16)
                }

                // Compact note preview
                if !note.text.isEmpty {
                    NotePreview(note: note)
                }

                Text("Are you sure you want to remove the content in the sticky notes?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)

                HStack(spacing: 12) {
                    Button { isPresented = false } label: {
                        Text("Cancel")
                            .font(.callout.bold())
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    Button {
                        onDelete()
                        isPresented = false
                    } label: {
                        Text("Delete")
                            .font(.callout.bold())
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundColor(.red)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
            )
            .frame(maxWidth: dialogMaxWidth)
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Small subview stays the same
private struct NotePreview: View {
    let note: Note
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.70, green: 0.50, blue: 0.30))
                .frame(width: 110, height: 85)
                .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 1)

            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(note.color)
                .frame(width: 96, height: 72)
                .overlay(
                    Text(note.text)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)
                        .padding(6)
                )

            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 1)
                .offset(y: -48)
        }
    }
}

#Preview {
    DeleteNoteView(
        isPresented: .constant(true),
        note: Note(text: "Speak it and\nStick it!", position: .zero, rotation: 0),
        onDelete: {},
        hero: UIImage(named: "SpeakStick") // if this asset doesn't exist, no blank space
    )
}
