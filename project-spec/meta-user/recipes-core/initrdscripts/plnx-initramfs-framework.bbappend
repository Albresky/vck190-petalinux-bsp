# Install a custom rescue module into the initramfs.
# This module runs as 98-rescue (just before 99-finish) and:
#   - overrides fatal() to launch sh via setsid+cttyhack so Ctrl+C works
#   - creates ~/.ssh/ so dropbear can save host keys (fixes scp)

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://rescue"

do_install:append() {
    install -m 0755 ${WORKDIR}/rescue ${D}/init.d/98-rescue
}

FILES:${PN}-base += "/init.d/98-rescue"
