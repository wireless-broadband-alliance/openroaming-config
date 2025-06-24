## fail2ban configuration examples

RADIUS and RadSec endpoints may see too many failed connection attempts
due to unknown certificates, protocol errors, and incorrect shared secrets.
Some of them are caused by misconfiguration of the peers,
while some others could be potentially dangerous.
These connection failures are not only inflating the log files 
but also causing port blockage and/or high process load sometimes.
Some might be a sign of further elaborated attacks.

**[fail2ban](https://github.com/fail2ban/fail2ban)**
is an intrusion prevention daemon.
Many Linux distributions provide fail2ban package, allowing 
administrators to enable log-monitoring-based server protection
easily.
Here are some configuration example that would be useful 
for protecting OpenRoaming RadSec endpoints.

