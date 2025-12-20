// pages/diet/DietHistory.ets
import DietApi, { DailyRecord, MealRecord, MealFood } from '../../model/api/diet/DietApi';
import { CustomCard } from '../../components/CustomCard';

@Component
export struct DietHistory {
  @State dietHistory: DailyRecord[] = [];
  @State isLoading: boolean = true;
  @Consume('refreshTrigger') @Watch('onRefresh') refreshTrigger: number;

  aboutToAppear() {
    console.log('DietHistory: aboutToAppear');
    this.loadDietHistory();
  }

  onRefresh() {
    console.log('DietHistory: onRefresh - 检测到Tab切换，刷新数据');
    this.loadDietHistory();
  }

  async loadDietHistory() {
    this.isLoading = true;
    try {
      const history: DailyRecord[] = await DietApi.getDietHistory();
      this.dietHistory = history;
    } catch (error) {
      console.error('加载饮食历史失败:', error);
      this.dietHistory = [];
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Text('饮食历史记录')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin(20)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .margin({ top: 10 })
            .fontColor('#666')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.dietHistory.length === 0) {
        Column() {
          Text('暂无历史记录')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
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
            Column() {
              Text('🍽️')
                .fontSize(24)
            }
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#E0E0E0')
            .borderRadius(8)
            .margin({ right: 12 })

            Column() {
              Text(`${food.foodName}${food.weight ? `（${food.weight}g）` : ''}`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
              Text(`热量: ${food.calories}kcal | 蛋白质: ${food.protein ?? '-'}g | 碳水: ${food.carbohydrates ?? '-'}g | 脂肪: ${food.fat ?? '-'}g`)
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
