Object Detector using Python 3
=========================================

**Note:** This assumes you have set up the NVidia Jetson as is described in the
*jetson* repository README.

If you want to try out TensorFlow with Python 3 rather than Python 2, you'll
probably want to set up everything in a separate workspace and overlay that on
the previous one so you don't mess up all the Python 2 packages.

Setup virtual environment for Python 3:

    pip3 install --user virtualenvwrapper
    export WORKON_HOME=~/Envs
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    source ~/.local/bin/virtualenvwrapper.sh
    echo "export WORKON_HOME=~/Envs" >> ~/.bashrc
    echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bashrc
    echo "source ~/.local/bin/virtualenvwrapper.sh" >> ~/.bashrc
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc

    mkvirtualenv -p python3 --system-site-packages tf-python3
    workon tf-python3
    git clone https://github.com/jetsonhacks/installTensorFlowJetsonTX.git
    cd installTensorFlowJetsonTX/TX2/
    pip install tensorflow-1.3.0-cp35-cp35m-linux_aarch64.whl
    pip install catkin_pkg rospkg pillow
    deactivate

If using Python 3.5, as
[described](https://devtalk.nvidia.com/default/topic/1027449/jetson-tx2/run-tensorflow-1-3-on-tx2-stuck/post/5226615/)
you need cuDNNv7. Download the .deb from
[https://developer.nvidia.com/nvidia-tensorrt3rc-download](https://developer.nvidia.com/nvidia-tensorrt3rc-download).
Then:

    sudo dpkg -i nv-tensorrt-repo-ubuntu1604-rc-cuda8.0-trt3.0-20170922_3.0.0-1_arm64.deb
    sudo apt update
    sudo apt install tensorrt python3-dev

Make ROS work with Python 3:

    sudo apt-get install python3-empy # Errors building messages without this

Download this repository.

    mkdir -p ~/catkin_py3/src/
    cd ~/catkin_py3/src/
    git clone https://github.com/WSU-RAS/jetson-py3.git ras_jetson_py3

Clone the *vision_opencv* package to make *cv_bridge* work with Python 3:

    git clone https://github.com/WSU-RAS/vision_opencv.git

Now build OpenCV 2 for Python 3
([src](https://www.pyimagesearch.com/2016/10/24/ubuntu-16-04-how-to-install-opencv/)).
Note you'll need roughly 12 GiB of disk space for this. If you don't have that,
then rsync a bunch of your files off the Jetson, delete them, and then copy
them back after you do the `make install`. Also, make sure you run `sudo
~/jetson_clocks.sh` before doing this so it'll compile faster.

    sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
        libxvidcore-dev libx264-dev libgtk-3-dev libatlas-base-dev gfortran python3-dev
    wget https://github.com/opencv/opencv/archive/3.3.1.zip -O opencv.zip
    wget https://github.com/opencv/opencv_contrib/archive/3.3.1.zip -O opencv_contrib.zip
    unzip opencv.zip
    unzip opencv_contrib.zip
    cd ~/opencv-3.3.1/
    mkdir build
    cd build
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.3.1/modules \
        -D PYTHON_EXECUTABLE=/usr/bin/python3 \
        -D BUILD_EXAMPLES=ON ..
    make -j6
    sudo make install
    sudo ldconfig

Now, if you do "import cv2" it'll still try to use the Python 2.7 version
provided in ROS, which will error. Thus, first try the version we just
installed. Before you use it, you need to:

    export PYTHONPATH="/usr/local/lib/python3.5/dist-packages:$PYTHONPATH"

which we will do in setup-env.sh before running the Python 3 object detection.

Make sure you have sourced the previous workspace before building, to make this
an overlay workspace:

    source /opt/ros/lunar/setup.bash
    source ~/catkin_ws/devel/setup.bash

Build everything:

    cd ~/catkin_py3
    workon tf-python3
    catkin_make -DFILTER=OFF -DPYTHON_EXECUTABLE=$(which python) -DPYTHON_VERSION=3

Finally, run TensorFlow with Python 3:

    cd ~/catkin_py3
    . src/ras_jetson_py3/setup-env.sh
    roslaunch ras_jetson_py3 object_detector.launch

Or, run components individually:

    roscore
    rosrun image_view image_view image:=/camera/rgb/image_raw
    rostopic echo /object_detector

    cd ~/catkin_py3
    . src/ras_jetson_py3/setup-env.sh
    rosrun ras_jetson_py3 object_detector.py \
        _graph_path:=~/networks/ssd_mobilenet_v1.pb \
        _labels_path:=~/networks/tf_label_map.pbtxt
