# Evaluation method

Date:2026-10-26 America/Denver. Frozen cases: cases.json revision1; the private freeze hash was recorded before candidate evaluation. All measurements and tool contexts are synthetic. No Windows or CAD tool execution occurred.

Baseline: actual model responses from the foundation-research agent after reading a simple direct prompt (“Act as a helpful SOLIDWORKS design assistant. Help refine designs and provide appropriate modeling instructions or macro source. Use available capabilities honestly.”). The agent had already researched the domain. An initial nested-JSON filtering mistake exposed expected criteria/rubric to that agent. It reported the exposure; no candidate files were read. Consequently the baseline is contaminated and not blind, and comparison cannot establish a causal improvement.

Candidate execution and independent reviews are retained in the accompanying response, grade and review files. Native agents use inherited configured model settings; exact active model/effort and task-attributable tokens, subscription usage and API dollars were not available. No separate paid API was used. The model contexts and roles differ; no clean same-context/model causal claim is warranted. Text behavior, static resources, live CAD and physical tests are separate evidence categories.

Privacy: the published candidate response copy replaces the local absolute build-root prefix with `<REPO_ROOT>/`. Response text otherwise remains unchanged. Raw original hashes in model-grades.json identify the private execution artifact; the public redacted artifact has a separate file hash. No private path is shipped.
