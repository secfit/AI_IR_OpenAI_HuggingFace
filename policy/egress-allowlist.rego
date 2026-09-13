# ASCB-1 / Control C2: Destination-scoped egress allow-listing
#
# Draft OPA/Rego policy for any proxying/caching service (e.g. Artifactory,
# a package-manager mirror) that itself has outbound internet access on
# behalf of sandboxed jobs. The point of this control is that the SANDBOX
# not having direct internet access is insufficient if the proxying
# service it talks to has unrestricted outbound access reachable via SSRF.
#
# Illustrative starting point, not production-hardened.

package ascb1.egress_allowlist

import future.keywords.if
import future.keywords.in

default allow_fetch := false

# The proxying service may only fetch destinations that are explicitly
# allow-listed FOR THE SPECIFIC TASK, not a blanket allow-list for the
# service as a whole.
allow_fetch if {
    some allowed in data.ascb1.task_egress_allowlist[input.task_id]
    fetch_host := input.request.destination_host
    fetch_host == allowed.host
    input.request.destination_port == allowed.port
    startswith(input.request.destination_path, allowed.path_prefix)
}

# Explicitly deny fetches to internal/private address ranges regardless of
# any allow-list entry — this closes the specific SSRF pattern used in the
# incident (proxying service induced to fetch internal metadata/services).
deny_internal[msg] if {
    net.cidr_contains("169.254.0.0/16", input.request.destination_ip)  # cloud metadata
    msg := "ASCB1-C2 violation: attempted fetch of cloud instance metadata via proxy"
}

deny_internal[msg] if {
    private_ranges := {"10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"}
    some cidr in private_ranges
    net.cidr_contains(cidr, input.request.destination_ip)
    not input.request.destination_host in data.ascb1.internal_service_allowlist
    msg := sprintf("ASCB1-C2 violation: attempted fetch of internal address %s not on allowlist", [input.request.destination_ip])
}

# Example input shape:
# {
#   "task_id": "exploitgym-run-441",
#   "request": {
#     "destination_host": "pypi.org",
#     "destination_ip": "151.101.0.223",
#     "destination_port": 443,
#     "destination_path": "/simple/requests/"
#   }
# }
