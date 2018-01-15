.. Platform documentation master file, created by
   sphinx-quickstart on Tue Nov 14 12:50:26 2017.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to Platform's documentation!
====================================

Here you'll find Platform's documentation. Tool for quickly define and launch experimental architectures in a new layout where your software will sit and serve others.

.. uml::

   @startuml
   node system1
   node system2
   node system3
   node system4
   node system5
   system1 -- system2
   system1 .. system3
   system1 ~~ system4
   system1 == system5
   @enduml

.. toctree::
   :maxdepth: 3
   :caption: User Documentation

   overview
   getting_started
   advanced_configurations
   specifications
   host_configurations


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
