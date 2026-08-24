#include <chrono>
#include <functional>
#include <memory>

#include "rclcpp/rclcpp.hpp"
#include "common_functions/common_functions.hpp"
#include "sample_msgs/msg/sum_result.hpp"

using namespace std::chrono_literals;

class PublisherNode : public rclcpp::Node
{
public:
  PublisherNode() : Node("publisher_node"), n_(1)
  {
    publisher_ = this->create_publisher<sample_msgs::msg::SumResult>("sum_result", 10);
    timer_ = this->create_wall_timer(1s, std::bind(&PublisherNode::timer_callback, this));
  }

private:
  void timer_callback()
  {
    int a = n_;
    int b = n_ + 1;
    int result = common_functions::sum(a, b);

    auto msg = sample_msgs::msg::SumResult();
    msg.a = a;
    msg.b = b;
    msg.result = result;
    publisher_->publish(msg);

    RCLCPP_INFO(this->get_logger(), "Publishing: sum(%d, %d) = %d", a, b, result);
    n_ += 2;
  }

  int n_;
  rclcpp::Publisher<sample_msgs::msg::SumResult>::SharedPtr publisher_;
  rclcpp::TimerBase::SharedPtr timer_;
};

int main(int argc, char * argv[])
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<PublisherNode>());
  rclcpp::shutdown();
  return 0;
}
