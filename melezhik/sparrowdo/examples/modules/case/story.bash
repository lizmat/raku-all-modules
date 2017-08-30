case=$(story_var case)
opts=$(config opts)
echo run case $case ...

sparrowdo --sparrowfile=$project_root_dir/$case/sparrowfile --no_sudo --local_mode --format=production

