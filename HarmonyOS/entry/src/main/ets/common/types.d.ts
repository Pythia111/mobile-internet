// common/types.d.ts
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

export interface RecognitionResult {
  foodName: string;
  calories: number;
  protein: number;
  carbohydrates: number;
  fat: number;
}

export interface FoodItem {
  foodName: string;
  calories: number;
  protein: number;
  carbohydrates: number;
  fat: number;
}

export interface MealFood {
  recordId: string;
  foodName: string;
  calories: number;
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

export interface TodaySummary {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

export interface DietHistoryResponse {
  date: string;
  meals: MealRecord[];
}

export interface AddRecordResponse {
  recordId: string;
}

export interface DeleteRecordResponse {
  code: number;
  message: string;
}
