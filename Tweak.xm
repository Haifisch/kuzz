/* 
	Uh, greetz to Ian Beer of ProjectZero n shit.
	http://googleprojectzero.blogspot.com/2014/11/pwn4fun-spring-2014-safari-part-ii.html
	most of this code is his, i just wanted it to be injected into all of the things on my ipad so thanks to him

	greets to dat boi ethan & sn0w for help
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
	}
	if (((arc4random() % 2000) % 7) == 0)
	{
		didFuzz = 1;
		NSLog(@"fake_IOConnectCallMethod called, we up in this bitch... flipping #2\n");
		flip_bit(inputStruct, inputStructCnt);
	}

	if (didFuzz)
	{
		NSMutableArray *caseData = [[NSMutableArray alloc] init];
		[caseData addObject:@"testcase"];
		[caseData addObject:@(selector)];

		NSLog(@"TESTCASE ::: %@", caseData);
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