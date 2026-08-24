#include <functional>
#include <memory>

#include "rclcpp/rclcpp.hpp"
#include "sample_msgs/msg/sum_result.hpp"

class SubscriberNode : public rclcpp::Node
{
public:
  SubscriberNode() : Node("subscriber_node")
  {
    subscription_ = this->create_subscription<sample_msgs::msg::SumResult>(
      "sum_result", 10,
      std::bind(&SubscriberNode::topic_callback, this, std::placeholders::_1));
  }

private:
  void topic_callback(const sample_msgs::msg::SumResult::SharedPtr msg)
  {
    RCLCPP_INFO(
      this->get_logger(),
      "Received: sum(%ld, %ld) = %ld",
      msg->a, msg->b, msg->result);
  }

  rclcpp::Subscription<sample_msgs::msg::SumResult>::SharedPtr subscription_;
};

int main(int argc, char * argv[])
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<SubscriberNode>());
  rclcpp::shutdown();
  return 0;
}
