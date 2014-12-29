//
//  TKAddressBook.h
//  AddressBookDemo
//
//  Created by chenhao on 14/12/29.
//  Copyright (c) 2014年 chenhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKAddressBook : NSObject
@property NSInteger m_sectionNum;
@property NSInteger m_recordID;
@property (nonatomic,strong)NSString *m_name;
@property (nonatomic,strong)NSString *m_email;
@property (nonatomic,strong)NSString *m_tel;
@end
