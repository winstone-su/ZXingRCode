/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ViewController.h"
#import "ViewControllerB.h"
#import "AppDelegate.h"

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.textView.text = @"http://github.com/TheLevelUp/ZXingObjC";
  [self updatePressed:nil];
}

#pragma mark - Events

- (IBAction)updatePressed:(id)sender {
  [self.textView resignFirstResponder];

  NSString *data = self.textView.text;
  if (data == 0) return;

  ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
  ZXBitMatrix *result = [writer encode:data
                                format:kBarcodeFormatQRCode
                                 width:self.imageView.frame.size.width
                                height:self.imageView.frame.size.width
                                 error:nil];

  if (result) {
    ZXImage *image = [ZXImage imageWithMatrix:result];
    self.imageView.image = [UIImage imageWithCGImage:image.cgimage];
  } else {
    self.imageView.image = nil;
  }
}

- (IBAction)selectImageClicked:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [[AppDelegate getAppDelegate].viewController presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark --delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    NSLog(@"123");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if(image == nil){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (image != nil) {
        CGImageRef imageToDecode = image.CGImage;
        
        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
        ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
        
        NSError *error = nil;
        
        // There are a number of hints we can give to the reader, including
        // possible formats, allowed lengths, and the string encoding.
        ZXDecodeHints *hints = [ZXDecodeHints hints];
        
        ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
        ZXResult *result = [reader decode:bitmap
                                    hints:hints
                                    error:&error];
        if (result) {
            // The coded result as a string. The raw data can be accessed with
            // result.rawBytes and result.length.
            NSString *contents = result.text;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:contents delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            // The barcode format, such as a QR code or UPC-A
            ZXBarcodeFormat format = result.barcodeFormat;
        } else {
            // Use error to determine why we didn't get a result, such as a barcode
            // not being found, an invalid checksum, or a format inconsistency.
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
