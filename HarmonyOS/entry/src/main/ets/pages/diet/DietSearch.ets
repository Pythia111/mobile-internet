// pages/diet/DietSearch.ets
import DietApi, { FoodItem, FoodRecord } from '../../model/api/diet/DietApi';
import hilog from '@ohos.hilog';

const TAG = 'DietSearch';
const DOMAIN = 0x0001;

@Entry
@Component
export struct DietSearch {
  @State searchKeyword: string = '';
  @State searchResults: FoodItem[] = [];
  // 记录每个食物的重量（g），key为foodName，value为number
  @State foodWeights: Record<string, number> = {};
  @State selectedMealType: string = 'breakfast';
  @State isLoading: boolean = false;
  @State hasSearched: boolean = false;

  // Toast状态管理
  @State toastMessage: string = '';
  @State showToast: boolean = false;
  @State toastType: 'success' | 'error' = 'success';

  aboutToAppear() {
    hilog.info(DOMAIN, TAG, '🎉 DietSearch页面加载完成');
  }

  // 自定义Toast显示方法
  showCustomToast(message: string, type: 'success' | 'error' = 'success') {
    this.toastMessage = message;
    this.toastType = type;
    this.showToast = true;

    // 2秒后自动隐藏
    setTimeout(() => {
      this.showToast = false;
    }, 2000);
  }

  async searchFood() {
    if (this.searchKeyword.trim() === '') {
      this.showCustomToast('请输入搜索关键词', 'error');
      this.searchResults = [];
      this.hasSearched = false;
      return;
    }

    this.isLoading = true;
    this.hasSearched = true;

    try {
      hilog.info(DOMAIN, TAG, '开始搜索食物: %{public}s', this.searchKeyword);
      const results: FoodItem[] = await DietApi.searchFood(this.searchKeyword);
      hilog.info(DOMAIN, TAG, '搜索完成，结果数量: %{public}d', results.length);

      this.searchResults = results;

      if (results.length === 0) {
        this.showCustomToast('未找到相关食物', 'error');
      }
    } catch (error) {
      let errorMsg = '搜索失败，请检查网络连接';
      this.showCustomToast(errorMsg, 'error');
      this.searchResults = [];
    } finally {
      this.isLoading = false;
    }
  }

  async addFoodRecord(food: FoodItem) {
    hilog.info(DOMAIN, TAG, '添加食物记录: %{public}s', food.foodName);
    // 获取用户输入的重量，默认为100g
    const weight = this.foodWeights[food.foodName] ?? 100;
    try {
      // 计算总营养值
      const ratio = weight / 100;
      const record: FoodRecord = {
        foodName: food.foodName,
        calories: Math.round(food.calories * ratio * 10) / 10,
        protein: Math.round(food.protein * ratio * 10) / 10,
        carbohydrates: Math.round(food.carbohydrates * ratio * 10) / 10,
        fat: Math.round(food.fat * ratio * 10) / 10,
        mealType: this.selectedMealType as 'breakfast' | 'lunch' | 'dinner' | 'snack',
        date: this.getFormattedDate(new Date()),
        // 可扩展: weight: weight
      };
      hilog.debug(DOMAIN, TAG, '发送记录数据: %{public}s', JSON.stringify(record));
      const result = await DietApi.addDietRecord(record);
      this.showCustomToast(`✓ 已添加 ${food.foodName}（${weight}g），点击\"饮食记录\"查看`, 'success');
      hilog.info(DOMAIN, TAG, '添加记录成功，recordId: %{public}s', result.recordId);
    } catch (error) {
      let errorMsg = '添加失败，请重试';
      this.showCustomToast(errorMsg, 'error');
      hilog.error(DOMAIN, TAG, '添加记录失败: %{public}s', errorMsg);
    }
  }

  getFormattedDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  build() {
    Column() {
      // 页面标题
      Text('搜索食物')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      this.SearchTab()

      // 自定义Toast显示
      if (this.showToast) {
        this.CustomToastBuilder()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder CustomToastBuilder() {
    Column() {
      Text(this.toastMessage)
        .fontSize(16)
        .fontColor(Color.White)
        .padding({ left: 24, right: 24, top: 12, bottom: 12 })
        .backgroundColor(this.toastType === 'success' ? '#4CAF50' : '#FF9800')
        .borderRadius(25)
        .shadow({ radius: 8, color: '#40000000', offsetX: 0, offsetY: 4 })
    }
    .width('100%')
    .position({ x: 0, y: '80%' })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder SearchTab() {
    Column() {
      // 搜索行
      Row() {
        TextInput({ placeholder: '搜索食物...', text: this.searchKeyword })
          .layoutWeight(1)
          .height(40)
          .type(InputType.Normal)
          .enterKeyType(EnterKeyType.Search)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            this.searchFood();
          })

        Button('搜索')
          .width(60)
          .height(40)
          .margin({ left: 10 })
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .onClick(() => {
            this.searchFood();
          })
      }
      .width('90%')
      .margin(10)

      // 餐别选择
      Row() {
        Text('选择餐别:')
          .fontSize(16)
          .margin({ right: 10 })

        Radio({ value: 'breakfast', group: 'mealType' })
          .checked(this.selectedMealType === 'breakfast')
          .onChange((value: boolean) => {
            if (value) this.selectedMealType = 'breakfast';
          })
        Text('早餐')
          .fontSize(14)
          .margin({ right: 10 })

        Radio({ value: 'lunch', group: 'mealType' })
          .checked(this.selectedMealType === 'lunch')
          .onChange((value: boolean) => {
            if (value) this.selectedMealType = 'lunch';
          })
        Text('午餐')
          .fontSize(14)
          .margin({ right: 10 })

        Radio({ value: 'dinner', group: 'mealType' })
          .checked(this.selectedMealType === 'dinner')
          .onChange((value: boolean) => {
            if (value) this.selectedMealType = 'dinner';
          })
        Text('晚餐')
          .fontSize(14)
          .margin({ right: 10 })

        Radio({ value: 'snack', group: 'mealType' })
          .checked(this.selectedMealType === 'snack')
          .onChange((value: boolean) => {
            if (value) this.selectedMealType = 'snack';
          })
        Text('加餐')
          .fontSize(14)
      }
      .width('90%')
      .margin(10)

      // 搜索结果区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('搜索中...')
            .fontSize(14)
            .margin({ top: 10 })
            .fontColor('#666')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.hasSearched && this.searchResults.length === 0) {
        Column() {
          Text('未找到相关食物')
            .fontSize(16)
            .fontColor('#999')
            .margin({ top: 10 })
          Text('请尝试其他关键词')
            .fontSize(14)
            .fontColor('#666')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.searchResults.length > 0) {
        Text(`找到 ${this.searchResults.length} 个结果`)
          .fontSize(14)
          .fontColor('#666')
          .width('90%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 10 })

        List() {
          ForEach(this.searchResults, (food: FoodItem) => {
            ListItem() {
              this.FoodItemBuilder(food)
            }
          }, (food: FoodItem) => food.foodName)
        }
        .layoutWeight(1)
        .width('100%')
      } else {
        Column() {
          Text('请输入食物名称搜索')
            .fontSize(16)
            .fontColor('#999')
          Text('例如：苹果、米饭、鸡胸肉等')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 5 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder FoodItemBuilder(food: FoodItem) {
    Row() {
      Column() {
        Text(food.foodName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
        Text(`热量: ${food.calories}kcal | 蛋白质: ${food.protein}g | 碳水: ${food.carbohydrates}g | 脂肪: ${food.fat}g`)
          .fontSize(12)
          .fontColor(Color.Gray)
          .textAlign(TextAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 新增重量输入框
      Column() {
        Text('重量(g)')
          .fontSize(12)
          .fontColor(Color.Gray)
        TextInput({ placeholder: '100', text: (this.foodWeights[food.foodName]?.toString() ?? '100') })
          .type(InputType.Number)
          .width(60)
          .height(30)
          .fontSize(12)
          .onChange((value: string) => {
            let num = parseInt(value);
            if (isNaN(num) || num <= 0) num = 100;
            this.foodWeights[food.foodName] = num;
          })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 8 })

      Button('添加')
        .fontSize(12)
        .width(60)
        .height(30)
        .backgroundColor('#4CAF50')
        .fontColor(Color.White)
        .onClick(() => {
          this.addFoodRecord(food);
        })
    }
    .width('100%')
    .padding(10)
    .border({ width: 1, color: '#E0E0E0' })
    .margin({ bottom: 5 })
    .borderRadius(8)
  }
}
