# Manual SOLIDWORKS guidance

Use the user's release/UI language and experience. Work in manageable stages; do not make the user complete a speculative questionnaire. For fully specified geometry, start modeling.

Each stage states its inputs, plane/datum, sketch entities and relations, dimensions with units, feature/settings, expected intermediate result, and a short check. Explain the design intent behind constraints and feature order. Avoid fragile face/edge references when stable datums or named geometry suffice. Ask for feedback only at a real uncertainty or stage boundary.

## Synthetic plate example (not a user's component)

1. New Part from the user's normal part template. Set display units to mm. Select an origin plane (for example Top Plane; names may be localized), then Sketch. Expected: empty sketch on the chosen plane.
2. Draw a center rectangle centered/coincident at the sketch origin. Make its sides horizontal/vertical, set width60 mm and height30 mm. Check that center, orientation and both dimensions are constrained; inspect any remaining degrees of freedom rather than relying only on color.
3. Exit sketch; use Boss-Extrude, blind depth4 mm. Expected: one rectangular solid body. Check width60, height30, thickness4 mm with Measure or dimensions and rebuild. Feature names depend on language/template.
4. Save to a new user-chosen .SLDPRT name. Reopen/inspect when feasible. Record what the user actually observed. Add exports only if requested, checking units, scope and actual file.

## Enclosures and assemblies

For an enclosure, parameterize inner and outer envelopes, floor/lid heights and board offsets first; use a dimensioned outer profile plus inner cut/shell appropriate to design intent. Add standoffs from measured hole datums, openings from connector/cable envelopes, attachment geometry and process clearances. Model the lid as a separate editable part when that fits assembly intent. Check assembly access and actual mating fit; label material and print settings as proposals until chosen.

For a multi-part mechanism, establish base/assembly datums, create separate components, define interfaces and mates, preserve intended degrees of freedom, then inspect motion and interference. Ask for the missing camera interface/load before finalizing a camera bracket; do not ask for a circuit-board mounting pattern.

For a revision, update the governing dimensions/equations and all dependent features, instructions and checks. If the specified envelope cannot fit the required contents, show the conflict and alternatives before proceeding with that dependent geometry.
