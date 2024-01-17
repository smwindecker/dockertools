# dockertools

1. create project description with `holepunch::write_compendium_description()` 
2. write local dockerfile with `dockertools::write_local_dockerfile()`
3. build local dockerfile with `dockertools::build_local_dockerfile()`
if you would like to track the build, run build -t tagname . in terminal 
4. run local dockerfile with `dockertools::run_local_dockerfile()`

after happy with project: 
5. push local dockerfile to dockerhub with `dockertools::pull_push_local_dockerfile()` 
6. write binder dockerfile with `dockertools::write_binder_dockerfile()`
7. use `holepunch::generate_badge()` to create binder badge and paste into readme
8. push repo to github

Note, you can also pull a built image from dockerhub with `dockertools::pull_push_local_dockerfile()` 

