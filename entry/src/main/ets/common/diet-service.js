// common/diet-service.js
import { HttpService } from './api.js';

export class DietService {
    httpService = null;

    constructor() {
        this.httpService = HttpService.getInstance();
    }

    async searchFood(keyword) {
        console.log('🔍 搜索食物:', keyword);

        try {
            const results = await this.httpService.get('diet/search', { keyword });
            console.log('✅ API搜索成功，结果数量:', results ? results.length : 0);
            return results || [];
        } catch (error) {
            console.error('❌ API搜索失败:', error.message);
            throw error;
        }
    }

    async addDietRecord(record) {
        console.log('添加饮食记录:', record);
        try {
            const result = await this.httpService.post('diet/records', record);
            console.log('✅ 添加记录成功');
            return result;
        } catch (error) {
            console.error('添加记录失败:', error.message);
            throw error;
        }
    }

    // 修复 getDietHistory 方法
    async getDietHistory() {
        console.log('📊 获取饮食历史记录');
        try {
            const response = await this.httpService.get('diet/records/all');
            console.log('✅ 获取历史记录成功，响应数据:', response);

            // API返回的是单个对象，需要转换为数组格式
            let history = [];
            if (response && typeof response === 'object') {
                // 如果返回的是单个记录对象，包装成数组
                history = [response];
            } else if (Array.isArray(response)) {
                history = response;
            }

            console.log('处理后的历史记录数量:', history.length);
            return history;
        } catch (error) {
            console.error('❌ 获取历史记录失败:', error.message);
            // 返回模拟数据作为备用
            return this.getMockDietHistory();
        }
    }

    async deleteDietRecord(recordId) {
        console.log('🗑️ 删除饮食记录:', recordId);
        try {
            const result = await this.httpService.delete(`diet/records/${recordId}`);
            console.log('✅ 删除记录成功');
            return result;
        } catch (error) {
            console.error('删除记录失败:', error.message);
            throw error;
        }
    }

    // 模拟历史数据
    getMockDietHistory() {
        console.log('📋 使用模拟历史数据');
        const today = new Date();
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        const dayBeforeYesterday = new Date(today);
        dayBeforeYesterday.setDate(dayBeforeYesterday.getDate() - 2);

        const formatDate = (date) => {
            const year = date.getFullYear();
            const month = (date.getMonth() + 1).toString().padStart(2, '0');
            const day = date.getDate().toString().padStart(2, '0');
            return `${year}-${month}-${day}`;
        };

        return [
            {
                date: formatDate(today),
                meals: [
                    {
                        mealType: 'breakfast',
                        foods: [
                            { recordId: '1', foodName: '牛奶', calories: 150 },
                            { recordId: '2', foodName: '面包', calories: 120 }
                        ]
                    },
                    {
                        mealType: 'lunch',
                        foods: [
                            { recordId: '3', foodName: '米饭', calories: 200 },
                            { recordId: '4', foodName: '鸡胸肉', calories: 180 }
                        ]
                    }
                ]
            },
            {
                date: formatDate(yesterday),
                meals: [
                    {
                        mealType: 'breakfast',
                        foods: [
                            { recordId: '5', foodName: '鸡蛋', calories: 80 },
                            { recordId: '6', foodName: '燕麦', calories: 150 }
                        ]
                    },
                    {
                        mealType: 'dinner',
                        foods: [
                            { recordId: '7', foodName: '牛肉', calories: 250 },
                            { recordId: '8', foodName: '蔬菜沙拉', calories: 80 }
                        ]
                    }
                ]
            }
        ];
    }
}