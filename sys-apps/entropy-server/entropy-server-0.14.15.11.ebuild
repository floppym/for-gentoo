# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/entropy/tags/${PV}"

DESCRIPTION="Official Sabayon Linux Package Manager Server Interface (tagged release)"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}"/trunk

DEPEND="~sys-apps/entropy-${PV}"
RDEPEND="${DEPEND}"

src_compile() {
	einfo "nothing to compile"
}

src_install() {

	dodir /usr/$(get_libdir)/entropy/server

        # copy configuration
        cd ${S}/conf
        dodir /etc/entropy
        insinto /etc/entropy
        doins activator.conf
        doins reagent.conf
        doins server.conf.example

	packages="reagent activator"
	inspackages="reagent activator server_reagent.py server_activator.py entropy-system-daemon server_query.py"
	cd ${S}/server
	insinto /usr/$(get_libdir)/entropy/server
	for package in ${inspackages}; do
		doins ${package}
	done

	cd ${S}
	for package in ${packages}; do
		echo '#!/bin/sh' > ${package}
		echo 'cd /usr/'$(get_libdir)'/entropy/server' >> ${package}
		echo 'python '${package}' "$@"' >> ${package}
		exeinto /usr/sbin
		doexe ${package}
	done

}
