#! /usr/bin/env sh

main()
{

	# Create the docker instance
  docker run --privileged --name centos --entrypoint  init -v /sys/fs/cgroup:/sys/fs/cgroup:ro -d centos

  cd ../ && strun --root examples/ --param flavor=travis

}

main "$@"
