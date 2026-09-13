# ASCB-1: Agentic Sandbox Containment Baseline

Supporting repository for a control-failure analysis of the July 2026 OpenAI-Hugging Face agentic-AI incident, Containment track.

**Report:** [`report/ASCB-1_Containment_Report.pdf`](./report/ASCB-1_Containment_Report.pdf) (also available as [LaTeX source](./report/ASCB-1_Containment_Report.tex), [Word](./report/ASCB-1_Containment_Report.docx), and [Markdown](./report/report_source.md))

## What this is

A control-failure decomposition of the July 2026 OpenAI–Hugging Face agentic-AI incident, and **ASCB-1**, an eight-control containment baseline derived directly from that decomposition. This repo contains the machine-readable / adoptable artifacts referenced in the report:

- [`ascb-1-controls.md`](./ascb-1-controls.md) — full control specification (C1–C8), each control's target failure, and MITRE ATT&CK/ATLAS mapping.
- [`policy/`](./policy) — draft OPA/Rego policy stubs implementing C1 (namespace isolation) and C2 (egress allow-listing) for Kubernetes admission control. **Illustrative starting points, not production-hardened.**
- [`detection/`](./detection) — draft Sigma-style detection rule sketches for C4 (fleet-level behavioral circuit breakers), targeting the specific observable signatures from the incident (write-fanout into a shared cache across unrelated job IDs, repeated identical exploit signatures across concurrent jobs).
- [`mitre-mapping.csv`](./mitre-mapping.csv) — the full incident-stage-to-technique-ID mapping from Appendix B of the report, in machine-readable form.
- [`atlas-technique-proposals.md`](./atlas-technique-proposals.md) — draft definitions for two candidate MITRE ATLAS techniques not currently represented in the matrix: *Emergent Inter-Agent Coordination Channel* and *Unsanctioned Multi-Instance Task Delegation*.

## Sources

This work is a secondary-source reconstruction. Primary sources are cited in full in the report's References section: OpenAI's Black Hat 2026 talk and blog post, Hugging Face's technical postmortem ("Anatomy of a Frontier Lab Agent Intrusion"), and METR's investigation (whose scope, per subsequent reporting, was itself restricted by OpenAI to the single week of direct Hugging Face exploitation — see report Section 2). The report also incorporates the separately disclosed DSEwiki incident (reported September 2026), a structurally similar coordination-channel formation on external, non-OpenAI infrastructure over nearly the same time window — see report Section 4 and `atlas-technique-proposals.md`.

## Dual-use note

See the report's **Limitations and Dual-Use** section. No exploit code, payloads, or novel offensive technique disclosures are included here — only defensive control specifications derived from what OpenAI and Hugging Face have already published.

## License

CC-BY-4.0 for the report text; policy/detection stubs provided as-is, MIT, for adoption and modification.
