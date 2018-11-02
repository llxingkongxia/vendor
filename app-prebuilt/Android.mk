PARSER_DEBUG := false

$(info **** BEGIN app-prebuilt ****)
$(info project is $(TARGET_PROJECT))
$(info sku is $(TARGET_SKU))
$(info XROM is $(TARGET_PROJECT_XROM))

### BEGIN: Check ro.adb.secure system property ###
ifneq ($(filter userdebug,$(TARGET_BUILD_VARIANT)),)
$(foreach each_get_product,$(call get-all-product-makefiles), \
    $(if $(filter $(basename $(notdir $(each_get_product))),$(TARGET_PRODUCT)),\
        $(if $(wildcard $(each_get_product)), \
           $(eval GET_PRODUCT_MAKEFILE := $(each_get_product)))))
IS_ACCEPT_ADB_PC_CONNECTION :=
$(foreach each_property,$(PRODUCTS.$(GET_PRODUCT_MAKEFILE).PRODUCT_DEFAULT_PROPERTY_OVERRIDES), \
    $(eval IS_CHECK_ADB_PROPERTY := false) \
    $(foreach var,$(subst =, ,$(each_property)), \
        $(eval $(if $(filter ro.adb.secure,$(var)), \
            IS_CHECK_ADB_PROPERTY := true, \
            $(if $(filter true,$(IS_CHECK_ADB_PROPERTY)), \
                 $(if $(filter 0 1,$(IS_ACCEPT_ADB_PC_CONNECTION)), \
                      IS_CHECK_ADB_PROPERTY := false, \
                      IS_ACCEPT_ADB_PC_CONNECTION := $(var) \
                      IS_CHECK_ADB_PROPERTY := false))))))
ifneq ($(filter 0 1, $(IS_ACCEPT_ADB_PC_CONNECTION)),)
$(info --- userdebug mode ---)
ifneq ($(filter 0,$(IS_ACCEPT_ADB_PC_CONNECTION)),)
$(info Use directly the Android Debug Bridge[adb] when device is connected to PC.)
$(info ro.adb.secure=0)
else
$(info Android asks you to accept the fingerprint of your pc when device is connected to PC.)
$(info ro.adb.secure=1)
endif
$(info ----------------------)
endif
endif
### END: Check ro.adb.secure system property ###

BUILD_MAKEFILE_STATUS := MakeFile_Success

ifeq (,$(filter $(BUILD_MAKEFILE_STATUS),$(PARSE_APP_PREBUILT)))
    $(info Building Makefiles in app-prebuilt is Fail)
else
    $(info Building Makefiles in app-prebuilt is Success)
    ifneq ($(filter userdebug,$(TARGET_BUILD_VARIANT)),)
        $(info -- Add product-packages --)
        $(info amax-prebuilt = $(PRODUCT_PACKAGES_IN_HOUSE))
        $(info 3rd_party = $(PRODUCT_PACKAGES_THIRD_PARTY))
        $(info google = $(PRODUCT_PACKAGES_GMS))
        $(info XROM = $(PRODUCT_PACKAGES_XROM))
### BEGIN: In addition to the XROM's apks, the something to add to the rom(system image)
        ifneq ($(PRODUCT_PACKAGES_EXT_XROM),)
            $(info --------)
            $(info External XROM = $(PRODUCT_PACKAGES_EXT_XROM))
        endif
### END: In addition to the XROM's apks, the something to add to the rom(system image)
        $(info --------------------------)
    endif
endif

ifeq ($(PARSER_DEBUG), false)
$(info Detail of app-prebuilt log -> the PARSER_DEBUG value is defined true in vendor/app-prebuilt/tools/Android.mk)
endif

ifeq ($(PARSER_DEBUG), true)
ifeq ($(PARSE_APP_PREBUILT),)
$(warning Check executing commands that execute built_makefiles_rom.py)
else
$(info The log of parsing app-prebuilt is $(PARSE_APP_PREBUILT))
endif
endif

### BEGIN: Get product value for installing the pre-built binaries
define get_product_value
$(strip \
    $(eval MY_LOCAL_PATH := $(LOCAL_PATH))
    $(foreach each_get_product,$(call get-all-product-makefiles), \
        $(if $(wildcard $(each_get_product)), \
            $(if $(filter $(PRODUCTS.$(each_get_product).PRODUCT_DEVICE),$(TARGET_DEVICE)),\
                $(eval GET_PRODUCT_VALUE := $(PRODUCTS.$(each_get_product).$(1))))))
    $(eval $(if $(filter true,$(PARSER_DEBUG)), \
        $(info The path is $(LOCAL_PATH) after call get-all-product-makefiles)))
    $(eval LOCAL_PATH := $(MY_LOCAL_PATH))
    $(eval $(if $(filter true,$(PARSER_DEBUG)), \
        $(info The path is $(LOCAL_PATH) after fix path)))
    $(GET_PRODUCT_VALUE)
)
endef
### END: Get product value for installing the pre-built binaries

### BEGIN: Pre-optimization of the definition ###
define local_odex_status
$(strip \
    $(eval app_odex_status := )
    $(eval $(if $(filter $(APP_ODEX_IS_TRUE),$(1)), \
        app_odex_status := true))
    $(eval $(if $(filter $(APP_ODEX_IS_FALSE),$(1)), \
        app_odex_status := false))
    $(app_odex_status)
    $(eval $(if $(filter true,$(PARSER_DEBUG)), \
        $(info $(strip $(1)) used odex is $(app_odex_status))))
)
endef
### END: Pre-optimization of the definition ###

### BEGIN: Get the suitable CPU-ABI ###
define check_cpu_abi_path
$(strip \
    $(eval $(if $(filter false,$(3)), \
        $(if $(wildcard $(1)/libs/$(2)), \
            check_path := $(2), \
            check_path := false), \
            check_path := $(3)))
    $(check_path)
)
endef

define cpu_abi_arm_to_x86
$(strip \
    $(eval arm_abi_path := $(call check_cpu_abi_path,$(1),armeabi-v7a,false))
    $(eval arm_abi_path := $(call check_cpu_abi_path,$(1),armeabi,$(arm_abi_path)))
    $(eval $(if $(filter false,$(arm_abi_path)), \
        $(error error - $(strip $(2)) : Native-libs do not support armeabi/arrmeabi-v7a abi)))
    $(arm_abi_path)
)
endef

define local_cpu_abi
$(strip \
    $(eval abi_path := false)
    $(eval $(if $(filter none,$(3)), \
        abi_path := $(call cpu_abi_arm_to_x86,$(1),$(2))))
    $(eval $(if $(TARGET_CPU_ABI), \
        abi_path := $(call check_cpu_abi_path,$(1),$(TARGET_CPU_ABI),$(abi_path))))
    $(eval $(if $(TARGET_CPU_ABI2), \
        abi_path := $(call check_cpu_abi_path,$(1),$(TARGET_CPU_ABI2),$(abi_path))))
    $(eval $(if $(TARGET_2ND_CPU_ABI), \
        abi_path := $(call check_cpu_abi_path,$(1),$(TARGET_2ND_CPU_ABI),$(abi_path))))
    $(eval $(if $(TARGET_2ND_CPU_ABI2), \
        abi_path := $(call check_cpu_abi_path,$(1),$(TARGET_2ND_CPU_ABI2),$(abi_path))))
    $(eval $(if $(filter false,$(abi_path)), \
        $(error error - $(2) : Native-libs do not support CPU ABI for $(TARGET_PROJECT))))
    $(abi_path)
    $(eval $(if $(filter true false,$(PARSER_DEBUG)), \
                $(if $(filter userdebug,$(TARGET_BUILD_VARIANT)), \
                     $(info $(strip $(2)) used cpu abi is $(abi_path)))))
)
endef
### END: Get the suitable CPU-ABI ###

$(shell rm -f vendor/app-prebuilt/tools/built_common.pyc)

ifeq ($(IS_USED_APP_PREBUILT_SYSTEM),true)
$(info Used the new [app-prebuilt system] method of building system image)
$(info Create- $(TARGET_OUT_ETC))
$(shell mkdir -p $(TARGET_OUT_ETC))
$(info ---- Include app ----)
-include vendor/app-prebuilt/build/AppList.mk
$(info ---------------------)

# BEGIN: filter out LOCAL_OVERRIDES_PACKAGES(PartnerBookmarksProvider) form Chrome required modules
ifneq ($(filter ASUSPartnerBookmarksProvider,$(PRODUCT_PACKAGES_IN_HOUSE)),)
ifneq ($(filter Chrome,$(PRODUCT_PACKAGES_GMS)),)
$(info -> Chrome required modules filter out PartnerBookmarksProvider)
ALL_MODULES.Chrome.REQUIRED := $(filter-out PartnerBookmarksProvider,$(ALL_MODULES.Chrome.REQUIRED))
$(info -> Chrome new required modules = $(ALL_MODULES.Chrome.REQUIRED))
endif
endif
# END: filter out LOCAL_OVERRIDES_PACKAGES(PartnerBookmarksProvider) form Chrome required modules

else
$(info Used the old method of building system image)
endif

### BEGIN: Generate asus board config report ###
GENERATE_BOARD_CONFIG_PYTHON := vendor/app-prebuilt/tools/asus_boardconfig_info/generate_board_config.py

BOARD_CONFIG_LOG := $(if $(wildcard $(GENERATE_BOARD_CONFIG_PYTHON)), $(shell python $(GENERATE_BOARD_CONFIG_PYTHON) --report-dir vendor/app-prebuilt --config-list BOARD_SYSTEMIMAGE_PARTITION_SIZE $(BOARD_SYSTEMIMAGE_PARTITION_SIZE)),Do not support providing board config)
$(info Message of generating board config - $(BOARD_CONFIG_LOG))
### END: Generate asus board config report ###

$(info **** END app-prebuilt ****)
