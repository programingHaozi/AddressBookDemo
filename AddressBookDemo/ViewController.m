//
//  ViewController.m
//  AddressBookDemo
//
//  Created by chenhao on 14/12/29.
//  Copyright (c) 2014年 chenhao. All rights reserved.
//http://www.cocoachina.com/bbs/read.php?tid=62527
//http://blog.csdn.net/iukey/article/details/7343650
//http://my.oschina.net/joanfen/blog/140146

#import "ViewController.h"
#import "TKAddressBook.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *tempAddressBookAry;
    IBOutlet UITableView *m_tableView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tempAddressBookAry = [[NSMutableArray alloc]init];
    [self getAddressBookInfo];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)getAddressBookInfo
{

    //新建一个通讯类
    ABAddressBookRef addressBooks = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
        addressBooks = ABAddressBookCreateWithOptions(NULL, NULL);
        //获取通讯录权限
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    //获取通讯录中的所有人
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    
    //通讯录中的人数
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    //循环，获取每个人的个人信息
    for (int i = 0; i< nPeople; i++) {
        //新建一个addressBook model类
        TKAddressBook *addressBook = [[TKAddressBook alloc]init];
        
        //获取个人
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        //获取个人名字
        CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        NSString * nameString = (__bridge NSString *)abName;
        NSString * lastNameString = (__bridge NSString *)abLastName;
        
        if ((__bridge NSString *)abFullName) {
            nameString = (__bridge NSString *)abFullName;
        }else{
            if ((__bridge NSString *)abLastName) {
                nameString = [NSString stringWithFormat:@"%@ %@",nameString,lastNameString];
            }
        }
        
        addressBook.m_name = nameString;
        addressBook.m_recordID = (int)ABRecordGetRecordID(person);
        
        ABPropertyID multiProperties[] = {
            kABPersonPhoneProperty,
            kABPersonEmailProperty
        };
        //multiProperties数组的类型为ABPropertyID的元素总数
        NSInteger multiPropertiesTotal = sizeof(multiProperties)/sizeof(ABPropertyID);
        
        for (int j = 0; j<multiPropertiesTotal; j++) {
            ABPropertyID property = multiProperties[j];
            ABMultiValueRef valueRef = ABRecordCopyValue(person, property);
            NSInteger valueCount = 0;
            if (valueRef) valueCount = ABMultiValueGetCount(valueRef);
            if (valueCount == 0) {
                CFRelease(valueRef);
                continue;
            }
           
            //获取电话号码和email
            for (int k = 0; k<valueCount; k++) {
                CFTypeRef value = ABMultiValueCopyValueAtIndex(valueRef, k);
                switch (j) {
                    case 0://电话号码
                    {
                        addressBook.m_tel = (__bridge NSString *)value;
                        
                    }
                        break;
                        case 1://电子邮箱
                    {
                        addressBook.m_email = (__bridge NSString *)value;
                    }
                        break;
                    default:
                        break;
                }
                CFRelease(value);
            }
            CFRelease(valueRef);
        }
        
        //将个人信息添加到数组中，循环完成后addressBookTemp中包含所有联系人的信息
        [tempAddressBookAry addObject:addressBook];
        
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
        
    }
}


#pragma --UItableViewDataSourceDelegate--
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tempAddressBookAry count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"contactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
    }
    
    TKAddressBook *addressBook = [tempAddressBookAry objectAtIndex:indexPath.row];
    cell.textLabel.text = addressBook.m_name;
    cell.detailTextLabel.text = addressBook.m_tel;
    
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
