//
//  AppDelegate.m
//  DUCEPRO
//
//  Created by Shubham Sorte on 28/10/15.
//  Copyright © 2015 appvaders. All rights reserved.
//

#import "AppDelegate.h"

#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>


@interface AppDelegate ()

@end

static Rdio * _rdioInstance;

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (Rdio *)sharedRdio
{
    if (_rdioInstance == nil) {
        _rdioInstance = [[Rdio alloc] initWithClientId:@"evmv6322brdixbus35sty7f6ya"
                                             andSecret:@"9CRVzbGmpu2q5GEZv9qGhw"
                                              delegate:nil];
    }
    return _rdioInstance;
	
	
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    Rdio *r = [AppDelegate sharedRdio];
    
    self.client = [MSClient clientWithApplicationURLString:@"https://echo.azure-mobile.net/"
                                            applicationKey:@"TpNuzgZVBTGbDXgbraqvNwbMpaACob38"];
	
	[Parse enableLocalDatastore];
	
    [Parse setApplicationId:PARSE_APPLICATION_ID clientKey:PARSE_CLIENT_KEY];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
	[Fabric with:@[[Twitter class]]];
	
	[[UINavigationBar appearance] setBackgroundColor:GLOBAL_BACK_COLOR];
	[[UINavigationBar appearance] setBarTintColor:GLOBAL_BACK_COLOR];
	[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: GLOBAL_TINT_COLOR}];
	
	[[UISearchBar appearance] setTintColor:GLOBAL_TINT_COLOR];
	
	[[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setDefaultTextAttributes:@{NSForegroundColorAttributeName: GLOBAL_TINT_COLOR, NSFontAttributeName: [UIFont systemFontOfSize:13.f]}];
	
	[SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
	[SVProgressHUD setBackgroundColor:GLOBAL_BACK_COLOR];
	[SVProgressHUD setForegroundColor:GLOBAL_TINT_COLOR];
	[SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
	
	[[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveMessagesOnParse:(id<SINMessage>)message {
    PFQuery *query = [PFQuery queryWithClassName:@"SinchMessage"];
    [query whereKey:@"messageId" equalTo:[message messageId]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *messageArray, NSError *error) {
        if (!error) {
            // If the SinchMessage is not already saved on Parse (an empty array is returned), save it.
            if ([messageArray count] <= 0) {
                PFObject *messageObject = [PFObject objectWithClassName:@"SinchMessage"];
                
                messageObject[@"messageId"] = [message messageId];
                messageObject[@"senderId"] = [message senderId];
                messageObject[@"recipientId"] = [message recipientIds][0];
                messageObject[@"text"] = [message text];
                messageObject[@"timestamp"] = [message timestamp];
                
                [messageObject saveInBackground];
            }
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}

- (void)sendTextMessage:(NSString *)messageText toRecipient:(NSString *)recipientId {
    SINOutgoingMessage *outgoingMessage = [SINOutgoingMessage messageWithRecipient:recipientId text:messageText];
    [self.sinchClient.messageClient sendMessage:outgoingMessage];
}


- (void)initSinchClient:(NSString*)userId {
    self.sinchClient = [Sinch clientWithApplicationKey:SINCH_APPLICATION_KEY
                                     applicationSecret:SINCH_APPLICATION_SECRET
                                       environmentHost:@"sandbox.sinch.com"
                                                userId:userId];
    self.sinchClient.delegate = self;
    [self.sinchClient setSupportMessaging:YES];
    [self.sinchClient start];
    [self.sinchClient startListeningOnActiveConnection];
    
}



#pragma mark SINClientDelegate methods

- (void)clientDidStart:(id<SINClient>)client {
    NSLog(@"Start SINClient successful!");
    self.sinchMessageClient = [self.sinchClient messageClient];
    self.sinchMessageClient.delegate =  self;
}

- (void)clientDidFail:(id<SINClient>)client error:(NSError *)error {
    NSLog(@"Start SINClient failed. Description: %@. Reason: %@.", error.localizedDescription, error.localizedFailureReason);
}


#pragma mark SINMessageClientDelegate methods

// Receiving an incoming message.
- (void)messageClient:(id<SINMessageClient>)messageClient didReceiveIncomingMessage:(id<SINMessage>)message {
    [self saveMessagesOnParse:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:SINCH_MESSAGE_RECIEVED object:self userInfo:@{@"message" : message}];
}

// Finish sending a message
- (void)messageSent:(id<SINMessage>)message recipientId:(NSString *)recipientId {
    [self saveMessagesOnParse:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:SINCH_MESSAGE_SENT object:self userInfo:@{@"message" : message}];
    
}

// Failed to send a message
- (void)messageFailed:(id<SINMessage>)message info:(id<SINMessageFailureInfo>)messageFailureInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:SINCH_MESSAGE_FAILED object:self userInfo:@{@"message" : message}];
    NSLog(@"MessageBoard: message to %@ failed. Description: %@. Reason: %@.", messageFailureInfo.recipientId, messageFailureInfo.error.localizedDescription, messageFailureInfo.error.localizedFailureReason);
}

-(void)messageDelivered:(id<SINMessageDeliveryInfo>)info
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SINCH_MESSAGE_DELIVERED object:info];
}

// Core Data additions

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) \
        {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            
        }
        
    }
    
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DUCEPRO_CoreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    
    if (_persistentStoreCoordinator != nil)
    {
        
        return _persistentStoreCoordinator;
    
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TechTatva15.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }
    
    return _persistentStoreCoordinator;
    
}

@end
