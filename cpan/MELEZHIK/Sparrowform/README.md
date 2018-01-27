# Synopsis

[Sparrowdo](https://github.com/melezhik/sparrowdo) provision for [Terraform](https://www.terraform.io) backed instances.

[![asciicast](https://asciinema.org/a/158919.png)](https://asciinema.org/a/158919)

# Install

    $ zef install Sparrowform

# Limitations

Currently only ***ssh accessed instances with public IPs are supported*** ( aws ec2 / google compute instances with public IPs ).

Terrafrom resources supported:

* [aws_instances](https://www.terraform.io/docs/providers/aws/r/instance.html)
* [google_compute_instance](https://www.terraform.io/docs/providers/google/r/compute_instance.html)


Ping me if you need more Terraform resourses support.

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

## Terraform resources access 

Sparrowform exposes nice API to access Terraform internal guts inside Sparrowdo scenarios.
 
The function `tf-resources` returns Perl6 Array of all Terraform resources. 
Each elements consists of two elements, the first one holds resource identificator, the
second one holds resource data, represented as Perl6 Hash.

Here is usage example:

    $ cat sparrowfile 

    # let's insert all ec2 instances DNS names into ever instance's /etc/hosts file:
 
    use Sparrowform;
    
    my @hosts = (
      "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4",
      "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6"
    );
    
    for tf-resources() -> $r {
      my $rd = $r[1]; # resource data
      next unless $rd<public_ip>;
      next unless $rd<public_dns>;
      next if $rd<public_ip> eq input_params('Host');
      push @hosts, $rd<public_ip> ~ ' ' ~ $rd<public_dns>;
    }
    
    file '/etc/hosts', %(
      action  => 'create',
      content => @hosts.join("\n")
    );
        

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
