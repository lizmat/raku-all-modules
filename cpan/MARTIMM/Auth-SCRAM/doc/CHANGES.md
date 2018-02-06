## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on
that page: *Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable.*

* 0.4.6
  * Appveyor test implementation
* 0.4.5
  * Typo in Server pod documentation
* 0.4.4
  * Removed todo from Server.pm6
  * Completed documentation
* 0.4.3
  * Pod doc using pod-render. pod.css is thrown away.
  * Managed to use multi BUILDs so interface is slimmed down and less checks are needed.
* 0.4.2
  * Pod Documentation
  * Change of pod.css
* 0.4.1
  changed the location of decoding and encoding the username string to translate
  ',' and '=' from and to '=2D' and '=3D'.
* 0.4.0
  * Normalization with rfc3454 rfc7564 (stringprep). saslPrep rfc4013 rfc7613. These rfc's are obsoleted by rfc's forming the PRECIS framework. The perl6 module used is Unicode::PRECIS.
  * Skip-sasl-prep() function is deprecated because it is not ok to skip normalization of strings.
  * The interfaces of some methods had to be changed in order to be able to select the proper normalization profiles. These, however, are initialized with proper defaults.
* 0.3.2
  * Refactoring code to have hidden methods. In current setup it was not possible. This failed because of role usage, so keep it the same.
  * documentation.
* 0.3.1
  * Bugfixes
  * Some server errors can be detected and returned
* 0.3.0
  * Server side code implemented. Lack error return if there are any.
* 0.2.0
  * Refactored code into server and client parts. User interface is unchanged.
* 0.1.1
  * renamed clean-up() optional method into cleanup().
* 0.1.0
  * mangle-password and clean-up in user objects are made optional. Called when defined.
* 0.0.2
  * Add server verification
* 0.0.1 Setup
