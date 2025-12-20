// model/api/diet/DietApi.ets
import http from '@ohos.net.http';
import ApiClient from '../ApiClient';
import { ApiResponse } from '../../response/ApiResponse';

export interface FoodItem {
  foodName: string;
  calories: number;
  protein: number;
  carbohydrates: number;
  fat: number;
}

export interface FoodRecord {
  foodName: string;
  calories: number;
  protein: number;
  carbohydrates: number;
  fat: number;
  mealType: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  date: string;
  image?: string;
}

export interface MealFood {
  recordId: string;
  foodName: string;
  calories: number;
  weight?: number;
  protein?: number;
  carbohydrates?: number;
  fat?: number;
  image?: string;
}

export interface MealRecord {
  mealType: string;
  foods: MealFood[];
}

export interface DailyRecord {
  date: string;
  meals: MealRecord[];
}

export interface RecordIdResponse {
  recordId: string;
}

export interface EmptyResponse {
  success: boolean;
}

export default class DietApi {
  /**
   * 搜索食物
   */
  static async searchFood(keyword: string): Promise<FoodItem[]> {
    console.info('DietApi: 搜索食物:', keyword);
    try {
      // 手动构建查询参数
      const encodedKeyword = encodeURIComponent(keyword);
      const path = `/api/diet/search?keyword=${encodedKeyword}`;
      
      const response = await ApiClient.request<ApiResponse<FoodItem[]>>(path, {
        method: http.RequestMethod.GET
      });
      
      console.info('DietApi: 搜索结果:', JSON.stringify(response));
      
      if (response.code === 200 && response.data) {
        return response.data;
      } else {
        console.error('DietApi: 搜索失败:', response.message);
        return [];
      }
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : 'Unknown error';
      console.error('DietApi.searchFood error:', errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 添加饮食记录
   */
  static async addDietRecord(record: FoodRecord): Promise<RecordIdResponse> {
    console.info('DietApi: 添加饮食记录:', JSON.stringify(record));
    try {
      const response = await ApiClient.request<ApiResponse<RecordIdResponse>>(
        '/api/diet/records',
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(record)
        }
      );
      
      console.info('DietApi: 添加记录响应:', JSON.stringify(response));
      
      if (response.code === 200 && response.data) {
        return response.data;
      } else {
        const errorMsg = response.message || '添加记录失败';
        throw new Error(errorMsg);
      }
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : 'Unknown error';
      console.error('DietApi.addDietRecord error:', errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 获取所有饮食历史记录
   */
  static async getDietHistory(): Promise<DailyRecord[]> {
    console.info('DietApi: 获取饮食历史记录');
    try {
      const response = await ApiClient.request<ApiResponse<DailyRecord[]>>(
        '/api/diet/records/all',
        {
          method: http.RequestMethod.GET
        }
      );
      
      console.info('DietApi: 历史记录响应:', JSON.stringify(response));
      
      if (response.code === 200 && response.data) {
        // 处理返回的数据，确保是数组格式
        let history: DailyRecord[] = [];
        if (Array.isArray(response.data)) {
          history = response.data;
          console.info(`DietApi: 解析到${history.length}条历史记录（数组）`);
        } else if (typeof response.data === 'object') {
          // 如果返回的是单个对象，包装成数组
          const singleRecord = response.data as DailyRecord;
          history = [singleRecord];
          console.info(`DietApi: 解析到1条历史记录（对象），包含${singleRecord.meals?.length || 0}餐`);
        }
        
        // 打印每条记录的详细信息
        history.forEach((record, index) => {
          console.info(`DietApi: 记录${index}: 日期=${record.date}, 餐数=${record.meals?.length || 0}`);
          if (record.meals) {
            record.meals.forEach((meal, mealIndex) => {
              console.info(`DietApi:   餐${mealIndex}: 类型=${meal.mealType}, 食物数=${meal.foods?.length || 0}`);
            });
          }
        });
        
        return history;
      } else {
        console.warn('DietApi: 获取历史记录失败，返回空数组');
        return [];
      }
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : 'Unknown error';
      console.error('DietApi.getDietHistory error:', errorMsg);
      // 返回空数组而不是抛出错误，让UI层处理
      return [];
    }
  }

  /**
   * 删除饮食记录
   */
  static async deleteDietRecord(recordId: string): Promise<boolean> {
    console.info('DietApi: 删除饮食记录:', recordId);
    try {
      const response = await ApiClient.request<ApiResponse<EmptyResponse>>(
        `/api/diet/records/${recordId}`,
        {
          method: http.RequestMethod.DELETE
        }
      );
      
      console.info('DietApi: 删除记录响应:', JSON.stringify(response));
      
      return response.code === 200;
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : 'Unknown error';
      console.error('DietApi.deleteDietRecord error:', errorMsg);
      throw new Error(errorMsg);
    }
  }
}
