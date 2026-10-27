# Release 1.0.0

The release ZIP contains exactly the nine files in [release-manifest.json](../release-manifest.json), under a single `solidworks-design-partner/` directory. Each installed release file and ZIP member was compared with the source SHA-256. The local managed-install receipt is administrative and is not bundled.

ZIP SHA-256: `22f4411de0866ba30252d8a3acc1784e011cbb1fb02f4d4a5f0bc528c263e47d`.

The public repository tag `v1.0.0` identifies the release source commit. The publication procedure verifies the remote branch/tag and every remote release file against the manifest, then downloads the uploaded ZIP and compares its hash. Local delivery records retain the verified commit and actual results; release metadata provides the downloadable asset. No private checkpoint/build state or unrelated parent repository history is included.

See [validation](VALIDATION.md) for actual static/model evidence and unavailable Windows/CAD tests. Original bundled files are MIT-licensed, copyright 2026 HarryBurd33; external references retain their own terms.
