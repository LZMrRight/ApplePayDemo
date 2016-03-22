//
//  ViewController.m
//  ApplePayDemo
//
//  Created by Mr.Right on 16/3/21.
//  Copyright © 2016年 lizheng. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

/**
 *  支付的时候回调
 */
#pragma mark - PKPaymentAuthorizationViewControllerDelegate
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion{
    
    /**
     *  在这个代理方法内部,需支付信息应发送给服务器/第三方的SDK（银联SDK/易宝支付SDK/易智付SDK等）
     *  再根据服务器返回的支付成功与否进行不同的block显示
     *  我这里是直接返回支付成功的结果
     */
    
    completion(PKPaymentAuthorizationStatusSuccess);
    
    NSLog(@"payment:%@", payment);
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    
    //支付页面关闭
    //点击支付/取消按钮调用该代理方法
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ApplePAY:(id)sender {
    // 1.判断设备是否支持Apple Pay快捷支付功能
    if (![PKPaymentAuthorizationViewController canMakePayments]) return;
    
    // 2.判断设备是否存在绑定过的并支持的银行卡
    if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay,PKPaymentNetworkDiscover]]) {
        
        //进入设置银行卡界面
        [[PKPassLibrary alloc] openPaymentSetup];
    }
    
    // 3.创建支付请求
    PKPaymentRequest *request = [PKPaymentRequest new];

    //填写商户ID（merchant IDs）
    request.merchantIdentifier = @"merchant.com.ApplePayDemoByMrRight";
    
    //设置国家代码
    request.countryCode = @"CN"; //中国大陆
    
    //设置支付货币
    request.currencyCode = @"CNY";//人民币
    
    //设置商户的支付标准
    /**
     *      PKMerchantCapability3DS      // Merchant supports 3DS
     *      PKMerchantCapabilityEMV      // Merchant supports EMV
     *      PKMerchantCapabilityCredit   // Merchant supports credit
     *      PKMerchantCapabilityDebit    // Merchant supports debit

     */
    request.merchantCapabilities = PKMerchantCapability3DS;
    
    //设置支持卡的类型
    /**
     *  对支付卡类别的限制
     *  PKPaymentNetworkChinaUnionPay  银联卡
     *  PKPaymentNetworkVisa  国际卡
     *  PKPaymentNetworkMasterCard 万事达卡 国际卡
     */
    request.supportedNetworks = @[PKPaymentNetworkChinaUnionPay, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    
    //设置商品参数
    /**
     *  summaryItemWithLabel 商品名称(英文字符默认全部显示大写)
     *  amount 商品的价格 - NSDecimalNumber类型
     *  PKPaymentSummaryItemTypePending 待付款 PKPaymentSummaryItemTypeFinal
     */
    
    NSDecimalNumber *oneAmout = [NSDecimalNumber decimalNumberWithString:@"5.20"];
    NSDecimalNumber *twoAmout = [NSDecimalNumber decimalNumberWithString:@"10.00"];
    NSDecimalNumber *threemAmout = [NSDecimalNumber decimalNumberWithString:@"3.33"];
    
    NSDecimalNumber *itemTotal = [NSDecimalNumber zero];
    itemTotal = [itemTotal decimalNumberByAdding:oneAmout];
    itemTotal = [itemTotal decimalNumberByAdding:twoAmout];
    itemTotal = [itemTotal decimalNumberByAdding:threemAmout];
    
    
    PKPaymentSummaryItem *itemOne = [PKPaymentSummaryItem summaryItemWithLabel:@"小一"
                                                                        amount:oneAmout];
    
    PKPaymentSummaryItem *itemTwo = [PKPaymentSummaryItem summaryItemWithLabel:@"小二"
                                                                        amount:twoAmout];
    
    PKPaymentSummaryItem *itemThree = [PKPaymentSummaryItem summaryItemWithLabel:@"小三"
                                                                          amount:threemAmout];
    
    PKPaymentSummaryItem *itemSum = [PKPaymentSummaryItem summaryItemWithLabel:@"Mr.Right_li" amount:itemTotal];
    
    request.paymentSummaryItems = @[itemOne, itemTwo, itemThree, itemSum];
    
    /**
     *  以上参数都是必须的
     *  以下参数不是必须的
     */
    
    //设置收据内容
    request.requiredBillingAddressFields = PKAddressFieldAll;  //则其余四个必须添加
    
    //设置送货内容 all则其余四个内容必填
    request.requiredShippingAddressFields = PKAddressFieldAll;
    
    //设置送货方式
    PKShippingMethod *method = [PKShippingMethod summaryItemWithLabel:@"达达" amount:[NSDecimalNumber decimalNumberWithString:@"10.00"]];
    method.identifier = @"达达快送";
    method.detail = @"2小时到达";
    
    request.shippingMethods = @[method];
    
    //显示支付界面
    PKPaymentAuthorizationViewController *paymentVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    // 设置代理
    paymentVC.delegate = self;
    
    if (!paymentVC) return;
    
    [self presentViewController:paymentVC animated:YES completion:nil];

}


@end
