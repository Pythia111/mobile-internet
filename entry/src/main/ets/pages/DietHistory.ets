// pages/DietHistory.ets
import { DietService } from '../common/diet-service';
import { CustomCard } from '../components/CustomCard';

@Entry
@Component
export struct DietHistory {
  private dietService: DietService = new DietService();
  @State dietHistory: DailyRecord[] = [];

  aboutToAppear() {
    this.loadDietHistory();
  }

  async loadDietHistory() {
    try {
      const history: DailyRecord[] = await this.dietService.getDietHistory();
      this.dietHistory = history;
    } catch (error) {
      console.error('加载饮食历史失败:', error);
    }
  }

  build() {
    Column() {
      Text('饮食历史记录')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin(20)

      List() {
        ForEach(this.dietHistory, (dayRecord: DailyRecord) => {
          ListItem() {
            Column() {
              // 日期标题
              Row() {
                Text(dayRecord.date)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                Blank()
                Text(this.calculateDayCalories(dayRecord) + ' kcal')
                  .fontSize(14)
                  .fontColor(Color.Gray)
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 各餐次记录
              ForEach(dayRecord.meals, (meal: MealRecord) => {
                if (meal.foods.length > 0) {
                  this.MealCard(meal)
                }
              })
            }
            .padding(16)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder MealCard(meal: MealRecord) {
    CustomCard() {
      Column() {
        // 餐次标题
        Row() {
          Text(this.getMealTypeText(meal.mealType))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Blank()
          Text(this.calculateMealCalories(meal) + ' kcal')
            .fontSize(14)
            .fontColor(Color.Gray)
        }
        .width('100%')

        // 食物列表
        ForEach(meal.foods, (food: MealFood) => {
          Row() {
            if (food.image) {
              Image(food.image)
                .width(40)
                .height(40)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
                .margin({ right: 12 })
            } else {
              Image($r('app.media.food_icon'))
                .width(40)
                .height(40)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
                .margin({ right: 12 })
            }

            Column() {
              Text(food.foodName)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
              Text(food.calories + ' kcal')
                .fontSize(12)
                .fontColor(Color.Gray)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
        })
      }
      .padding(12)
    }
  }

  getMealTypeText(mealType: string): string {
    const mealMap: Record<string, string> = {
      'breakfast': '早餐',
      'lunch': '午餐',
      'dinner': '晚餐',
      'snack': '加餐'
    };
    return mealMap[mealType] || mealType;
  }

  calculateDayCalories(dayRecord: DailyRecord): number {
    return dayRecord.meals.reduce((total: number, meal: MealRecord) => {
      return total + this.calculateMealCalories(meal);
    }, 0);
  }

  calculateMealCalories(meal: MealRecord): number {
    return meal.foods.reduce((total: number, food: MealFood) => total + food.calories, 0);
  }
}

// 本地类型定义
interface DailyRecord {
  date: string;
  meals: MealRecord[];
}

interface MealRecord {
  mealType: string;
  foods: MealFood[];
}

interface MealFood {
  recordId: string;
  foodName: string;
  calories: number;
  image?: string;
}