from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    return LaunchDescription([
        Node(
            package='subscriber_node',
            executable='subscriber_node',
            name='subscriber_node',
            output='screen',
        ),
    ])
