#include <gtest/gtest.h>

#include "common_functions/common_functions.hpp"

// 测试 sum：正数相加
TEST(CommonFunctionsTest, SumPositive)
{
  EXPECT_EQ(common_functions::sum(1, 2), 3);
  EXPECT_EQ(common_functions::sum(10, 20), 30);
}

// 测试 sum：负数相加
TEST(CommonFunctionsTest, SumNegative)
{
  EXPECT_EQ(common_functions::sum(-1, -2), -3);
  EXPECT_EQ(common_functions::sum(-5, 5), 0);
}

// 测试 sum：零相加
TEST(CommonFunctionsTest, SumZero)
{
  EXPECT_EQ(common_functions::sum(0, 0), 0);
  EXPECT_EQ(common_functions::sum(0, 42), 42);
}
