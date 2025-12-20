// pages/diet/DietMain.ets
import DietApi, { DailyRecord, MealRecord, MealFood } from '../../model/api/diet/DietApi';

interface TodaySummary {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

@Component
export struct DietMain {
  @State currentDate: string = this.getFormattedDate(new Date());
  @State dietHistory: DailyRecord[] = [];
  @State todaySummary: TodaySummary = {
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0
  };
  @State isLoading: boolean = true;
  @Consume('refreshTrigger') @Watch('onRefresh') refreshTrigger: number;

  aboutToAppear() {
    console.log('DietMain: aboutToAppear');
    this.loadDietData();
  }

  onRefresh() {
    console.log('DietMain: onRefresh - 检测到Tab切换，刷新数据');
    this.loadDietData();
  }

  async loadDietData() {
    this.isLoading = true;
    try {
      console.log('开始加载饮食数据...');
      const history: DailyRecord[] = await DietApi.getDietHistory();
      console.log('加载到历史记录:', history ? history.length : 0, '条');

      this.dietHistory = Array.isArray(history) ? history : [];
      this.calculateTodaySummary();

    } catch (error) {
      console.error('加载饮食数据失败:', error);
      this.dietHistory = [];
      this.calculateTodaySummary();
    } finally {
      this.isLoading = false;
    }
  }

  calculateTodaySummary() {
    console.log('计算今日汇总...');

    if (!Array.isArray(this.dietHistory)) {
      this.dietHistory = [];
    }

    const todayRecord = this.dietHistory.find((record: DailyRecord) => record.date === this.currentDate);

    if (todayRecord) {
      let totalCalories = 0;
      let totalProtein = 0;
      let totalCarbs = 0;
      let totalFat = 0;

      const meals = Array.isArray(todayRecord.meals) ? todayRecord.meals : [];

      meals.forEach((meal: MealRecord) => {
        const foods = Array.isArray(meal.foods) ? meal.foods : [];
        foods.forEach((food: MealFood) => {
          totalCalories += food.calories || 0;
          totalProtein += food.protein || 0;
          totalCarbs += food.carbohydrates || 0;
          totalFat += food.fat || 0;
        });
      });

      this.todaySummary = {
        calories: Number(totalCalories.toFixed(1)),
        protein: Number(totalProtein.toFixed(1)),
        carbs: Number(totalCarbs.toFixed(1)),
        fat: Number(totalFat.toFixed(1))
      };
    } else {
      this.todaySummary = { calories: 0, protein: 0, carbs: 0, fat: 0 };
    }

    console.log('今日汇总 - 热量:', this.todaySummary.calories);
  }

  getFormattedDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
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

  build() {
    Column() {
      // 顶部标题和日期
      Row() {
        Text('饮食记录')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(this.currentDate)
          .fontSize(16)
          .fontColor(Color.Gray)
      }
      .width('100%')
      .padding(20)

      if (this.isLoading) {
        // 加载中状态
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
      } else {
        Column() {
          // 今日数据总览
          Column() {
            Text('今日总览')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 16 })

            Row() {
              Column() {
                Text(this.todaySummary.calories.toString())
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#4CAF50')
                Text('千卡')
                  .fontSize(12)
                  .fontColor(Color.Gray)
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)

              Divider()
                .vertical(true)
                .height(40)
                .margin({ left: 10, right: 10 })

              Column() {
                Text(`${this.todaySummary.protein}g`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text('蛋白质')
                  .fontSize(12)
                  .fontColor(Color.Gray)
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)

              Column() {
                Text(`${this.todaySummary.carbs}g`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text('碳水')
                  .fontSize(12)
                  .fontColor(Color.Gray)
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)

              Column() {
                Text(`${this.todaySummary.fat}g`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text('脂肪')
                  .fontSize(12)
                  .fontColor(Color.Gray)
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)
            }
            .justifyContent(FlexAlign.SpaceAround)
            .width('100%')
          }
          .width('90%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
          .margin({ bottom: 20 })

          // 近三天饮食记录
          if (this.dietHistory.length > 0) {
            Column() {
              Text('最近记录')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ bottom: 12 })

              List() {
                ForEach(this.dietHistory.slice(0, 3), (dayRecord: DailyRecord) => {
                  ListItem() {
                    this.DayRecordCard(dayRecord)
                  }
                }, (dayRecord: DailyRecord) => dayRecord.date)
              }
              .layoutWeight(1)
              .width('100%')
            }
            .width('100%')
            .layoutWeight(1)
          } else {
            // 无数据状态
            Column() {
              Text('暂无饮食记录')
                .fontSize(16)
                .fontColor('#999')
              Text('快去添加一些食物吧！')
                .fontSize(14)
                .fontColor('#666')
                .margin({ top: 8 })
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder DayRecordCard(dayRecord: DailyRecord) {
    Column() {
      // 日期标题
      Row() {
        Text(dayRecord.date)
          .fontSize(16)
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
      }, (meal: MealRecord) => meal.mealType)
    }
    .width('90%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
    .margin({ bottom: 12 })
  }

  @Builder MealCard(meal: MealRecord) {
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
      .margin({ bottom: 8 })

      // 食物列表
      ForEach(meal.foods, (food: MealFood) => {
        Row() {
          // 使用默认图标代替图片
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
            // 显示食物名和重量
            Text(`${food.foodName}${food.weight ? `（${food.weight}g）` : ''}`)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
            // 展示总营养值
            Text(`热量: ${food.calories}kcal | 蛋白质: ${food.protein ?? '-'}g | 碳水: ${food.carbohydrates ?? '-'}g | 脂肪: ${food.fat ?? '-'}g`)
              .fontSize(12)
              .fontColor(Color.Gray)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Button('删除')
            .fontSize(12)
            .width(50)
            .height(25)
            .backgroundColor('#FF6B6B')
            .fontColor(Color.White)
            .onClick(() => {
              this.deleteFoodRecord(food.recordId);
            })
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      }, (food: MealFood) => food.recordId)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
    .margin({ bottom: 8 })
  }

  calculateDayCalories(dayRecord: DailyRecord): number {
    let total = 0;
    dayRecord.meals.forEach((meal: MealRecord) => {
      total += this.calculateMealCalories(meal);
    });
    return total;
  }

  calculateMealCalories(meal: MealRecord): number {
    let total = 0;
    meal.foods.forEach((food: MealFood) => {
      total += food.calories || 0;
    });
    return total;
  }

  async deleteFoodRecord(recordId: string) {
    try {
      console.log('删除记录:', recordId);
      await DietApi.deleteDietRecord(recordId);
      // 重新加载数据
      this.loadDietData();
    } catch (error) {
      console.error('删除记录失败:', error);
    }
  }
}
