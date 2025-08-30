import SwiftUI


struct StickyNoteView: View {
    let note: Note
    let isEditing: Bool
    @Binding var editingText: String
    var onTap: () -> Void

    private let noteSize = CGSize(width: 320, height: 420)
    private let cornerRadius: CGFloat = 22
    private let basePadding: CGFloat = 16
    private let pinDiameter: CGFloat = 28
    private let pinOverlap: CGFloat = 8  // how much the pin “bites” into the note

    var body: some View {
        let extraTopInset = pinDiameter / 2 + pinOverlap + 6
        
        ZStack {
            // NOTE BACKGROUND
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(note.color)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
            
            // NOTE CONTENT
            VStack(alignment: .leading, spacing: 10) {
                if isEditing {
                    TextEditor(text: $editingText)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    Text(note.text.isEmpty ? "Tap to add note" : note.text)
                        .font(.custom("Marker Felt", size: 28))
                        .foregroundColor(note.text.isEmpty ? .black.opacity(0.4) : .black)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .padding(.horizontal, basePadding)
            .padding(.bottom, basePadding)
            .padding(.top, basePadding + extraTopInset) // leave space for the pin
        }
        .frame(width: noteSize.width, height: noteSize.height)
        .rotationEffect(.degrees(note.rotation))
        .overlay(
            // Pin is positioned RELATIVE TO THE NOTE, not the screen
            /*  PinIcon()
             .frame(width: pinDiameter, height: pinDiameter)
             // only move a little upward so it overlaps the note edge
             .offset(y: -(pinDiameter / 2) + pinOverlap),
             alignment: .top*/
            
            // Red pin (head only, no needle)
            (
                // Red pin (head only, no needle)
                VStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 22, height: 22)
                                .offset(x: -4, y: -4)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 2)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .offset(y: -16)
            )
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onTapGesture(perform: onTap)
        .zIndex(1)
    }
}

// Small red pin
private struct PinIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.red)
                .shadow(radius: 3, y: 2)
            Circle()
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 12, height: 12)
        }
        .overlay(
            Rectangle()
                .fill(.red)
                .frame(width: 3, height: 20)
                .offset(y: 20),
            alignment: .bottom
        )
        .accessibilityHidden(true)
    }
}
/*
private struct PinIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.red)
                .shadow(radius: 3, y: 2)
            Circle()
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 12, height: 12)
        }
        .accessibilityHidden(true)
    }
}


struct StickyNoteView: View {
    let note: Note
    let isEditing: Bool
    @Binding var editingText: String
    var onTap: () -> Void

    // Layout constants
    private let noteSize = CGSize(width: 320, height: 420)
    private let cornerRadius: CGFloat = 22
    private let basePadding: CGFloat = 16
    private let pinDiameter: CGFloat = 28
    private let pinOverlapIntoNote: CGFloat = 10  // how much the pin overlaps the top edge

    var body: some View {
        // Extra top space so text never touches the pin
        let extraTopInset = pinDiameter / 2 + pinOverlapIntoNote + 6

        ZStack {
            // NOTE BACKGROUND
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(note.color)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)

            // NOTE CONTENT
            VStack(alignment: .leading, spacing: 10) {
                if isEditing {
                    TextEditor(text: $editingText)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .accessibilityLabel("Note text editor")
                } else {
                    Text(note.text.isEmpty ? "Tap to add note" : note.text)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .accessibilityLabel(note.text.isEmpty ? "Empty note. Tap to add note." : "Note text")
                }
            }
            .padding(.horizontal, basePadding)
            .padding(.bottom, basePadding)
            .padding(.top, basePadding + extraTopInset) // <- keeps text clear of the pin
        }
        .frame(width: noteSize.width, height: noteSize.height)
        .rotationEffect(.degrees(note.rotation))
        .overlay(
            // PIN AT TOP CENTER, ABOVE THE NOTE
            PinIcon()
                .frame(width: pinDiameter, height: pinDiameter)
                .offset(y: -(noteSize.height / 2) - 6 + pinOverlapIntoNote),
            alignment: .top
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onTapGesture(perform: onTap)
        .zIndex(1) // keeps the pin/note above the board
    }
}


// Small red pin
private struct PinIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.red)
                .shadow(radius: 3, y: 2)
            Circle()
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 12, height: 12)
        }
        .overlay(
            Rectangle()
                .fill(.red)
                .frame(width: 3, height: 20)
                .offset(y: 20),
            alignment: .bottom
        )
        .accessibilityHidden(true)
    }
}
 */
