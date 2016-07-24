# kuzz
an ios iokit fuzzer

most of this code used and concepts executed are from Ian Beers research for google's project zero.

the MS dylib redirects any IOConnectCallMethod usage to a "fake" replacement that randomly fuzzes the input data. 
this is pretty fucking smart, thanks Ian. 

change the MS filters in kuzz.plist to control what you're fuzzing, by default its filtered into IOMobileFramebuffer and IOSurface.
by default you will fuzz all the things. 

feel free to fuzz away. 
