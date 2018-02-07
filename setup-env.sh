source /opt/ros/lunar/setup.bash
source ~/catkin_ws/devel/setup.bash
source ~/catkin_py3/devel/setup.bash
workon tf-python3
export PYTHONPATH=$PYTHONPATH:$HOME/catkin_py3/src/ras_jetson_py3/models/research/:$HOME/catkin_py3/src/ras_jetson_py3/models/research/slim/
export PYTHONPATH=/usr/local/lib/python3.5/dist-packages:$PYTHONPATH
