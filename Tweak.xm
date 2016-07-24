/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/
#import <IOKit/IOKitLib.h>
#import <substrate.h>
#import <Foundation/Foundation.h>

int maybe(){
  static int seeded = 0;
  if(!seeded){
    srand(time(NULL));
    seeded = 1;
  }
  return !(rand() % 100);
}

unsigned int random_int() {
	unsigned int i = 0;
    unsigned int v = 0;
    unsigned char buffer[4];
	for (i = 0; i < 4; i++) {
		buffer[i] = rand() & 0xFF;
	}
    v = *(unsigned int*) buffer;
	return v;
}

void flip_bit(void* buf, size_t len){
  if (!len)
    return;
  size_t offset = rand() % len;
  ((uint8_t*)buf)[offset] ^= (0x01 << (rand() % 8));
}

static kern_return_t (*old_IOConnectCallMethod)(
	mach_port_t connection,
  uint32_t    selector,
  uint64_t   *input,
  uint32_t    inputCnt,
  void       *inputStruct,
  size_t      inputStructCnt,
  uint64_t   *output,
  uint32_t   *outputCnt,
  void       *outputStruct,
  size_t     *outputStructCntP);

kern_return_t fake_IOConnectCallMethod(
  mach_port_t connection,
  uint32_t    selector,
  uint64_t   *input,
  uint32_t    inputCnt,
  void       *inputStruct,
  size_t      inputStructCnt,
  uint64_t   *output,
  uint32_t   *outputCnt,
  void       *outputStruct,
  size_t     *outputStructCntP)
{
	bool didFuzz = 0;
	if (((arc4random() % 2000) % 7) == 0)
	{
		didFuzz = 1;
		NSLog(@"fake_IOConnectCallMethod called, we up in this bitch... flipping #1\n");
		flip_bit(input, sizeof(input) * inputCnt);
		//ret = randomize_string((unsigned char*)input, sizeof(input) * inputCnt, 25);
	}
	if (((arc4random() % 2000) % 7) == 0)
	{
		didFuzz = 1;
		NSLog(@"fake_IOConnectCallMethod called, we up in this bitch... flipping #2\n");
		flip_bit(inputStruct, inputStructCnt);
		//ret = randomize_string((unsigned char*)inputStruct, inputStructCnt, 25);
	}

	if (didFuzz)
	{
		NSMutableArray *caseData = [[NSMutableArray alloc] init];
		[caseData addObject:@"testcase"];
		[caseData addObject:@(selector)];

		NSLog(@"TESTCASE::: %@", caseData);
	}
	
	return old_IOConnectCallMethod(
		connection,
		selector,
		input,
		inputCnt,
		inputStruct,
		inputStructCnt,
		output,
		outputCnt,
		outputStruct,
		outputStructCntP);
}


%ctor {
	MSHookFunction((int *)&IOConnectCallMethod, (int *)&fake_IOConnectCallMethod, (void **)&old_IOConnectCallMethod);
      
}