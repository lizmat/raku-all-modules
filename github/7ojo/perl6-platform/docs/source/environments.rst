Environments
============

Environment File
----------------

File Type: YAML

File Name: environment-name.yml

.. list-table:: Top level definitions under environment file
   :widths: 15, 15, 200
   :header-rows: 1

   * - Key
     - Value
     - Description
   * - type
     - environment | *string*
     - Describes what kind of definition file is this
   * - name
     - *string*
     - Informative purposes only. Used on graphical user interfaces in the future
   * - desc 
     - *string*
     - Informative purposes only. Describe your environment.
   * - *relative/path/to/your/project*
     - *hash*
     - Define project configuration. Identical to *project.yml* definitions. Values here override *project.yml* definitions.

