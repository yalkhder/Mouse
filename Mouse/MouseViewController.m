//
//  MouseViewController.m
//  Mouse
//
//  Created by Yasser Al-Khder on 2/21/2014.
//  Copyright (c) 2014 Yasser Al-Khder. All rights reserved.
//

#import "MouseViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface MouseViewController () <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *mouseMoveCharacteristic;

@end

@implementation MouseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Will do bluetooth setup here for now. Refactor later.
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIGestureRecognizer Actions

- (IBAction)moveMouse:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"pan started");
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [sender translationInView:self.view];
        NSLog(@"pan changed: %f %f", point.x, point.y);
        NSData *pointData = [NSData dataWithBytes:&point length:sizeof(CGPoint)];
        // One way of decoding
//        CGPoint pointFromData;
//        [pointData getBytes:&pointFromData length:sizeof(CGPoint)];
//        NSLog(@"%f %f", pointFromData.x, pointFromData.y);
        
        // Another way (Don't know which is "better"
//        CGPoint *pointFromData = (CGPoint *)[pointData bytes];
//        NSLog(@"%f %f", pointFromData->x, pointFromData->y);
        
        self.mouseMoveCharacteristic.value = pointData;
        
        [sender setTranslation:CGPointZero inView:self.view];
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"pan ended");
    }
}

- (IBAction)leftClick:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        
        NSLog(@"left click");
    }
}


- (IBAction)rightClick:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        
        NSLog(@"right click");
    }
}

#pragma mark - CBPeripheralManager Delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth is Off"
                                                            message:@"Please make sure bluetooth is activated"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        NSLog(@"Powered Off");
    }
    
    else if(peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        // Will probably change as needed.
        CBUUID *mousePanCharacteristicUUID = [CBUUID UUIDWithString:@"17D3EE2B-5464-42D9-B9BC-416F7DDC9335"];
        CBUUID *mouseServiceUUID = [CBUUID UUIDWithString:@"E5F03A91-9C62-4570-9E55-3489B4510AAB"];
        
        self.mouseMoveCharacteristic = [[CBMutableCharacteristic alloc] initWithType:mousePanCharacteristicUUID properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
        
        CBMutableService *mouseService = [[CBMutableService alloc] initWithType:mouseServiceUUID primary:YES];
        mouseService.characteristics = @[self.mouseMoveCharacteristic];
        
        [self.peripheralManager addService:mouseService];
        
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey:@[mouseService.UUID] }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Add service error: %@", [error localizedDescription]);
    }
    
    else {
        NSLog(@"Service %@ added", service.UUID.data);
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"Advertising error: %@", [error localizedDescription]);
    }
    else {
        NSLog(@"Started Advertising");
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"Did Recieve Read Request");
}



@end
