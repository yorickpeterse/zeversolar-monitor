FROM registry.fedoraproject.org/fedora-minimal:43

RUN microdnf --assumeyes --quiet install nmap-ncat fish curl
ADD monitor.fish /monitor.fish
CMD ["/usr/bin/fish", "monitor.fish"]
