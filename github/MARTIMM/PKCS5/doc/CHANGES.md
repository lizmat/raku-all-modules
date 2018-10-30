
See [semantic versioning](http://semver.org/). Please note point 4. on that page: *Major version zero (0.y.z) is for initial development. Anything may change at any time. The public API should not be considered stable.*

* 0.1.6
  * Appveyor failed to load OpenSSL::Digest. This is a mistake in the dependencies part of META.info because it is in the package of OpenSSL. This is noticed on travis-ci which is hapily loading the stuff without hampering.
* 0.1.5
  * Changed readme doc
  * Appveyor tests added
* 0.1.4
  * Added tests from rfc6070
* 0.1.3
  * Changed terminology. PRF into CGH for cryptographic hash
* 0.1.1
  * Added pod doc.
* 0.1.0
  * Implemented derive() and derive-hex()
* 0.0.1 Setup
