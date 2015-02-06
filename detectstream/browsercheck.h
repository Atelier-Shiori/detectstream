//
//  browsercheck.h
//  detectstream
//
//  Created by 高町なのは on 2015/02/06.
//  Copyright (c) 2014, Atelier Shiori and James M.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface browsercheck : NSObject
-(BOOL)checkIdentifier:(NSString*)identifier;
-(NSString *)checkURL:(NSString *)url;
@end