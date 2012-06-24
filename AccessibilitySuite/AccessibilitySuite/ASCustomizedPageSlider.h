//
//  ASCustomizedPageSlider.h
//
//  Created by Doug Russell
//  Copyright (c) 2012 Doug Russell. All rights reserved.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  

#import <UIKit/UIKit.h>

// IMPORTANT: Don't actually use this class, it's just a demonstration of how to make a custom slider accessible. Use UISlider, it's much better.

@interface ASCustomizedPageSlider : UIControl

@property (nonatomic) float value;
@property (nonatomic) float minValue;
@property (nonatomic) float maxValue;

@end
