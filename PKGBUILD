# Maintainer: Pierre Schmitz <pierre@archlinux.de>

pkgname=pkgstats
pkgver=2.4.2
pkgrel=2
pkgdesc='Submit a list of installed packages to the TOS project'
url='https://stats.odex.be/'
arch=('any')
license=('GPL')
depends=('bash' 'curl' 'pacman' 'sed' 'coreutils' 'systemd' 'grep')
makedepends=('git')
checkdepends=('bash-bats' 'shellcheck')
source=("${pkgname}::git+https://github.com/ODEX-TOS/pkgstats-cli.git")
sha1sums=('SKIP')
validpgpkeys=('SKIP')

pkgver() {
    cd "$pkgname"
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

check() {
	cd ${srcdir}/${pkgname}

	make test
}

build() {
	cd ${srcdir}/${pkgname}

	make
}

package() {
	cd ${srcdir}/${pkgname}

	make DESTDIR=${pkgdir} install
}
