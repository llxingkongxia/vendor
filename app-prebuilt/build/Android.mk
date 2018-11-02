#############################
# Target Project:ZS620KL
# Target Sku:WW
#############################

# Define asus uses-feature for project, sku
PRODUCT_COPY_FILES += \
    vendor/app-prebuilt/build/features/asus.software.project.ZS620KL.xml:system/etc/permissions/asus.software.project.ZS620KL.xml \
    vendor/app-prebuilt/build/features/asus.software.sku.WW.xml:system/etc/permissions/asus.software.sku.WW.xml

# Define enable(or disable) secure usb debugging
ifneq ($(filter userdebug,$(TARGET_BUILD_VARIANT)),)
# Disable secure usb debugging
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
      ro.adb.secure=0
else
# Enable secure usb debugging
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
      ro.adb.secure=1
endif

# Define build old/new system
IS_USED_APP_PREBUILT_SYSTEM := true

# PMS customization for WW sku
PRODUCT_COPY_FILES += \
    vendor/app-prebuilt/config/ZS620KL/WW/applications.xml:system/etc/cust_pms/applications.xml \
    $(call find-copy-subdir-files,*,vendor/app-prebuilt/config/ZS620KL/WW/CountryCode,system/etc/cust_pms/CountryCode) \
    $(call find-copy-subdir-files,*,vendor/app-prebuilt/config/ZS620KL/WW/CustomerID,system/etc/cust_pms/CustomerID)

###### BEGIN: Project Settings #####
# Add properties for project
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-asus \
    ro.com.google.clientidbase.ms=android-asus-tpin

# Build Settings Define
DEFINE_GMS_BUILD_ODEX := yes
GMS_PROPERTIES := contract-n

###### END: Project Settings #####

###### BEGIN: App List #####
# amax-prebuilt
PRODUCT_PACKAGES_IN_HOUSE := \
    ASUSPartnerHomepageProvider \
    AsusAnalytics \
    AsusBlockedNumberProvider \
    AsusBoost \
    AsusCalculator \
    AsusCamera \
    AsusCellBroadcast \
    AsusConfigUpdater \
    AsusContacts \
    AsusContactsProvider \
    AsusDefaultTheme \
    AsusDemoService \
    AsusDemoUI \
    AsusDeskClock \
    AsusEasyLauncher \
    AsusEmergencyHelp \
    AsusEmergencyInfo \
    AsusFMRadio \
    AsusFMService \
    AsusFaceUnlockService \
    AsusGallery \
    AsusGalleryBurst \
    AsusInCallUI \
    AsusKidsLauncher \
    AsusLauncher \
    AsusMediaProvider \
    AsusPackageInstaller \
    AsusSensorService \
    AsusSetupWizard \
    AsusSoundRecorder \
    AsusSplendid \
    AsusSplendidCommandAgent \
    AsusSystemDiagnostic \
    AsusSystemUI \
    AsusThemeApp \
    AsusVisualMaster \
    AudioWizard \
    AudioWizardView \
    BRApps \
    BrowserGenie \
    CSCBatterySOH \
    DMClient \
    DriveActivator \
    FileManager \
    FocusAppListener \
    GameBroadcaster \
    GameBroadcasterService \
    HardwareStub \
    InadvertentTouch \
    Keyboard \
    Lockscreen \
    LogUploader \
    LogUploaderProxy \
    MobileManager \
    MobileManagerService \
    NextApp \
    NextAppCore \
    ParallaxLiveWallpaper \
    PowerSaving2 \
    SUWTermsAndConditionsWebViewer \
    SelfieMaster \
    ShimProcess \
    SmartReading \
    StitchImage \
    StitchImageService \
    SystemMonitor \
    TaskManager \
    TextAnalyticsService \
    TwinApps \
    UpdateLauncher \
    WeatherTime \
    ZenUIHelp \
    Zenimoji

# 3rd_party
PRODUCT_PACKAGES_THIRD_PARTY := \
    ATOKIME \
    AsusDataTransfer \
    Babe \
    Facebook \
    FacebookAppManager \
    FacebookInstaller \
    FacebookMessenger \
    FlipfontFelbridge \
    FlipfontMFinanceTW \
    FlipfontMYingHei \
    FlipfontMYuppyTW \
    FlipfontSyndor \
    GSuiteProps \
    Go2Pay \
    IBook \
    Instagram \
    MyASUS \
    PAIStub \
    WebStorage \
    YandexApp \
    YandexBrowser \
    ZenTalk \
    iFilter

# google
PRODUCT_PACKAGES_GMS := \
    CalendarGoogle \
    CantoneseIME \
    CarrierServices \
    Chrome \
    ConfigUpdater \
    Drive \
    Duo \
    Gmail2 \
    GmsCore \
    GoogleBackupTransport \
    GoogleCalendarSyncAdapter \
    GoogleContactsSyncAdapter \
    GoogleExtServices \
    GoogleExtShared \
    GoogleFeedback \
    GoogleLens \
    GoogleOneTimeInitializer \
    GooglePackageInstaller \
    GooglePartnerSetup \
    GooglePay \
    GooglePrintRecommendationService \
    GoogleServicesFramework \
    GoogleTTS \
    LatinImeGoogle \
    Maps \
    Messages \
    Music2 \
    Phonesky \
    Photos \
    SetupWizard \
    Velvet \
    Videos \
    WebViewGoogle \
    YouTube \
    ZhuyinIME \
    talkback

# Add PRODUCT_PACKAGES
PRODUCT_PACKAGES += $(PRODUCT_PACKAGES_IN_HOUSE) $(PRODUCT_PACKAGES_THIRD_PARTY) $(PRODUCT_PACKAGES_GMS)
###### END: App List #####

###### BEGIN: supprt odex list #####
# odex define is false
APP_ODEX_IS_FALSE := \
    AsusDemoService \
    AsusDemoUI \
    AsusEasyLauncher \
    AsusFMRadio \
    FileManager \
    GameBroadcaster \
    NextAppCore \
    TaskManager \
    ZenUIHelp

# Disable pre-optimization of a particular module or package
$(foreach each_module,$(APP_ODEX_IS_FALSE), \
    $(call add-product-dex-preopt-module-config,$(each_module),disable))
###### END: support odex list #####

# If the gms_asus.mk exists, inherit it
$(call inherit-product-if-exists, vendor/app-prebuilt/ZS620KL/google/products/gms_asus.mk)

# Re-Generating vendor_required_apps_managed_device(profile) overlay for ManagedProvisioning project
PRODUCT_PACKAGE_OVERLAYS := vendor/app-prebuilt/build/gms_overlay

# Add external prodcuts settings
$(call inherit-product-if-exists, vendor/app-prebuilt/tools/ext_product/ext_product.mk)

# Special apps define inherit the specify makefiles that customized resources by project(or sku)
$(call inherit-product-if-exists, vendor/app-prebuilt/data/customize.mk)

$(shell rm -f vendor/app-prebuilt/tools/built_common.pyc)