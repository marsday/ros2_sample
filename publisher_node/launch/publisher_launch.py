from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    return LaunchDescription([
        Node(
            package='publisher_node',
            executable='publisher_node',
            name='publisher_node',
            output='screen',
        ),
    ])
