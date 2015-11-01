#import "MNCLoginViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"


@interface MNCLoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *promptLabel;

@property (strong, nonatomic) IBOutlet UITextField *usernameField;

@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end



@implementation MNCLoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"User"] != nil)
    {
        [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
        return;
    }
    
    self.navigationItem.title = @"ECHO";
    self.promptLabel.hidden = YES;
    UITapGestureRecognizer *tapViewGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnView)];
    [self.view addGestureRecognizer:tapViewGR];
	
	[self.usernameField becomeFirstResponder];
	
	// Remove this later
	self.usernameField.text = @"shorteswag";
	self.passwordField.text = @"echo";
	
	self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
	
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
		UINavigationController *navc = [segue destinationViewController];
        MNCChatMateListViewController *destViewController = [navc.viewControllers firstObject];
        destViewController.myUserId = self.usernameField.text;
    }
}
// Tab the view to dismiss keyboard
- (void)didTapOnView {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.usernameField)
		[self.passwordField becomeFirstResponder];
	else
		[self login:self];
	return YES;
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	UINavigationController *navC = [self.storyboard instantiateViewControllerWithIdentifier:@"mainVcNav"];
//	ViewController *vc = [navC.viewControllers firstObject];
	[self presentViewController:navC animated:YES completion:nil];
}

- (IBAction)signup:(id)sender {
    PFUser *pfUser = [PFUser user];
    pfUser.username = self.usernameField.text;
    pfUser.password = self.passwordField.text;
    
    __weak typeof(self) weakSelf = self;
    [pfUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            weakSelf.promptLabel.textColor = [UIColor greenColor];
            weakSelf.promptLabel.text = @"Signup successful!";
            weakSelf.promptLabel.hidden = NO;
            [weakSelf login:nil];
            
        } else {
            weakSelf.promptLabel.textColor = [UIColor redColor];
            weakSelf.promptLabel.text = [error userInfo][@"error"];
            weakSelf.promptLabel.hidden = NO;
        }
    }];
}

- (IBAction)login:(id)sender {
	
	[SVProgressHUD showWithStatus:@"Loading..."];
	
    __weak typeof(self) weakSelf = self;
    [PFUser logInWithUsernameInBackground:self.usernameField.text
                                 password:self.passwordField.text
                                    block:^(PFUser *pfUser, NSError *error)
     {
         if (pfUser && !error) {
             // Proceed to next screen after successful login.
             weakSelf.promptLabel.hidden = YES;
             //add this
             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             [appDelegate initSinchClient:self.usernameField.text];
             //
             [weakSelf performSegueWithIdentifier:@"LoginSegue" sender:self];
          
             
         } else {
             // The login failed. Show error.
             weakSelf.promptLabel.textColor = [UIColor redColor];
             weakSelf.promptLabel.text = [error userInfo][@"error"];
             weakSelf.promptLabel.hidden = NO;
         }
		 
		 [SVProgressHUD dismiss];
		 
     }];
}


@end
