export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2222

include theos/makefiles/common.mk
export SDKVERSION=8.1

TWEAK_NAME = kuzz
kuzz_FILES = Tweak.xm
kuzz_PRIVATE_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
