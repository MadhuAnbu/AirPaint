//
//  VariousStuffViewController.m
//  AirPaint2
//
//  Created by Philipp Sessler on 07.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "VariousStuffViewController.h"
#import "MenuPoint.h"

@implementation VariousStuffViewController

- (id)initWithCanvasViewController:(CanvasViewController*) viewController {
    
    self = [super initWithIcon:[UIImage imageNamed:@"quit_icon.png"] andCanvasViwController:viewController];
    
    if (self) {
        appDelegate = [[UIApplication sharedApplication] delegate];
        [canvasViewController setVariousStuffViewController:self];
        library = [[ALAssetsLibrary alloc] init];
        activity = 	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActionSheetStyleBlackTranslucent];
        activity.hidesWhenStopped = YES;
        displayStartRow = 0;
    }
    

    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    // background image (frame)
    backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"variousStuff.png"]];
    self.view.frame = CGRectMake(
                                 (self.view.frame.size.height - backgroundImageView.frame.size.width)/2,
                                 (self.view.frame.size.width - backgroundImageView.frame.size.height)/2 , 
                                 backgroundImageView.frame.size.width, 
                                 backgroundImageView.frame.size.height);    
    [self.view setBackgroundColor:[UIColor clearColor]];    
    [self.view addSubview:backgroundImageView];
    
    activity.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    activity.alpha = 0.0;
    [self.view addSubview:activity];
    
    menuTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 50, self.view.frame.size.width - 20, self.view.frame.size.height - 70) style:UITableViewStylePlain];
    
    [menuTable setDelegate:self];
    [menuTable setDataSource:self];
    [menuTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [menuTable setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:menuTable];
 
    // scrollArrow
    arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down.png"]];
    CGRect frame = arrowImageView.frame;
    frame.origin = CGPointMake(backgroundImageView.frame.size.width - frame.size.width - 30, backgroundImageView.frame.size.height - frame.size.height - 40);
    arrowImageView.frame = frame;
    arrowImageView.alpha = 0.0;
    [self.view addSubview:arrowImageView];
    arrowDown = YES;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void) viewDidAppear:(BOOL)animated {
    canvasViewController.variousStuffIsActive = YES;
    [[appDelegate shoeConnection] sendMessage:@"trackFingerCountSwipeStart" withAck:YES];
    [canvasViewController hideCursor];
    FLog(@"Various Stuff start");

}



// --------------------------

- (void) saveCanvasToPhotoAlbum {
    
    canvasSaved = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        menuTable.alpha = 0.0;
    } completion:^(BOOL finished){
        activity.alpha = 1.0;
        [activity startAnimating];
        timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/2.0) target:self selector:@selector(activityTimer) userInfo:nil repeats:YES];
        
        [library saveImage:[[canvasViewController canvasHolder] getSnapshotImage] toAlbum:@"AirPaint Images" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Big error: %@", [error description]);
            } else {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"Image saved successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }];
        
        canvasSaved = YES;

    }];    
    
        
}

- (void) activityTimer
{
    if (canvasSaved) {
    
        [timer invalidate];
        
        [activity stopAnimating];
    
        menuTable.alpha = 1.0;
        activity.alpha = 0.0;
        [self quit];
        
    } else {
        [activity startAnimating];
    }
    
}
// --------------------------


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [appDelegate.configurationsViewController.numberOfChoicesVariouStuff.text intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *MyCellIdentifier = @"MyCellIdentifier";
    
    MenuPoint *cell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if(cell == nil) {
        cell = [[MenuPoint alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyCellIdentifier] ;
    }
    
    

    [[cell numberLabel] setText:[NSString stringWithFormat:@"%i", indexPath.row + 1 - (int)(indexPath.row / 5)*5]];
    
    switch (indexPath.row) {
        case 0:
            [[cell menuText] setText:@"Erease canvas"];
            break;
        case 1:
            [[cell menuText] setText:@"Save picture"];
            break;
        case 2:
            [[cell menuText] setText:@"Browse gallery"];
            break;
        default:
            [[cell menuText] setText:[NSString stringWithFormat:@"Menu point %i", indexPath.row+1]];
            break;
    }
    
    return cell;

}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)performSelectAction:(id)sender  {
   
  
    NSLog(@"selected row: %i", [menuTable indexPathForSelectedRow].row);

    int row = [menuTable indexPathForSelectedRow].row;

    switch (row) {
        case 0:
            [[canvasViewController canvasHolder] eraseToIndex:-1 finished:YES];
            [self quit];
            break;
        case 1: 
            [self saveCanvasToPhotoAlbum];
            return;
            
            break;
        case 2:
            [appDelegate showGallery];
            [self quit];
            break;
        default:
            break;
    }
    
    

}

// ----------------------------

- (void) selectMenuPoint:(int) index {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(displayStartRow+index-1) inSection:0];
    
    [menuTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [[menuTable delegate] tableView:menuTable didSelectRowAtIndexPath:indexPath];
}

- (void) increaseSelectedMenuPoint {
    
    
    MenuPoint *point = (MenuPoint*)[menuTable cellForRowAtIndexPath:[menuTable indexPathForSelectedRow]];
 
    if(point.progress.progress >= 1.0)
        return;
    
    [point.progress setProgress: [point progress].progress + 0.02];
        
    if([point progress].progress >= 1.0) {
        [self performSelectAction:self];
    }
}

- (void) deselectSelectedMenuPoint {
    
    MenuPoint *point = (MenuPoint*)[menuTable cellForRowAtIndexPath:[menuTable indexPathForSelectedRow]];
    
    if(point!=nil) {
        [point.progress setProgress: 0];
        
        [menuTable deselectRowAtIndexPath:[menuTable indexPathForSelectedRow] animated:YES];

        [point setSelected:NO animated:NO];
    }
}


- (void) quit {
    
    [self deselectSelectedMenuPoint];
    [[appDelegate shoeConnection] sendMessage:@"backToNormalTracking" withAck:YES];
    canvasViewController.variousStuffIsActive = NO;
    [canvasViewController.sidebarViewController deselectMenuPoint];
    [canvasViewController hidePopup];
    [canvasViewController hideSidebar:self];
    [canvasViewController showCursor];
    
    FLog(@"Various Stuff finished");

}

- (void) scrollMenuDown 
{
    if(displayStartRow + 5 >= [menuTable numberOfRowsInSection:0]) {
        return ;
    } else {
        
        if(arrowDown) {
            arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            arrowDown = NO;
        }
        
        
        arrowImageView.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            arrowImageView.alpha = 0.7;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.5 animations:^{
                arrowImageView.alpha = 0.0;
            } completion:^(BOOL finished){
                
            }];   
        }];  
        
        [menuTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:displayStartRow+5 
                                                             inSection:0] 
                         atScrollPosition:UITableViewScrollPositionTop animated:YES];
        displayStartRow += 5;
    }
    
    
    
   
}

- (void) scrollMenuUp 
{
    
    
    
    
    if(displayStartRow==0) {
        return ;
    } else if(displayStartRow - 5 >= 0) {
        [menuTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:displayStartRow-5 
                                                             inSection:0] 
                         atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
        displayStartRow -= 5;
    
        
        if(!arrowDown) {
            arrowImageView.transform = CGAffineTransformIdentity;
            arrowDown = YES;
        }
        
        
        arrowImageView.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            arrowImageView.alpha = 0.7;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.5 animations:^{
                arrowImageView.alpha = 0.0;
            } completion:^(BOOL finished){
                
            }];   
        }];    

    }

}

@end
