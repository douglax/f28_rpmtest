# fedora28 rpm test node  
A docker image to test rpm development



The containers created with this image will have ssh access so rpm can be installed and tested.

To create a container:
`docker run -d -P --name myrpmnode douglax/f28_rpmtest`

Check the port 22 is mapped to:
`docker port myrpmnode`

Check ip address of the node:
`docker inspect myrpmnode`

Connect to the container via ssh:

`ssh developr@<container_ip_address>`
or
`ssh developr@<host_ip_address> -p <mapped_port>`

password is _developr_ 
root password is _devroot_
