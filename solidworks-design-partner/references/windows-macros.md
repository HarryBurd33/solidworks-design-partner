# Windows macro source, execution, and acceptance

Use this path when source can be authored but the intended Windows SOLIDWORKS session is unavailable to the agent. A Mac and a separate PC need a user-arranged transfer; this guide creates no remote connection. Generated source is not an executed macro or a CAD model.

## Confirm the environment

Record the installed SOLIDWORKS release/service pack and relevant edition, working part/assembly templates, language, and requested operations. Use API Help for that installed release. The included fixture targets the API surface documented by SOLIDWORKS 2024, including `FeatureExtrusion3` and `SaveAs3` (available since 2020 SP02). It is source reviewed, **not compiled or executed in Windows SOLIDWORKS**. Compatibility with a particular installation remains unverified.

VBA is the proposed minimal-dependency choice for in-application automation. The user needs the installed SOLIDWORKS VBA macro editor/runtime working; verify **Tools → Macro → New** opens the editor. No Python, downloaded add-in, or external runtime is required by this fixture. A newly created macro project may contain SOLIDWORKS type-library references even though this module uses late-bound `Object` variables. Resolve any `MISSING:` references using the installed release's libraries; do not download arbitrary replacements. VSTA/VB.NET/C# is a different project/build workflow with release-specific prerequisites. Choose it only when justified and verified.

The [official macro guide](https://help.solidworks.com/2021/english/api/sldworksapiprogguide/gettingstarted/solidworks_macros.htm) explains VBA and VSTA. Its 2021 release is a starting reference, not evidence of the user's installed version.

## Transfer and create a real runnable macro

1. Transfer [SmokePlate.bas](../examples/SmokePlate.bas) using the user's chosen file method. Keep the `.bas` extension visible in Windows Explorer. Inspect the transferred source; use an ordinary text editor, not a rich-text document. Transfer no credentials.
2. In the intended SOLIDWORKS Windows session, choose **Tools → Macro → New**. Choose a new `.swp` project filename in a writable folder. SOLIDWORKS creates the project and opens the VBA editor; exact menus may vary by release/language.
3. In the editor, remove the generated empty standard module or its `Sub main` before importing. Choose **File → Import File**, select `SmokePlate.bas`, and confirm the imported standard module is `SmokePlateModule`. Keep exactly one intended `Sub main` entry point to avoid running an empty or wrong procedure. Do not import this module twice.
4. Configure `TEMPLATE_PATH` to an existing `.prtdot` appropriate to this SOLIDWORKS release. Obtain its path from the installation's template settings or a known working template; no bundled template is assumed. Configure `OUTPUT_PATH` to a full, new `.SLDPRT` filename in an existing, writable folder. Blank paths deliberately fail preflight. The parent-directory check preserves drive roots such as `C:\` and checks directory attributes; unavailable or invalid paths stop before modeling. Use a fresh filename for every independent run.
5. Set `SKETCH_PLANE` to the exact existing plane name in that template, such as the localized equivalent of `Front Plane`. Use an ordinary part template without pre-existing solid geometry. Keep the fixture's synthetic dimensions at 80 × 40 × 3 mm for the acceptance test.
6. Choose **Debug → Compile** if offered; resolve syntax/reference errors before execution. Save the macro project with the editor's **File → Save** command. Return to SOLIDWORKS, choose **Tools → Macro → Run**, and select the saved `.swp` and `SmokePlateModule.main` if an entry-point choice is shown. Do not launch from an unrelated application or Mac VBA host.
7. Read the result dialog and VBA Immediate window (`Ctrl+G`) for the host revision, operation stage, and save error/warning bitmasks. Keep that evidence with the design brief. A completion dialog means the code's limited checks passed; independently inspect the model as described below.

Importing a `.bas` into an actual project and saving creates a runnable `.swp`. **Renaming text to `.swp` does not create a macro.** If importing is unavailable, paste only the code beginning with `Option Explicit` into one standard module of the genuine project; omit the exported `Attribute VB_Name` line and remove any duplicate entry point. [Microsoft's VBA File menu reference](https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/file-menu) documents module import.

## Fixture behavior and limits

`SmokePlate.bas` uses the SOLIDWORKS instance hosting the macro. It checks paths and an output collision before creating a **new** part, creates a rectangle on the configured plane, extrudes it, requests a rebuild, checks feature codes and one solid body, then saves a new native part. It neither intentionally edits nor closes pre-existing documents. A created new document becomes active; earlier documents remain open.

Constants are in millimeters. Each API length crosses an explicit boundary using `MM_TO_M = 0.001`: 80 mm → 0.08 m, 40 mm → 0.04 m, 3 mm → 0.003 m. API angular values, if added later, generally use radians. Document display units do not change API length units. See [API units](https://help.solidworks.com/2024/english/api/sldworksapiprogguide/Overview/Units.htm).

The rectangle is native, editable sketch geometry created at coordinates. This smoke fixture does **not** add production driving dimensions or fully constrain the sketch. Edit the source constants before an independent run, or add native sketch dimensions/relations deliberately afterward. A production design macro should expose named parameters, appropriate dimensions/relations, and a feature strategy matching its design intent. This fixture is not an enclosure generator.

A failed operation stops with its stage and error. The new document remains open for inspection and may be partially built, unsaved, or saved with an uncertain final verification outcome. No automatic cleanup, deletion, retry, or rollback hides that state. Reconcile it before running again.

The output collision guard runs both before modeling and immediately before save. `SaveAs3` itself can overwrite. Use a unique filename under the user's exclusive control; do not run concurrent writers against that path. The guard does not provide an operating-system atomic reservation. If the file already exists, inspect and preserve it; choose another name. Updating a prior model requires a separately designed, identity-checked update procedure, not this fresh-document fixture.

## Check the resulting model on Windows

Record each check as executed, user-reported, failed, or unexecuted, with the actual document/configuration and file path:

| Requirement | Acceptance evidence |
|---|---|
| Correct host and new target | Intended SOLIDWORKS release/service pack; new part title/path; earlier documents intact |
| Native feature structure | `SmokePlateProfile` sketch consumed by `SmokePlateExtrusion`; both editable; exactly one solid body |
| Dimensions | Measure two perpendicular rectangle edges as 80 and 40 mm, and extrusion depth as 3 mm; inspect native feature definition and geometry rather than inferring from a screenshot |
| Rebuild | Full rebuild succeeds; no feature errors or unexpected warnings; relevant configuration identified |
| Saved model | Save returned true with errors 0; warnings decoded/reviewed; nonempty `.SLDPRT` at the expected path; close only this fixture when appropriate, reopen it, and rebuild again |
| Rerun preservation | Running again with the same output path stops before a new model is created; original saved file and existing work remain intact |
| Export, only if requested | Correct active document/configuration and cleared selections; verified exporter/options/units; new noncolliding path; reopen/reimport and compare the requested geometry |

The macro checks return values and file presence, not the complete acceptance table. No STEP/STL/drawing export is performed by this fixture. Do not use an approximate bounding box as proof of exact dimensions. A screen image or a successful rebuild does not prove physical fit, strength, heat performance, or manufacturability. Assemblies additionally need intended component configurations, mates/motion, fit/interference and reference checks; perform those on the actual assembly when relevant.

For a requested export, choose the installed release's supported method and format-specific options. Verify the intended document is active, clear face/body selections to avoid exporting a subset, prevent overwrite, check Boolean/error/warning results, and inspect the resulting file. Reuse no export claim from the native save alone.

## Troubleshooting and uncertain runs

| Symptom | Next action |
|---|---|
| Macro editor unavailable | Verify the SOLIDWORKS installation's VBA components and organizational macro policy. Continue with manual modeling instructions while this is resolved. |
| Invalid macro or wrong entry point | Create a genuine `.swp`, import the module once, remove the empty duplicate `main`, compile and save. |
| `MISSING:` library or compile error | Verify installed-release references in the VBA editor; keep the source and exact error. This module needs no third-party library. |
| Template/plane selection failure | Confirm the `.prtdot` opens in this release and inspect its exact plane name; leave any new partial document open until reviewed. |
| No rectangle or no extrusion feature | Inspect the reported stage, selected plane/sketch, closed profile and returned objects. Do not save or claim a finished model merely because code ran. |
| Rebuild or feature code failure | Read the native **What's Wrong** detail and the versioned enum description; repair the geometry/constraints before acceptance. |
| Save failure or nonzero warnings | Check writable folder, collision, active target, permissions and error/warning enums. Preserve partial files and native documents until reconciled. |
| Timeout, disconnected controller, or unknown completion | Inspect the originating Windows process/session, open documents, logs, output file timestamps/content and rebuild state. A timeout is not proof that execution stopped. Do not duplicate an uncertain operation. |

If Windows is unavailable, retain source, parameters, design decisions, errors and the next check. Continue independent design work and provide manual stages. Request the specific Windows evidence needed next; do not build a remote-control service merely to recover this run.

## API references used for the source review

- [NewDocument](https://help.solidworks.com/2021/English/api/sldworksapi/SOLIDWORKS.Interop.sldworks~SOLIDWORKS.Interop.sldworks.ISldWorks~NewDocument.html): new document object, with failure checked.
- [CreateCornerRectangle, 2024](https://help.solidworks.com/2024/english/api/sldworksapi/solidworks.interop.sldworks~solidworks.interop.sldworks.isketchmanager~createcornerrectangle.html): six coordinates and segment-array result.
- [FeatureExtrusion3, 2024](https://help.solidworks.com/2024/english/api/sldworksapi/solidworks.interop.sldworks~solidworks.interop.sldworks.ifeaturemanager~featureextrusion3.html): 23 positional arguments, with blind depth in meters and returned feature checked.
- [GetNextFeature, 2024](https://help.solidworks.com/2024/english/api/sldworksapi/solidworks.interop.sldworks~solidworks.interop.sldworks.ifeature~getnextfeature.html): identify the sketch feature by its type and specific sketch object, not a guessed generated name.
- [GetErrorCode2](https://help.solidworks.com/2023/english/api/sldworksapi/SolidWorks.Interop.sldworks~SolidWorks.Interop.sldworks.IFeature~GetErrorCode2.html): feature code with a separate warning flag.
- [ForceRebuild3, 2024](https://help.solidworks.com/2024/english/api/sldworksapi/solidworks.interop.sldworks~solidworks.interop.sldworks.imodeldoc2~forcerebuild3.html): rebuild result is one check, not full geometric verification.
- [GetBodies2](https://help.solidworks.com/2022/English/api/sldworksapi/SOLIDWORKS.Interop.sldworks~SOLIDWORKS.Interop.sldworks.IPartDoc~GetBodies2.html): body-type and visibility arguments.
- [SaveAs3](https://help.solidworks.com/2021/English/api/sldworksapi/SolidWorks.Interop.sldworks~SolidWorks.Interop.sldworks.IModelDocExtension~SaveAs3.html): seven arguments, Boolean/error/warning handling, active-document/export selection and overwrite behavior. This is `IModelDocExtension.SaveAs3`, not the differently shaped `IModelDoc2.SaveAs3`.

These references were inspected as documentation, without copying example code. Some dynamic help pages returned only the site shell; indexed official page content supplied the signatures. Verify them against local API Help before a production run.
