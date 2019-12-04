#nim c --app:lib --passC:-g --threads:on -d:noSignalHandler --tlsEmulation:off jfx.nim

import jnim#, jnim/private/jni_export
import java2jnim
#import java2jnim/javafx

setupForeignThreadGc()

when true:
    jnimport_all:
        java.lang.Object
        java.lang.reflect.Type as ReflectType
        java.lang.Class
        java.lang.Void
        #javafx.application.Application$Parameters as AppPrms
        #javafx.application.Application
        #javafx.application.Preloader$PreloaderNotification as PreloaderPreloaderNotification
        javafx.stage.Window
        javafx.stage.WindowEvent
        javafx.stage.Stage
        javafx.scene.image.Image




when false:
    jnimport_all:
        java.lang.Void
        javafx.scene.Scene
        javafx.scene.Group
        javafx.scene.SnapshotResult
        #javafx.scene.text.Text

#[
when defined(MACOSX):
    const
        JVM_LIB_NAME* = "jvm.dylib"
elif defined(UNIX):
    const
        JVM_LIB_NAME* = "jvm.so"
else:
    const
        JVM_LIB_NAME* = "jvm.dll"
]#

when defined(windows):
    {.pragma: JNIEXPORT, stdcall, exportc, dynlib.}
    #{.pragma: JNIIMPORT, stdcall, importc, dynlib: JVM_LIB_NAME.}
    #{.pragma: JNICALL, stdcall.}
else:
    {.pragma: JNIEXPORT, cdecl, exportc, dynlib.}
    #{.pragma: JNIIMPORT, cdecl, importc, dynlib: JVM_LIB_NAME.}
    #{.pragma: JNICALL, cdecl.}


#checkInit() #initJNI

proc Java_JFx_startJfx(vjnienv: JNIEnvPtr, vclass: pointer, stage: jobject) {.JNIEXPORT.} =
    setupForeignThreadGc()
    let stage = jcast[Stage](stage.newJVMObject)
    stage.setTitle("JNIM First Application")
    stage.setWidth(300)
    stage.setHeight(650)
    stage.show()
proc Java_JFx_startJfy(vjnienv: JNIEnvPtr, vclass: pointer) {.JNIEXPORT.} =
    discard