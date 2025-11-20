<template>
  <div class="user-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户列表</span>
          <el-button type="primary" :icon="Refresh" @click="fetchUsers"
            >刷新</el-button
          >
        </div>
      </template>

      <!-- 搜索栏 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="手机号">
          <el-input
            v-model="searchForm.phone"
            placeholder="请输入手机号"
            clearable
          />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input
            v-model="searchForm.name"
            placeholder="请输入姓名"
            clearable
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="handleSearch"
            >查询</el-button
          >
          <el-button :icon="RefreshLeft" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 用户表格 -->
      <el-table
        v-loading="loading"
        :data="tableData"
        border
        style="width: 100%"
      >
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
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)"
              >查看</el-button
            >
            <el-button type="warning" size="small" @click="handleEdit(row)"
              >编辑</el-button
            >
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 查看用户详情对话框 -->
    <el-dialog v-model="viewDialogVisible" title="用户详情" width="600px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="ID">{{
          currentUser?.id
        }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{
          currentUser?.phone
        }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{
          currentUser?.name
        }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{
          currentUser?.email || "未填写"
        }}</el-descriptions-item>
        <el-descriptions-item label="角色" :span="2">
          <el-tag
            v-for="role in currentUser?.roles"
            :key="role.id"
            :type="role.name === 'ROLE_ADMIN' ? 'danger' : 'success'"
            size="small"
            style="margin-right: 5px"
          >
            {{ formatRole(role.name) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="注册时间" :span="2">
          {{ formatDate(currentUser?.createdAt) }}
        </el-descriptions-item>
        <el-descriptions-item label="最后更新" :span="2">
          {{ formatDate(currentUser?.updatedAt) }}
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="viewDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 编辑用户对话框 -->
    <el-dialog v-model="editDialogVisible" title="编辑用户" width="500px">
      <el-form ref="editFormRef" :model="editForm" label-width="80px">
        <el-form-item label="手机号">
          <el-input v-model="editForm.phone" disabled />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="editForm.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="editForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="头像URL">
          <el-input v-model="editForm.avatarUrl" placeholder="请输入头像URL" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage } from "element-plus";
import { Search, Refresh, RefreshLeft } from "@element-plus/icons-vue";
import { userApi } from "@/api/user";

const loading = ref(false);
const tableData = ref([]);
const total = ref(0);
const currentPage = ref(1);
const pageSize = ref(10);

const searchForm = reactive({
  phone: "",
  name: "",
});

const viewDialogVisible = ref(false);
const editDialogVisible = ref(false);
const currentUser = ref(null);
const editFormRef = ref();

const editForm = reactive({
  id: null,
  phone: "",
  name: "",
  email: "",
  avatarUrl: "",
});

// 获取用户列表
const fetchUsers = async () => {
  loading.value = true;
  try {
    // 注意：这里需要后端提供获取所有用户的接口
    // 目前使用模拟数据
    const mockData = [
      {
        id: 1,
        phone: "+8613800000001",
        name: "管理员",
        email: "admin@example.com",
        roles: [
          { id: 1, name: "ROLE_USER" },
          { id: 2, name: "ROLE_ADMIN" },
        ],
        createdAt: "2024-01-01T10:00:00Z",
        updatedAt: "2024-01-01T10:00:00Z",
      },
      {
        id: 2,
        phone: "+8613800000002",
        name: "张三",
        email: "zhangsan@example.com",
        roles: [{ id: 1, name: "ROLE_USER" }],
        createdAt: "2024-01-02T10:00:00Z",
        updatedAt: "2024-01-02T10:00:00Z",
      },
      {
        id: 3,
        phone: "+8613800000003",
        name: "李四",
        email: null,
        roles: [{ id: 1, name: "ROLE_USER" }],
        createdAt: "2024-01-03T10:00:00Z",
        updatedAt: "2024-01-03T10:00:00Z",
      },
    ];

    tableData.value = mockData;
    total.value = mockData.length;
  } catch (error) {
    console.error("获取用户列表失败:", error);
    ElMessage.error("获取用户列表失败");
  } finally {
    loading.value = false;
  }
};

// 搜索
const handleSearch = () => {
  currentPage.value = 1;
  fetchUsers();
};

// 重置
const handleReset = () => {
  searchForm.phone = "";
  searchForm.name = "";
  handleSearch();
};

// 查看详情
const handleView = (row) => {
  currentUser.value = row;
  viewDialogVisible.value = true;
};

// 编辑
const handleEdit = (row) => {
  editForm.id = row.id;
  editForm.phone = row.phone;
  editForm.name = row.name;
  editForm.email = row.email || "";
  editForm.avatarUrl = row.avatarUrl || "";
  editDialogVisible.value = true;
};

// 保存编辑
const handleSaveEdit = async () => {
  try {
    // 这里需要后端提供管理员编辑用户的接口
    ElMessage.success("保存成功");
    editDialogVisible.value = false;
    fetchUsers();
  } catch (error) {
    console.error("保存失败:", error);
  }
};

// 分页相关
const handleSizeChange = (val) => {
  pageSize.value = val;
  fetchUsers();
};

const handleCurrentChange = (val) => {
  currentPage.value = val;
  fetchUsers();
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

onMounted(() => {
  fetchUsers();
});
</script>

<style scoped>
.user-list {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 20px;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
