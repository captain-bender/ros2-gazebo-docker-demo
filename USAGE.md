# Usage Guide

Everything below runs in a terminal **inside the container**. For setup, see the [README](./readme.md).

## Contents

- [Creating Your First Package](#creating-your-first-package)
- [Working with Gazebo Fortress](#working-with-gazebo-fortress)
- [Gazebo–ROS Bridge](#gazeboros-bridge)
- [Common ROS 2 Commands](#common-ros-2-commands)
- [Common Gazebo Commands](#common-gazebo-commands)
- [Performance Tips](#performance-tips)

## Creating Your First Package

```bash
# Navigate to the source directory (= workspace/ on Windows)
cd /root/ros2_ws/src

# Create a Python package with a starter node
ros2 pkg create --build-type ament_python --node-name my_node my_robot_package --dependencies rclpy

# Or a C++ package with a starter node
ros2 pkg create --build-type ament_cmake --node-name my_node my_robot_cpp --dependencies rclcpp

# Build the workspace
cd /root/ros2_ws
colcon build

# Source the workspace
source install/setup.bash

# Run your node (prints "Hi from my_robot_package.")
ros2 run my_robot_package my_node
```

> Always run `colcon build` from `/root/ros2_ws`, not from `src`. New terminals source the workspace automatically once it has been built.

## Working with Gazebo Fortress

```bash
# Launch an empty world
ign gazebo empty.sdf

# Launch the shapes demo world
ign gazebo shapes.sdf

# Launch with verbose output (debugging)
ign gazebo -v 4 shapes.sdf

# Launch through a ROS 2 launch file (no topics are bridged)
ros2 launch ros_gz_sim gz_sim.launch.py gz_args:="shapes.sdf"

# List models available on Gazebo Fuel
ign fuel list -t model
```

## Gazebo–ROS Bridge

Gazebo and ROS 2 have separate topic systems. `gz_sim.launch.py` starts Gazebo but does **not** bridge any topics; bridges are created explicitly with `ros_gz_bridge`.

```bash
# Terminal 1: launch a world
ros2 launch ros_gz_sim gz_sim.launch.py gz_args:="shapes.sdf"

# Terminal 2: bridge the clock (Gazebo → ROS 2)
ros2 run ros_gz_bridge parameter_bridge "/clock@rosgraph_msgs/msg/Clock[ignition.msgs.Clock"

# Terminal 3: check it
ros2 topic echo /clock
```

Bridge syntax: `/topic@ROS_type<direction>Gazebo_type`

| Symbol | Direction |
|---|---|
| `[` | Gazebo → ROS 2 |
| `]` | ROS 2 → Gazebo |
| `@` | Both directions |

Keep the argument in quotes, because `[` and `]` are special characters in bash.

### Spawning a Model

```bash
# -world must match the name of the running world
# (shapes.sdf → "shapes", empty.sdf → "empty")
ros2 run ros_gz_sim create -world shapes -name my_model -file /path/to/model.sdf
```

## Common ROS 2 Commands

```bash
# List nodes
ros2 node list

# List topics
ros2 topic list

# Echo a topic
ros2 topic echo /topic_name

# Show topic info
ros2 topic info /topic_name

# Run rqt (graphical tools)
rqt

# View TF tree (writes frames.pdf in the current directory)
ros2 run tf2_tools view_frames
```

## Common Gazebo Commands

```bash
# Get help
ign gazebo --help

# Run the simulation server only (no GUI)
ign gazebo -s shapes.sdf

# Run the GUI client only (connects to a running server)
ign gazebo -g

# List Gazebo topics
ign topic -l

# Echo a Gazebo topic
ign topic -e -t /topic_name

# List Gazebo services
ign service -l
```

## Performance Tips

- **Headless mode:** run `ign gazebo -s <world>` for simulation only and visualise with RViz2.
- **Split server and GUI:** run the server with `-s` and the GUI separately with `-g`, so you can close the GUI without stopping the simulation.
- **Optimise models:** use simpler meshes and lower sensor update rates.
- **Allocate resources:** Docker Desktop → Settings → Resources (4 GB+ RAM recommended).
