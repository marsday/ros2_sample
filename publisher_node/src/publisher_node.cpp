#include <chrono>
#include <functional>
#include <memory>
#include <string>

#include "rclcpp/rclcpp.hpp"
#include "common_functions/common_functions.hpp"
#include "sample_msgs/msg/sum_result.hpp"
#include "protobuf_msg/sum_data.pb.h"

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

    // 使用 protobuf 序列化演示
    protobuf_msg::SumData data;
    data.set_a(a);
    data.set_b(b);
    data.set_result(result);
    std::string serialized;
    data.SerializeToString(&serialized);

    RCLCPP_INFO(this->get_logger(),
      "Publishing: sum(%d, %d) = %d | protobuf serialized %zu bytes",
      a, b, result, serialized.size());
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
