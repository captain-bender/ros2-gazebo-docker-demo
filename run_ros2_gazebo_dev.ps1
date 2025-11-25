docker run -it `
  -e DISPLAY=host.docker.internal:0.0 `
  -e LIBGL_ALWAYS_INDIRECT=0 `
  --name ros2_humble_gazebo_dev `
  -v ${PWD}/workspace:/root/ros2_ws/src `
  ros2-humble-gazebo-fortress:dev