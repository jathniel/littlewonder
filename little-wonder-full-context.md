# Little Wonder — Full Product Context

## Overview
**Working title:** Little Wonder  
**Platform:** iPad first  
**Audience:** children ages 2–7, with parent-managed access

Little Wonder is a calm Montessori-style digital playroom where each topic feels like a toy. Core learning areas include shapes, numbers, animals, and colors, with a future expansion into feelings and emotional learning.

## Product goals
- Create a low-stimulation learning app for young children.
- Teach early concepts through playful, hands-on interactions.
- Keep the experience calm, spacious, and tactile.
- Support parents with a simple purchase model and clear access control.

## Learning areas
- **Shapes:** match, sort, trace, and build with circles, squares, triangles, rectangles, and more.
- **Numbers:** count objects, order numerals, connect dots, and match quantity to number.
- **Animals:** identify animals, match babies to parents, sort by habitat, and explore animal sounds.
- **Colors:** color sorting, color matching, and simple discovery tasks.
- **Feelings:** future module for recognizing emotions, reading facial expressions, and responding with empathy.

## Feelings module
The Feelings feature should arrive as a future update after the core subjects are established. It can teach basic emotional vocabulary through expressive faces, calm storytelling, and simple choice-based interactions, such as choosing how to help a sad character feel better. This adds social-emotional learning without changing the app’s gentle, Montessori-like tone.

## Experience style
The UI should stay quiet, spacious, and tactile, with soft colors, rounded shapes, slow animations, and minimal text. The goal is for children to explore independently while still feeling guided by the structure of each activity.

## Content structure
- **Home:** four big doorway tiles for Shapes, Numbers, Animals, and Colors.
- **Topic room:** a simple sandbox with 3–5 activities per topic.
- **Parent area:** progress snapshots, settings, and restore purchase.
- **Free play mode:** open-ended creation, such as shape painting or animal collage.

## Montessori-like rules
- No ads, no pop-ups, no external links for kids.
- No fail states; every action should gently redirect.
- Use self-correcting interactions, such as snapping pieces into the right place.
- Keep instructions visual and spoken, with very short prompts.

## Sample activity flow
1. Child opens Shapes.
2. They see a tray of shape blocks and a board with empty outlines.
3. They drag the correct shape into place.
4. The shape animates softly and names itself aloud.
5. After a few matches, the child can freely combine shapes into a picture.

## iPad design notes
- Portrait-first or flexible landscape with large spacing.
- Support Apple Pencil only as an optional creative tool, not a requirement.
- Prioritize haptics, audio cues, and drag interactions.
- Design for offline use and single-child focus.

## Payment model
- **Price:** $5 one-time purchase.
- **Access:** full app unlocked permanently after purchase.
- **No subscription:** remove the free trial and auto-renew logic.
- **Family handling:** support Family Sharing where possible, and parent approval controls like Ask to Buy for child accounts.

## Suggested pricing language
- Pay once, play forever.
- One-time purchase: $5.
- No subscription, no recurring charges.
- Full access unlocks all current learning activities.

## Tech stack
- **Frontend:** SwiftUI.
- **Mini-games and interactions:** SpriteKit for drag-and-drop puzzles, shape matching, dot-to-dot, and other playful activities.
- **Audio:** AVFoundation for narration, sound cues, and gentle feedback.
- **Purchase flow:** StoreKit 2 for one-time purchase entitlement and restore purchases.
- **Data layer:** SwiftData or Core Data for local progress, favorites, and offline-friendly state.
- **Architecture:** MVVM with lightweight services for content, audio, and purchase state.

## Why this stack fits
SwiftUI is a strong fit because the app needs large touch targets, simple screens, and a low-stimulation interface that can scale cleanly across iPad sizes. SpriteKit is useful for the interactive learning toys because it handles playful motion and drag interactions well. StoreKit 2 is the best option for the one-time paid unlock because it is Apple’s modern Swift-first purchasing API.

## App positioning
Little Wonder is a Montessori-inspired iPad app for kids that turns early learning into calm, open-ended play. Children can explore shapes, numbers, animals, colors, and future feelings activities at their own pace, with a one-time $5 purchase and no recurring subscription.
