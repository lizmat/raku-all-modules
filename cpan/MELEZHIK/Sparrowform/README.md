# Synopsis

[Sparrowdo](https://github.com/melezhik/sparrowdo) provision for [Terraform](https://www.terraform.io) backed instances.

# Install

    $ zef install Sparrowform

# Limitations

Currently only ***ssh instances with public IPs are supported*** ( usually is what one has when deploy aws ec2 instances with public IPs ).
Ping me if you need more flavors/ways support.

# Usage

## Write some Terraform scenarios and deploy some instances

    $ terraform apply

## Create Sparrowodo scenarios, one per instance

Scenarios should be named as `$terrafrom-instance-type.$terraform-instance-ID.sparrowfile`

    $ nano aws_instance.example.sparrowfile
    $ nano aws_instance.example2.sparrowfile
    $ nano aws_instance.example3.sparrowfile
    # ...

See also [Sparrowdo one liners option](#using-sparrowdo-one-liners-instead-of-scenarios)
on how to run sparrowdo tasks/modules not scenarios.

## Run Sparrowdo provision

This command will run Sparrowdo scenarios for all instances for which files `$terrafrom-instance-ID.sparrowfile` exist:

    $ sparrowform

## Handling ssh connections

You may pass ssh connection parameters by specifying [sparrowdo cli](https://github.com/melezhik/sparrowdo#sparrowdo-client-command-line-parameters) parameters:

    $ sparrowform --ssh_user=ec2-user --ssh_private_key=/path/to/ssh.key

## Using [sparrowdo one liners](https://github.com/melezhik/sparrowdo#--module_run) instead of scenarios:

    # install Nginx on all instances:
    $ sparrowform --module_run=Nginx

    # check if Nginx alive on all instances:
    $ sparrowform --task_run=bash@command='"ps uax|grep nginx"'

    # install packages
    $ sparrowform --task_run=package-generic@list="'nano mc'"

## Default Sparrowdo scenario

If you don't want bother with creating scenarios for every instance, you may choose to defined _default_ scenario.

Create scenario named `sparrowfile`:


    $ nano sparrowfile

    bash "apt-get update";

So, these instances which do not have a related Sparrowdo scenarios files will use this _default_ scenario.

## Debugging

If something goes awry ... Enable SPF_DEBUG variable to see internal output:

    $ SPF_DEBUG=1 sparrowform

## Dry run

If you only want to see which instances would be deployed, run with  SPG_DRYRUN enabled:

    $ SPF_DRYRUN=1 sparrowform

# Author

Alexey Melezhik


# See also

* [Sparrowdo](https://github.com/melezhik/sparrowdo)
* [Terraform](https://www.terraform.io)
