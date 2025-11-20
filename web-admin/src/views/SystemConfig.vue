<template>
  <div class="system-config">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>系统配置管理</span>
          <div>
            <el-button type="primary" :icon="Plus" @click="handleAdd"
              >新增配置</el-button
            >
            <el-button type="success" :icon="Download" @click="handleExport"
              >导出备份</el-button
            >
            <el-button type="warning" :icon="Upload" @click="handleImport"
              >导入备份</el-button
            >
          </div>
        </div>
      </template>

      <!-- 配置列表 -->
      <el-table
        v-loading="loading"
        :data="configList"
        border
        style="width: 100%"
      >
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="key" label="配置键" width="200" />
        <el-table-column prop="value" label="配置值" min-width="200" />
        <el-table-column prop="description" label="描述" min-width="250" />
        <el-table-column prop="updatedAt" label="更新时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.updatedAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)"
              >编辑</el-button
            >
            <el-button type="danger" size="small" @click="handleDelete(row)"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 系统日志 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <div class="card-header">
          <span>系统日志</span>
          <el-button type="primary" :icon="Refresh" @click="fetchLogs"
            >刷新</el-button
          >
        </div>
      </template>
      <el-input
        v-model="logs"
        type="textarea"
        :rows="15"
        readonly
        style="font-family: monospace; font-size: 12px"
      />
    </el-card>

    <!-- 编辑配置对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="配置键" prop="key">
          <el-input
            v-model="form.key"
            placeholder="请输入配置键"
            :disabled="!!form.id"
          />
        </el-form-item>
        <el-form-item label="配置值" prop="value">
          <el-input v-model="form.value" placeholder="请输入配置值" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="3"
            placeholder="请输入描述"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Plus, Download, Upload, Refresh } from "@element-plus/icons-vue";
import { systemApi } from "@/api/system";

const loading = ref(false);
const configList = ref([]);
const logs = ref("");
const dialogVisible = ref(false);
const dialogTitle = ref("");
const formRef = ref();

const form = reactive({
  id: null,
  key: "",
  value: "",
  description: "",
});

const rules = {
  key: [{ required: true, message: "请输入配置键", trigger: "blur" }],
  value: [{ required: true, message: "请输入配置值", trigger: "blur" }],
};

// 获取配置列表
const fetchConfigs = async () => {
  loading.value = true;
  try {
    const data = await systemApi.getConfigs();
    configList.value = data;
  } catch (error) {
    console.error("获取配置失败:", error);
  } finally {
    loading.value = false;
  }
};

// 获取日志
const fetchLogs = async () => {
  try {
    const data = await systemApi.getLogs(200);
    logs.value = data;
  } catch (error) {
    console.error("获取日志失败:", error);
    ElMessage.error("获取日志失败");
  }
};

// 新增配置
const handleAdd = () => {
  dialogTitle.value = "新增配置";
  form.id = null;
  form.key = "";
  form.value = "";
  form.description = "";
  dialogVisible.value = true;
};

// 编辑配置
const handleEdit = (row) => {
  dialogTitle.value = "编辑配置";
  form.id = row.id;
  form.key = row.key;
  form.value = row.value;
  form.description = row.description || "";
  dialogVisible.value = true;
};

// 保存配置
const handleSave = async () => {
  if (!formRef.value) return;

  await formRef.value.validate(async (valid) => {
    if (!valid) return;

    try {
      await systemApi.saveConfig({
        key: form.key,
        value: form.value,
        description: form.description,
      });
      ElMessage.success("保存成功");
      dialogVisible.value = false;
      fetchConfigs();
    } catch (error) {
      console.error("保存失败:", error);
    }
  });
};

// 删除配置
const handleDelete = (row) => {
  ElMessageBox.confirm(`确定要删除配置 "${row.key}" 吗？`, "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  })
    .then(async () => {
      try {
        await systemApi.deleteConfig(row.key);
        ElMessage.success("删除成功");
        fetchConfigs();
      } catch (error) {
        console.error("删除失败:", error);
      }
    })
    .catch(() => {});
};

// 导出备份
const handleExport = async () => {
  try {
    const blob = await systemApi.exportBackup();
    const url = window.URL.createObjectURL(new Blob([blob]));
    const link = document.createElement("a");
    link.href = url;
    link.setAttribute("download", `backup-${Date.now()}.json`);
    document.body.appendChild(link);
    link.click();
    link.remove();
    ElMessage.success("导出成功");
  } catch (error) {
    console.error("导出失败:", error);
    ElMessage.error("导出失败");
  }
};

// 导入备份
const handleImport = () => {
  ElMessageBox.prompt("请输入备份文件名", "导入备份", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    inputPattern: /^.+\.json$/,
    inputErrorMessage: "请输入有效的文件名",
  })
    .then(async ({ value }) => {
      try {
        await systemApi.importBackup(value);
        ElMessage.success("导入成功");
        fetchConfigs();
      } catch (error) {
        console.error("导入失败:", error);
      }
    })
    .catch(() => {});
};

// 格式化日期
const formatDate = (date) => {
  if (!date) return "-";
  return new Date(date).toLocaleString("zh-CN");
};

onMounted(() => {
  fetchConfigs();
  fetchLogs();
});
</script>

<style scoped>
.system-config {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
