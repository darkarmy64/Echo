
#import "MNCChatMateListViewController.h"
#import "MusicChatViewController.h"

@interface MNCChatMateListViewController ()

@end



@implementation MNCChatMateListViewController
@synthesize chatMatesArray, myUserId;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"@%@", self.myUserId];
    
    self.chatMatesArray = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.activeDialogViewController = nil;  /* add this line */
    [self retrieveChatMatesFromParse];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Segue to open a dialog
    if ([segue.identifier isEqualToString:@"OpenDialogSegue"]) {
        self.activeDialogViewController = segue.destinationViewController;
        //        NSInteger chatMateIndex = [[self.tableView indexPathForCell:(UITableViewCell *)sender] row];
        NSInteger actualIndex = [[self.tableView indexPathForSelectedRow] row];
        self.activeDialogViewController.chatMateId = self.chatMatesArray[actualIndex];
        self.activeDialogViewController.myUserId = self.myUserId;   /* add this line */
        return;
    }
}

- (void)dealloc {
    //Logout current user
    [PFUser logOut];
}





- (void)retrieveChatMatesFromParse {
	//    [self.chatMatesArray removeAllObjects];
	
	PFQuery *query = [PFUser query];
	[query orderByAscending:@"username"];
	[query whereKey:@"username" notEqualTo:self.myUserId];
	
	//    __weak typeof(self) weakSelf = self;
	[query findObjectsInBackgroundWithBlock:^(NSArray *chatMateArray, NSError *error) {
		if (!error) {
			NSMutableArray *chatMatesArrayNew = [[NSMutableArray alloc] init];
			for (int i = 0; i < [chatMateArray count]; i++) {
				[chatMatesArrayNew addObject:chatMateArray[i][@"username"]];
			}
			//            [weakSelf.tableView reloadData];
			self.chatMatesArray = [NSMutableArray arrayWithArray:chatMatesArrayNew];
			[self.tableView reloadData];
		} else {
			NSLog(@"Error: %@", error.description);
		}
	}];
}

- (IBAction)logoutAction:(id)sender {
	UIAlertController *alertContoller = [UIAlertController alertControllerWithTitle:@"Logout?" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
	UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
								   {
									   [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
										   [self dismissViewControllerAnimated:YES completion:^{
											   
										   }];
									   }];
									   
								   }];
	[alertContoller addAction:cancelAction];
	[alertContoller addAction:deleteAction];
	[self presentViewController:alertContoller animated:YES completion:^{ }];
}


#pragma mark UITableViewDataSource protocol methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.chatMatesArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 10.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
	return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatMateListPrototypeCell" forIndexPath:indexPath];
    NSString *chatMateId = [self.chatMatesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = chatMateId;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"OpenDialogSegue" sender:self];
}
@end
