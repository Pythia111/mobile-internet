<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <!-- 统计卡片 -->
      <el-col :xs="24" :sm="12" :lg="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon user-icon">
              <el-icon :size="40"><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ totalUsers }}</div>
              <div class="stat-label">用户总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :lg="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon today-icon">
              <el-icon :size="40"><Calendar /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ todayUsers }}</div>
              <div class="stat-label">今日新增</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :lg="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon active-icon">
              <el-icon :size="40"><Connection /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ activeUsers }}</div>
              <div class="stat-label">活跃用户</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :lg="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon admin-icon">
              <el-icon :size="40"><UserFilled /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ adminUsers }}</div>
              <div class="stat-label">管理员</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" style="margin-top: 20px">
      <!-- 用户增长趋势 -->
      <el-col :xs="24" :lg="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>用户增长趋势</span>
            </div>
          </template>
          <div ref="userTrendChart" style="height: 300px"></div>
        </el-card>
      </el-col>

      <!-- 用户角色分布 -->
      <el-col :xs="24" :lg="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>用户角色分布</span>
            </div>
          </template>
          <div ref="roleDistChart" style="height: 300px"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最近注册用户 -->
    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>最近注册用户</span>
              <el-button type="text" @click="$router.push('/users')"
                >查看全部</el-button
              >
            </div>
          </template>
          <el-table :data="recentUsers" border>
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="phone" label="手机号" width="150" />
            <el-table-column prop="name" label="姓名" width="120" />
            <el-table-column prop="email" label="邮箱" min-width="200" />
            <el-table-column label="角色" width="150">
              <template #default="{ row }">
                <el-tag
                  v-for="role in row.roles"
                  :key="role.id"
                  :type="role.name === 'ROLE_ADMIN' ? 'danger' : 'success'"
                  size="small"
                  style="margin-right: 5px"
                >
                  {{ formatRole(role.name) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createdAt" label="注册时间" width="180">
              <template #default="{ row }">
                {{ formatDate(row.createdAt) }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from "vue";
import {
  User,
  Calendar,
  Connection,
  UserFilled,
} from "@element-plus/icons-vue";
import * as echarts from "echarts";

// 统计数据
const totalUsers = ref(0);
const todayUsers = ref(0);
const activeUsers = ref(0);
const adminUsers = ref(0);
const recentUsers = ref([]);

// 图表引用
const userTrendChart = ref(null);
const roleDistChart = ref(null);

// 获取统计数据
const fetchStatistics = async () => {
  // 模拟数据
  totalUsers.value = 1234;
  todayUsers.value = 45;
  activeUsers.value = 856;
  adminUsers.value = 5;

  recentUsers.value = [
    {
      id: 10,
      phone: "+8613800000010",
      name: "王五",
      email: "wangwu@example.com",
      roles: [{ id: 1, name: "ROLE_USER" }],
      createdAt: new Date().toISOString(),
    },
    {
      id: 9,
      phone: "+8613800000009",
      name: "赵六",
      email: null,
      roles: [{ id: 1, name: "ROLE_USER" }],
      createdAt: new Date(Date.now() - 3600000).toISOString(),
    },
    {
      id: 8,
      phone: "+8613800000008",
      name: "孙七",
      email: "sunqi@example.com",
      roles: [{ id: 1, name: "ROLE_USER" }],
      createdAt: new Date(Date.now() - 7200000).toISOString(),
    },
  ];
};

// 初始化用户增长趋势图
const initUserTrendChart = () => {
  const chart = echarts.init(userTrendChart.value);
  const option = {
    tooltip: {
      trigger: "axis",
    },
    xAxis: {
      type: "category",
      data: ["周一", "周二", "周三", "周四", "周五", "周六", "周日"],
    },
    yAxis: {
      type: "value",
    },
    series: [
      {
        name: "新增用户",
        type: "line",
        data: [12, 23, 34, 45, 32, 28, 45],
        smooth: true,
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: "rgba(64, 158, 255, 0.5)" },
            { offset: 1, color: "rgba(64, 158, 255, 0.1)" },
          ]),
        },
      },
    ],
  };
  chart.setOption(option);

  // 响应式
  window.addEventListener("resize", () => chart.resize());
};

// 初始化角色分布图
const initRoleDistChart = () => {
  const chart = echarts.init(roleDistChart.value);
  const option = {
    tooltip: {
      trigger: "item",
    },
    legend: {
      orient: "vertical",
      left: "left",
    },
    series: [
      {
        name: "用户角色",
        type: "pie",
        radius: "60%",
        data: [
          { value: 1229, name: "普通用户" },
          { value: 5, name: "管理员" },
        ],
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: "rgba(0, 0, 0, 0.5)",
          },
        },
      },
    ],
  };
  chart.setOption(option);

  // 响应式
  window.addEventListener("resize", () => chart.resize());
};

// 格式化角色
const formatRole = (role) => {
  const roleMap = {
    ROLE_ADMIN: "管理员",
    ROLE_USER: "普通用户",
  };
  return roleMap[role] || role;
};

// 格式化日期
const formatDate = (date) => {
  if (!date) return "-";
  return new Date(date).toLocaleString("zh-CN");
};

onMounted(async () => {
  await fetchStatistics();
  await nextTick();
  initUserTrendChart();
  initRoleDistChart();
});
</script>

<style scoped>
.dashboard {
  height: 100%;
}

.stat-card {
  margin-bottom: 20px;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.stat-icon {
  width: 70px;
  height: 70px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
}

.user-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.today-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.active-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.admin-icon {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
