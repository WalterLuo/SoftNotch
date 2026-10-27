////
////  NSObject.h
////  SoftNotch
////
////  Created by Shariq Charolia on 2025-09-18.
////
//
//
//
//#import "IMessageService.h"
//
//// Import the specific private headers from your project using quotes
//#import "IMAccountController.h"
//#import "IMChatRegistry.h"
//#import "IMChat.h"
//#import "IMMessage.h"
//#import "IMMessageItem-IMChat_Internal.h"
////#import "IMHandle.h"
//#import "IMChatHistoryController.h"
//#import "TUCallCenter.h"
//#import "TUCall.h"
//#import "TUAnswerRequest.h"
//#import "TUHandle.h"
//// We don't need to import IMCore.h or TelephonyUtilities.h directly
//
//// MARK: - Manual Private API Declarations
//
//// Manually declare the notification constant because its header is not available.
//// The actual string value will be linked at runtime.
//extern NSString * const TUCallCenterCallStatusChangedNotification;
//
//// Re-declare the category for the private method on TUCallCenter
//@interface TUCallCenter (Private)
//- (TUCall *)callWithUUID:(NSUUID *)uuid;
//@end
//
//
//// The rest of your file starts here...
////@implementation IMessageService
//
//
//// For nicer logging of dictionaries and arrays
//@interface NSObject (Logging)
//- (NSString *)prettyDescription;
//@end
//
//@implementation NSObject (Logging)
//- (NSString *)prettyDescription {
//    if ([self isKindOfClass:[NSDictionary class]] || [self isKindOfClass:[NSArray class]]) {
//        NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
//        if (data) {
//            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        }
//    }
//    return [self description];
//}
//@end
//
//
//@implementation IMessageService
//
//+ (instancetype)sharedInstance {
//    static IMessageService *sharedInstance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedInstance = [[self alloc] init];
//    });
//    return sharedInstance;
//}
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        NSLog(@"[SoftNotchHelper] IMessageService initializing...");
//        [self setupListeners];
//    }
//    return self;
//}
//
//- (void)setupListeners {
//    NSLog(@"[SoftNotchHelper] Attaching listeners for Messages and FaceTime...");
//    
//    // Listen for new iMessages
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(messageReceived:)
//                                                 name:@"__IMChatRegistryMessageReceivedNotification"
//                                               object:nil];
//                                               
//    // Listen for FaceTime call status changes
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(callStatusChanged:)
//                                                 name:TUCallCenterCallStatusChangedNotification
//                                               object:[TUCallCenter sharedInstance]];
//    NSLog(@"[SoftNotchHelper] Listeners attached.");
//}
//
//- (void)messageReceived:(NSNotification *)notification {
//    // MARK: - LOGGING
//    NSLog(@"[SoftNotchHelper] <<< EVENT: Received '__IMChatRegistryMessageReceivedNotification' notification.");
//    NSLog(@"[SoftNotchHelper] Raw Notification UserInfo: %@", [notification.userInfo prettyDescription]);
//
//    IMMessage *message = notification.userInfo[@"__IMMessage"];
//    if (!message) {
//        NSLog(@"[SoftNotchHelper] Notification did not contain an IMMessage object. Ignoring.");
//        return;
//    }
//
//    // MARK: - LOGGING
//    NSLog(@"[SoftNotchHelper] Raw IMMessage Object:\n%@", message);
//
//    if (message.isFromMe) {
//        NSLog(@"[SoftNotchHelper] Message is from me. Ignoring.");
//        return;
//    }
//    if (message.isSystemMessage) {
//        NSLog(@"[SoftNotchHelper] Message is a system message. Ignoring.");
//        return;
//    }
//    
//    NSDictionary *messageData = @{
//        @"guid": message.guid ?: [NSNull null],
//        @"chatGuid": message._imMessageItem.parentChatID ?: [NSNull null],
//        @"text": message.text.string ?: @"",
//        @"sender": message.sender.ID ?: [NSNull null],
//        @"isAudioMessage": @(message.isAudioMessage),
//        @"isRead": @(message.isRead),
//        @"time": @([message.time timeIntervalSince1970])
//    };
//    
//    // MARK: - LOGGING
//    NSLog(@"[SoftNotchHelper] >>> FORWARDING to Swift (onMessageReceived):\n%@", [messageData prettyDescription]);
//    
//    if (self.onMessageReceived) {
//        self.onMessageReceived(messageData);
//    }
//}
//
//- (void)callStatusChanged:(NSNotification *)notification {
//    // MARK: - LOGGING
//    NSLog(@"[SoftNotchHelper] <<< EVENT: Received 'TUCallCenterCallStatusChangedNotification' notification.");
//    
//    TUCall *call = notification.object;
//    if (!call) {
//        NSLog(@"[SoftNotchHelper] Call status notification did not contain a TUCall object. Ignoring.");
//        return;
//    }
//
//    // MARK: - LOGGING
//    NSLog(@"[SoftNotchHelper] Raw TUCall Object:\n%@", call);
//
//    NSDictionary *callData = @{
//        @"callUUID": call.uniqueProxyIdentifier ?: [NSNull null],
//        @"status": @(call.status),
//        @"isOutgoing": @(call.isOutgoing),
//        @"isIncoming": @(call.isIncoming),
//        @"isOnHold": @(call.isOnHold),
//        @"handle": call.handle.value ?: [NSNull null],
//        @"callerName": call.callerNameFromNetwork ?: [NSNull null]
//    };
//
//    // MARK: - LOGGING
//    NSLog(@"[SoftNotchHelper] >>> FORWARDING to Swift (onCallStatusChanged):\n%@", [callData prettyDescription]);
//    
//    if (self.onCallStatusChanged) {
//        self.onCallStatusChanged(callData);
//    }
//}
//
//// Main command router
//- (void)handleCommand:(NSDictionary *)command {
//    NSString *action = command[@"action"];
//    NSDictionary *data = command[@"data"];
//    NSString *transactionId = command[@"transactionId"];
//
//    // MARK: - LOGGING
//    NSLog(@"[SoftNotchHelper] <<< COMMAND received from Swift: '%@' with data:\n%@", action, [data prettyDescription]);
//
//    if ([action isEqualToString:@"send-message"]) {
//        [self handleSendMessage:data transactionId:transactionId];
//    } else if ([action isEqualToString:@"send-reaction"]) {
//        [self handleSendReaction:data transactionId:transactionId];
//    } else if ([action isEqualToString:@"answer-call"]) {
//        [self handleAnswerCall:data transactionId:transactionId];
//    } else if ([action isEqualToString:@"hangup-call"]) {
//        [self handleHangupCall:data transactionId:transactionId];
//    } else {
//        NSLog(@"[SoftNotchHelper] WARN: Unhandled command action '%@'", action);
//    }
//}
//
//// MARK: - Command Handlers
//
//- (void)handleSendMessage:(NSDictionary *)data transactionId:(NSString *)transactionId {
//    NSString *chatGuid = data[@"chatGuid"];
//    NSString *messageText = data[@"message"];
//    
//    NSLog(@"[SoftNotchHelper] Attempting to send message '%@' to chat '%@'", messageText, chatGuid);
//    
//    IMChat *chat = [[IMChatRegistry sharedInstance] existingChatWithGUID:chatGuid];
//    if (chat && messageText) {
//        NSLog(@"[SoftNotchHelper] Found IMChat object: %@", chat);
//        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:messageText];
//        IMMessage *message = [IMMessage instantMessageWithText:attrString messageSubject:nil flags:0];
//        
//        NSLog(@"[SoftNotchHelper] Created IMMessage object: %@", message);
//        [chat sendMessage:message];
//        NSLog(@"[SoftNotchHelper] sendMessage: called. Message is now queued for sending.");
//        // Note: Success/failure is asynchronous and not easily tracked here.
//    } else {
//        NSLog(@"[SoftNotchHelper] ERROR: Could not find chat with GUID '%@' or message text was nil.", chatGuid);
//    }
//}
//
//- (void)handleSendReaction:(NSDictionary *)data transactionId:(NSString *)transactionId {
//    NSString *reactionType = data[@"reactionType"];
//    NSString *messageGuid = data[@"messageGuid"];
//    NSString *chatGuid = data[@"chatGuid"];
//    
//    NSLog(@"[SoftNotchHelper] Attempting to send reaction '%@' to message '%@' in chat '%@'", reactionType, messageGuid, chatGuid);
//    
//    IMChat *chat = [[IMChatRegistry sharedInstance] existingChatWithGUID:chatGuid];
//    if (!chat) {
//        NSLog(@"[SoftNotchHelper] ERROR: Could not find chat with GUID '%@' for reaction.", chatGuid);
//        return;
//    }
//    
//    long long reactionInt = [self parseReactionType:reactionType];
//    if (reactionInt == 0) {
//        NSLog(@"[SoftNotchHelper] ERROR: Invalid reaction type '%@'.", reactionType);
//        return;
//    }
//    
//    NSLog(@"[SoftNotchHelper] Loading original message with GUID '%@'...", messageGuid);
//    [[IMChatHistoryController sharedInstance] loadMessageWithGUID:messageGuid completionBlock:^(IMMessage *message) {
//        if (!message) {
//            NSLog(@"[SoftNotchHelper] ERROR: Could not find original message with GUID '%@' to react to.", messageGuid);
//            return;
//        }
//        
//        NSLog(@"[SoftNotchHelper] Found original message: %@", message);
//        
//        struct _NSRange range = NSMakeRange(0, [message.text length]);
//        NSDictionary *summaryInfo = @{@"amc":@1, @"ams":message.text.string ?: @""};
//        
//        IMMessage *reactionMessage = [IMMessage instantMessageWithAssociatedMessageContent:nil
//                                                                                      flags:5
//                                                                      associatedMessageGUID:message.guid
//                                                                    associatedMessageType:reactionInt
//                                                                     associatedMessageRange:range
//                                                                         messageSummaryInfo:summaryInfo];
//        
//        NSLog(@"[SoftNotchHelper] Created reaction IMMessage object: %@", reactionMessage);
//        [chat sendMessage:reactionMessage];
//        NSLog(@"[SoftNotchHelper] sendReaction: called. Reaction is now queued for sending.");
//    }];
//}
//
//- (long long)parseReactionType:(NSString *)reactionType {
//    NSString *lower = [reactionType lowercaseString];
//    if ([lower isEqualToString:@"love"]) return 2000;
//    if ([lower isEqualToString:@"like"]) return 2001;
//    if ([lower isEqualToString:@"dislike"]) return 2002;
//    if ([lower isEqualToString:@"laugh"]) return 2003;
//    if ([lower isEqualToString:@"emphasize"]) return 2004;
//    if ([lower isEqualToString:@"question"]) return 2005;
//    if ([lower isEqualToString:@"-love"]) return 3000;
//    if ([lower isEqualToString:@"-like"]) return 3001;
//    if ([lower isEqualToString:@"-dislike"]) return 3002;
//    if ([lower isEqualToString:@"-laugh"]) return 3003;
//    if ([lower isEqualToString:@"-emphasize"]) return 3004;
//    if ([lower isEqualToString:@"-question"]) return 3005;
//    return 0;
//}
//
//- (void)handleAnswerCall:(NSDictionary *)data transactionId:(NSString *)transactionId {
//    NSString *callUUID = data[@"callUUID"];
//    NSLog(@"[SoftNotchHelper] Attempting to answer call with UUID '%@'", callUUID);
//    
//    TUCall *call = [[TUCallCenter sharedInstance] callWithUUID:[[NSUUID alloc] initWithUUIDString:callUUID]];
//    
//    if (call && call.isIncoming) {
//        NSLog(@"[SoftNotchHelper] Found incoming TUCall object: %@", call);
//        TUAnswerRequest *request = [[TUAnswerRequest alloc] initWithCall:call];
//        NSLog(@"[SoftNotchHelper] Created TUAnswerRequest: %@", request);
//        [[TUCallCenter sharedInstance] answerWithRequest:request];
//        NSLog(@"[SoftNotchHelper] answerWithRequest: called.");
//    } else {
//        NSLog(@"[SoftNotchHelper] ERROR: Call not found or is not an incoming call. Current call object: %@", call);
//    }
//}
//
//- (void)handleHangupCall:(NSDictionary *)data transactionId:(NSString *)transactionId {
//    NSString *callUUID = data[@"callUUID"];
//    NSLog(@"[SoftNotchHelper] Attempting to hang up call with UUID '%@'", callUUID);
//    
//    TUCall *call = [[TUCallCenter sharedInstance] callWithUUID:[[NSUUID alloc] initWithUUIDString:callUUID]];
//    
//    if (call) {
//        NSLog(@"[SoftNotchHelper] Found TUCall object to hang up: %@", call);
//        [call disconnectWithReason:1]; // 1 = Ended by user
//        NSLog(@"[SoftNotchHelper] disconnectWithReason: called.");
//    } else {
//        NSLog(@"[SoftNotchHelper] ERROR: Call to hang up not found.");
//    }
//}
//
//- (void)dealloc {
//    NSLog(@"[SoftNotchHelper] IMessageService deallocating. Removing listeners.");
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//@end
