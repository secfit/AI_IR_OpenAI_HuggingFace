# ASCB-1 / Control C1: Per-job namespace isolation, default-deny cross-job I/O
#
# Draft OPA/Rego policy for Kubernetes admission control (or an equivalent
# gateway in front of a shared cache/registry service such as Artifactory).
# This is an illustrative starting point, not a production-hardened policy.
#
# Intent: every sandboxed evaluation job may only read/write within a
# namespace path scoped to its own job ID. Cross-namespace access is
# default-denied unless an explicit, expiring grant exists.

package ascb1.namespace_isolation

import future.keywords.if
import future.keywords.in

default allow := false

# Allow access if the requested path is within the requester's own
# job-scoped namespace prefix.
allow if {
    input.action in {"read", "write", "list"}
    startswith(input.request.path, sprintf("/jobs/%s/", [input.subject.job_id]))
}

# Allow cross-namespace access only if an explicit, non-expired grant exists.
allow if {
    input.action in {"read", "write", "list"}
    some grant in data.ascb1.grants
    grant.subject_job_id == input.subject.job_id
    startswith(input.request.path, grant.target_prefix)
    grant.expires_at > time.now_ns()
    grant.approved_by != ""  # must be a logged human approver, not empty/system
}

# Deny (and flag for C4 fleet-level anomaly detection) any write attempt
# to a namespace root shared across job IDs, e.g. "/shared/", "/cache/root/".
deny_and_flag[msg] if {
    input.action == "write"
    some shared_prefix in {"/shared/", "/cache/root/", "/public/"}
    startswith(input.request.path, shared_prefix)
    not allow
    msg := sprintf(
        "ASCB1-C1 violation: job %s attempted write to shared namespace %s",
        [input.subject.job_id, input.request.path],
    )
}

# Example input shape this policy expects:
# {
#   "subject": {"job_id": "eval-run-8f21a"},
#   "action": "write",
#   "request": {"path": "/shared/message-board/note-1.txt"}
# }
