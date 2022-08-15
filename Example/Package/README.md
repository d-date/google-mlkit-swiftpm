# Experimental: Example for MLKit for Swift PM

## Limitation

- This project is enable to build in `arm64` for iphoneos and `x86_64` for iphonesimulator. That means we cannot build in arm64 simulator.

## Current Problem

You can see these errors below when building for iOS Devices.

```text
Details

Unable to install "Example"
Domain: com.apple.dt.MobileDeviceErrorDomain
Code: -402653103
User Info: {
    DVTErrorCreationDateKey = "2022-08-15 14:01:57 +0000";
    IDERunOperationFailingWorker = IDEInstalliPhoneLauncher;
}
--
Could not inspect the application package.
Domain: com.apple.dt.MobileDeviceErrorDomain
Code: -402653103
User Info: {
    DVTRadarComponentKey = 282703;
    MobileDeviceErrorCode = "(0xE8000051)";
    "com.apple.dtdevicekit.stacktrace" = (
	0   DTDeviceKitBase                     0x0000000112c2c2bc DTDKCreateNSErrorFromAMDErrorCode + 300
	1   DTDeviceKitBase                     0x0000000112c603c0 __90-[DTDKMobileDeviceToken installApplicationBundleAtPath:withOptions:andError:withCallback:]_block_invoke + 136
	2   DVTFoundation                       0x00000001031a2530 DVTInvokeWithStrongOwnership + 76
	3   DTDeviceKitBase                     0x0000000112c60144 -[DTDKMobileDeviceToken installApplicationBundleAtPath:withOptions:andError:withCallback:] + 1196
	4   IDEiOSSupportCore                   0x000000010e747d90 __118-[DVTiOSDevice(DVTiPhoneApplicationInstallation) processAppInstallSet:appUninstallSet:installOptions:completionBlock:]_block_invoke.147 + 2328
	5   DVTFoundation                       0x00000001032ac7d4 __DVT_CALLING_CLIENT_BLOCK__ + 16
	6   DVTFoundation                       0x00000001032ad240 __DVTDispatchAsync_block_invoke + 152
	7   libdispatch.dylib                   0x000000018bb4a5f0 _dispatch_call_block_and_release + 32
	8   libdispatch.dylib                   0x000000018bb4c1b4 _dispatch_client_callout + 20
	9   libdispatch.dylib                   0x000000018bb538a8 _dispatch_lane_serial_drain + 668
	10  libdispatch.dylib                   0x000000018bb54404 _dispatch_lane_invoke + 392
	11  libdispatch.dylib                   0x000000018bb5ec98 _dispatch_workloop_worker_thread + 648
	12  libsystem_pthread.dylib             0x000000018bd0c360 _pthread_wqthread + 288
	13  libsystem_pthread.dylib             0x000000018bd0b080 start_wqthread + 8
);
}
--

Analytics Event: com.apple.dt.IDERunOperationWorkerFinished : {
    "device_model" = "iPhone13,4";
    "device_osBuild" = "15.6 (19G71)";
    "device_platform" = "com.apple.platform.iphoneos";
    "launchSession_schemeCommand" = Run;
    "launchSession_state" = 1;
    "launchSession_targetArch" = arm64;
    "operation_duration_ms" = 3229;
    "operation_errorCode" = "-402653103";
    "operation_errorDomain" = "com.apple.dt.MobileDeviceErrorDomain";
    "operation_errorWorker" = IDEInstalliPhoneLauncher;
    "operation_name" = IDEiPhoneRunOperationWorkerGroup;
    "param_consoleMode" = 0;
    "param_debugger_attachToExtensions" = 0;
    "param_debugger_attachToXPC" = 1;
    "param_debugger_type" = 5;
    "param_destination_isProxy" = 0;
    "param_destination_platform" = "com.apple.platform.iphoneos";
    "param_diag_MainThreadChecker_stopOnIssue" = 0;
    "param_diag_MallocStackLogging_enableDuringAttach" = 0;
    "param_diag_MallocStackLogging_enableForXPC" = 1;
    "param_diag_allowLocationSimulation" = 1;
    "param_diag_checker_tpc_enable" = 1;
    "param_diag_gpu_frameCapture_enable" = 0;
    "param_diag_gpu_shaderValidation_enable" = 0;
    "param_diag_gpu_validation_enable" = 0;
    "param_diag_memoryGraphOnResourceException" = 0;
    "param_diag_queueDebugging_enable" = 1;
    "param_diag_runtimeProfile_generate" = 0;
    "param_diag_sanitizer_asan_enable" = 0;
    "param_diag_sanitizer_tsan_enable" = 0;
    "param_diag_sanitizer_tsan_stopOnIssue" = 0;
    "param_diag_sanitizer_ubsan_stopOnIssue" = 0;
    "param_diag_showNonLocalizedStrings" = 0;
    "param_diag_viewDebugging_enabled" = 1;
    "param_diag_viewDebugging_insertDylibOnLaunch" = 1;
    "param_install_style" = 0;
    "param_launcher_UID" = 2;
    "param_launcher_allowDeviceSensorReplayData" = 0;
    "param_launcher_kind" = 0;
    "param_launcher_style" = 0;
    "param_launcher_substyle" = 0;
    "param_runnable_appExtensionHostRunMode" = 0;
    "param_runnable_productType" = "com.apple.product-type.application";
    "param_runnable_type" = 2;
    "param_testing_launchedForTesting" = 0;
    "param_testing_suppressSimulatorApp" = 0;
    "param_testing_usingCLI" = 0;
    "sdk_canonicalName" = "iphoneos16.0";
    "sdk_osVersion" = "16.0";
    "sdk_variant" = iphoneos;
}
--


System Information

macOS Version 12.4 (Build 21F79)
Xcode 14.0 (21330) (Build 14A5294e)
Timestamp: 2022-08-15T23:01:57+09:00
```
