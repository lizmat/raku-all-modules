#! /usr/bin/env sh

main()
{

	# Create the docker instance
  # docker run --privileged --name ubuntu --entrypoint  init -v /sys/fs/cgroup:/sys/fs/cgroup:ro -d ubuntu
  # docker run --name ubuntu --entrypoint init -v /sys/fs/cgroup:/sys/fs/cgroup:ro -d ubuntu
  docker run -t -d --name ubuntu ubuntu sh
  cd ../ && strun --root examples/ --param flavor=travis

}

main "$@"
