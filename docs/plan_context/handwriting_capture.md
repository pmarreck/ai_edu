# Finger-written letter capture and scoring (child track)

BDFN's idea (2026-09-28): a web page on any iOS device collects the child's finger-written letters; the system judges letter form.

## Evidence status

- Handwriting practice supports letter learning at tier C (docs/evidence/EARLY_LITERACY_NUMERACY_2026-09-28.md).
- Patchan and Puranik (2016, Computers and Education) reportedly found finger-on-tablet practice produced more correctly written letters than stylus or pen for ages 3-6. Seen only in a secondary summary; unverified until the primary abstract is read.

## Design sketch

- Browser: one fixed, hand-audited canvas component (Pointer Events, `touch-action: none`) that records strokes as (x, y, t) points and posts them. Never generated per lesson.
- Server (LuaJIT, pure): score shape with a $P point-cloud recognizer (Vatavu, Anthony, Wobbrock 2012; >99% user-dependent accuracy with 5+ templates per class on adult gestures). $P ignores stroke order, so formation (stroke count, order, direction, start point) is a separate check.
- Mirror reversals (b/d, p/q) are common at age 5: record them as their own outcome, not as a plain failure.
- Control: the parent's judgment is the canonical score until the recognizer's agreement with the parent is measured on this child's own samples. Test the recognizer as a classifier over a labeled set (confusion matrix), never on single examples.
- Privacy: stroke points only, no images or audio; home network only until deployment and retention are decided.

## Apple Pencil (BDFN, 2026-09-28)

- The same canvas takes Pencil input: Pointer Events report `pointerType` ("pen" vs "touch"), and pen events carry pressure and tilt. Record the input type on every sample so scores are never pooled across finger and Pencil unknowingly.
- Finger vs Pencil is a defensible pair of practice conditions (the unverified Patchan and Puranik report favors finger; pencil-like grip may transfer better to paper). Treat it as an experiment arm, measured on paper-written letters as the transfer outcome, not as a fixed choice.
- The parent can write reference templates with the Pencil.
- Unverified until tested on the device: Safari's pen sample rate, coalesced-event support, and whether a 5-year-old's palm resting on the screen is rejected when writing with the Pencil.
