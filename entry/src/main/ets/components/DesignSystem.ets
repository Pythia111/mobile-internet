// 设计系统：颜色、间距、字号等集中定义
export interface ColorPalette { primary: string; background: string; textPrimary: string; textSecondary: string; danger: string; warn: string; card: string }
export const Colors: ColorPalette = {
  primary: '#4CAF50',
  background: '#F5F5F5',
  textPrimary: '#333333',
  textSecondary: '#666666',
  danger: '#FF5252',
  warn: '#FF9800',
  card: '#FFFFFF'
};

export interface SpacingScale { xs: number; sm: number; md: number; lg: number }
export const Spacing: SpacingScale = { xs: 4, sm: 8, md: 16, lg: 24 };

export interface RadiusScale { sm: number; md: number }
export const Radius: RadiusScale = { sm: 6, md: 12 };

export interface NutritionSummary { calories: number; protein: number; carbohydrates: number; fat: number; remaining: number }
export interface Food { id?: string; name: string; calories: number; protein?: number; carbohydrates?: number; fat?: number; amountDesc?: string }
export interface Meal { mealType: string; timeLabel?: string; foods: Array<Food> }
export interface DayDiet { date: string; meals: Array<Meal>; totalCalories: number }

export interface MacroRatio { proteinPct: number; carbPct: number; fatPct: number }
// 简单工具：计算营养比例
export function calcMacroRatio(summary: NutritionSummary): MacroRatio {
  const p: number = summary.protein || 0;
  const c: number = summary.carbohydrates || 0;
  const f: number = summary.fat || 0;
  const total: number = p + c + f || 1;
  return { proteinPct: p / total, carbPct: c / total, fatPct: f / total };
}
