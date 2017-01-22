case=$(story_var case)
opts=$(config opts)
echo run case $case ...

perl6 -I$project_root_dir/../lib $project_root_dir/../bin/sparrowdo \
--host=127.0.0.1 \
--sparrowfile=$project_root_dir/$case/sparrowfile \
$opts

