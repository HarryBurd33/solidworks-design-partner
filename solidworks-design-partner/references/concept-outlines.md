# Concept outlines with Anatomy

Present the design before building it: what parts exist, where they go, which dimensions/interfaces govern them, how they attach, and what remains unresolved. Use labels and dimension tables for engineering communication. Simple tasks need a compact outline; no minimum part count or invented mechanism applies.

## Choose the outline

- Written parts/interface/parameter/feature plan works for every design, including missing measurements and unavailable rendering tools.
- SVG/HTML isometric previews help compare arrangements and assembled/exploded views. Use only measured/supplied dimensions or explicitly proposed/assumed values; preserve their status. Unknown dimensions stay unknown in the written outline. A symbolic sketch is preferable to a fabricated measured drawing.
- Request-specific outlines may include top/front/side sketches or CAD drawings only through supported tools; the bundled renderer supplies simplified isometric envelopes, not dimensioned production drawings.

## Render a preview

Node.js20.10+; no npm install, API key or network is required. From this skill folder, run the [renderer](../scripts/render-outline.mjs) with an input JSON and a NEW output directory:

```sh
node scripts/render-outline.mjs examples/concept-outline.json /tmp/solidworks-concept-preview
```

The [example](../examples/concept-outline.json) is synthetic. Copy it into the user's project and edit its values; do not store private designs in the installed skill. The schema uses `units: "mm"`, `title`, and `parts`. Each part has a unique safe `id`, `name`, `shape` (`box` or `cylinder`), `position: [x,y,z]`, and `status` (`supplied`, `proposed`, or `assumed`). Boxes use `size: [width,depth,height]`; cylinders use `radius` and `height` along z. Optional `explode: [dx,dy,dz]` changes the display arrangement only. Values must be finite and dimensions positive; zero/negative coordinates are valid. No measured-versus-proposed inference is made by the renderer: the author must preserve the brief's actual status and explain source/uncertainty.

The renderer writes `outline.svg`, standalone `outline.html`, and `parameters.json`. Open HTML in a browser and toggle its Exploded view control. The dimension table and geometry derive from the same parameters; explode displacement does not change component dimensions. Use a new output directory to preserve earlier work. Invalid inputs and existing outputs must fail without overwriting.

## Review and carry forward

Show the outline artifact and identify the decisions to inspect: overall arrangement/envelope, component interfaces, assembly access, clearances and unresolved measurements. Update the brief and parameter source together. For a fixed100×70mm exterior with walls2→3mm, cavity96×66 becomes94×64; do not preserve an obsolete outline or silently enlarge the exterior.

“Outline only” or explicit review-first stops before any construction or macro generation. Otherwise present the outline and proceed within an already authorized build request; do not invent a mandatory approval step. Carry settled dimensions, datums, choices and remaining questions into the SOLIDWORKS sketch/features, macros/manual steps and verification record. Use the preview's parameter file as a reference, not as an automatic CAD import: no conversion to SLDPRT/STEP/DXF is included.

## Scope, provenance and limits

This integration vendors the unmodified `kit/iso-kit.mjs` from [Anatomy](https://github.com/wheresryan22/anatomy/tree/1482e8469b0a9e0d8cc18ea2740a01423d29ae80), inspected2026-10-27, plus its original [MIT license](../vendor/anatomy/LICENSE), copyright2026 Ryan. Root SKILL.md, README, kit API and verification guidance were inspected as references. The original outline renderer and CAD-specific workflow adapt the parts-first, single-model and isometric principles; upstream's unrelated40-part minimum, invented explanatory objects, restrictions on labels and community publishing are not imported. See [third-party notices](../THIRD_PARTY_NOTICES.md).

The bundled subset supplies solid shaded SVG projection, not all of Anatomy. It omits WebGL, beta live3D rotation, React components, print/PDF pipelines, gallery publishing and full geometry audits. Boxes and vertical cylinders are envelope approximations: no booleans, holes, material simulation, true interference, tolerance or physical-fit proof. A view can look plausible despite an engineering conflict. Rendering is separate from CAD creation and from visual inspection; report which checks actually ran. If browser inspection is unavailable, deliver generated source/artifacts with visual QA explicitly pending.
