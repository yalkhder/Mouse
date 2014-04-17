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

- (NSData *)dataFromPoint:(CGPoint)point {
    int64_t pointArray [2] = { (int64_t)point.x, (int64_t)point.y };
    NSData *pointData = [NSData dataWithBytes:&pointArray length:sizeof(int64_t)*2];
    return pointData;
}

#pragma mark - UIGestureRecognizer Actions

- (IBAction)moveMouse:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"pan started");
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [sender translationInView:self.view];
        NSLog(@"pan changed: %f %f", point.x, point.y);
        
        self.mouseMoveCharacteristic.value = [self dataFromPoint:point];
        [self.peripheralManager updateValue:self.mouseMoveCharacteristic.value forCharacteristic:self.mouseMoveCharacteristic onSubscribedCentrals:nil];
        
        [sender setTranslation:CGPointZero inView:self.view];
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender translationInView:self.view];
        NSLog(@"pan ended with point: %f %f", point.x, point.y);
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
        
//        self.mouseMoveCharacteristic = [[CBMutableCharacteristic alloc] initWithType:mousePanCharacteristicUUID properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
        
        self.mouseMoveCharacteristic = [[CBMutableCharacteristic alloc] initWithType:mousePanCharacteristicUUID properties:CBCharacteristicPropertyNotify| CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
        
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
    if ([request.characteristic.UUID isEqual:self.mouseMoveCharacteristic.UUID]) {
        if (request.offset > self.mouseMoveCharacteristic.value.length) {
            [peripheral respondToRequest:request withResult:CBATTErrorInvalidOffset];
            return;
        }
        request.value = self.mouseMoveCharacteristic.value;
        NSLog(@"request.value: %@", request.value);

        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Central Subscribed");
}

@end
