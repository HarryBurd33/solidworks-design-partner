# Verify direct access before CAD changes

1. Inventory connected tools and supported capabilities. A live Windows session must be independently reachable; a skill, stdio server on another machine, upstream demo, mock backend, or file listing alone does not prove that.
2. Read the intended SOLIDWORKS session version, active document identity/path/type, configuration, revision/dirty state and relevant model information. Match the user's target. Distinguish document inspection from simply reading its filename.
3. Verify the required inspect, sketch/feature/edit, rebuild, save-copy and export methods. Record unsupported steps. Confirm templates, add-ins and a writable destination only when needed. Use documentation for that installed version.
4. Preserve unsaved/existing work and prefer an isolated new document or copy. Describe a concrete change and verification sequence before executing. For updates, recheck target identity/revision just before mutation; do not switch to whatever happens to be active.
5. Execute the intended operations through the verified interface. Check returned objects/results and useful error details at each dependency boundary. Stop on failure and retain evidence. Rebuild then inspect dimensions/features/body counts; save only to a collision-safe agreed path. Verify actual native/export files and scope.
6. After timeouts or connection loss, reconcile Windows process identity, open documents, dirty state and filesystem outcomes before rerunning. Do not infer cancellation or success. Preserve partial work and provide source/manual continuation where useful.

For assemblies, include component revisions/configurations, mate status, intended degrees of freedom, motion envelope and relevant interference. For drawings, include linked model/configuration, scale, sheet/template, dimension/tolerance and export checks. Do not add deliverables the user did not request.

If direct access is absent, use macro source or manual guidance. Discuss integration setup as separate scoped work only when needed; do not install servers or remote infrastructure as an implicit prerequisite.
