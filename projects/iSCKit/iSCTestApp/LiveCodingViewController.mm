/************************************************************************
 *
 * Copyright 2015 Kengo Watanabe <kengo@wdkk.co.jp>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 ************************************************************************/

#import "LiveCodingViewController.h"
#import "iSCController.h"

@implementation LiveCodingViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{

	}
	return self;
}

- (void) viewDidLoad
{
    self.view.backgroundColor = [UIColor lightGrayColor];
    [iSC interpret:@"a = {SinOsc.ar()}.play"];
}

@end
