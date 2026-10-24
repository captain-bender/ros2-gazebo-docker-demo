# ROS 2 Humble with Gazebo Fortress - Docker Development Environment

A complete Docker-based development environment for ROS 2 Humble with Gazebo Fortress (the new Gazebo), optimized for Windows 11 with VS Code integration.

## Prerequisites

- Windows 11
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (with WSL2 backend)
- [VcXsrv Windows X Server](https://sourceforge.net/projects/vcxsrv/)
- [Visual Studio Code](https://code.visualstudio.com/)
- VS Code Extension: [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Features

- **ROS 2 Humble Desktop Full** - Complete ROS 2 installation
- **Gazebo Fortress** - Next-generation Gazebo simulator (formerly Ignition Gazebo)
- **ROS-Gazebo Bridge** - Seamless ROS 2 ↔ Gazebo integration
- **RViz2** - 3D visualization tool
- **Full Development Tools** - Git, CMake, GDB, Python linting/formatting
- **VS Code Integration** - Seamless development experience with IntelliSense

## Quick Start
Your ROS 2 packages go in workspace/ on Windows. Inside the container it appears as /root/ros2_ws/src.

### 1. Setup X Server (VcXsrv)

1. Launch **XLaunch** from Start menu (or install from [SourceForge](https://sourceforge.net/projects/vcxsrv/))
2. Configure settings:
   - Display: **Multiple windows**, Display number: **0**
   - Client startup: **Start no client**
   - Extra settings: **Disable access control** (Important!)
3. Click Finish
4. **Keep VcXsrv running** (you'll see it in system tray)
5. Select to save the configuration, and next time double-click to the config file in order to start automatically.

### 2. Build Docker Image
```bash
docker build -f Dockerfile.fortress -t ros2-humble-gazebo-fortress:dev .
```

### 3. Start the container
**Option A (recommended): VS Code**
1. Open this folder in VS Code
2. Press `F1` → **Dev Containers: Reopen in Container**
3. The first build takes several minutes. After that, VS Code reuses the same container.

**Option B: terminal only**
Run `run_ros2_gazebo_dev.ps1` from this folder (see the note below). Exit with `Ctrl+D`.
Next time, start and stop it from Docker Desktop, or attach to it from VS Code's Remote Explorer.

> Use one option or the other. To switch, first remove the old container:
> `docker rm -f ros2_humble_gazebo_dev`

> Run it from the repository folder:
> ```powershell
> cd path\to\ros2-gazebo-docker-demo
> powershell -ExecutionPolicy Bypass -File .\run_ros2_gazebo_dev.ps1
> ```
> This allows the script to run for this one call only; it doesn't change any system settings.

## Usage

### Testing the Setup

Open a terminal in VS Code and test:
```bash
# Test X server connection
xclock

# Launch RViz2
rviz2

# Launch Gazebo Fortress (GUI)
ign gazebo

# Check Gazebo version
ign gazebo --version
```

### Creating Your First Package
# Navigate to the source directory
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

### Working with Gazebo Fortress
```bash
# Launch empty world
ign gazebo empty.sdf

# Launch with shapes demo
ign gazebo shapes.sdf

# Launch with verbosity (debugging)
ign gazebo -v 4

# List available fuel models
ign fuel list -t model

# Launch with ROS 2 integration
ros2 launch ros_gz_sim gz_sim.launch.py

# Launch specific world with ROS 2
ros2 launch ros_gz_sim gz_sim.launch.py gz_args:="shapes.sdf"
```

### Gazebo-ROS Bridge

`gz_sim.launch.py` starts Gazebo but does **not** bridge any topics.
Bridges are created explicitly with `ros_gz_bridge`.

```bash
# Terminal 1: launch a world
ros2 launch ros_gz_sim gz_sim.launch.py gz_args:="shapes.sdf"

# Terminal 2: bridge the clock (Gazebo → ROS 2)
ros2 run ros_gz_bridge parameter_bridge "/clock@rosgraph_msgs/msg/Clock[ignition.msgs.Clock"

# Terminal 3: check it
ros2 topic echo /clock
```

Bridge syntax: `/topic@ROS_type<direction>Gazebo_type`, where
`[` = Gazebo → ROS, `]` = ROS → Gazebo, `@` = both directions.

```bash
# Spawn a model into the running world.
# -world must match the world name (shapes.sdf → "shapes", empty.sdf → "empty")
ros2 run ros_gz_sim create -world shapes -name my_model -file /path/to/model.sdf
```

### Common Ignition Commands
```bash
# Launch Gazebo GUI
ign gazebo

# List running simulations
ign gazebo -l

# Get help
ign gazebo --help

# Launch GUI client only (connect to running server)
ign gazebo -g

# Service list
ign service -l

# Topic list
ign topic -l

# Echo a topic
ign topic -e -t /topic_name
```

### Common ROS 2 Commands
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

# View TF tree
ros2 run tf2_tools view_frames
```

## Performance Tips

- **Headless mode**: Run `ign gazebo -s` for simulation only, visualize with RViz2
- **Reduce GUI load**: Use `-g` flag to run GUI client separately
- **Optimize models**: Use simpler meshes and reduce sensor update rates
- **Allocate resources**: Docker Desktop → Settings → Resources (4GB+ RAM recommended)

## License

This project is provided as-is for educational and development purposes.

## Contributing

Feel free to submit issues and enhancement requests!