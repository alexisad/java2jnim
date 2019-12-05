# To run these tests, simply execute `nimble test`.

import jnim, jnim/private/jni_export
import java2jnim#, java2jnim/javafx
import unittest, math

when true:
    jnimport_all:
        java.lang.Object
        java.lang.Class
        javafx.application.Application
        javafx.application.Application$Parameters as AppPrms
        javafx.application.Preloader$PreloaderNotification as PreloaderPreloaderNotification
        #javafx.stage.Stage
        #javafx.scene.image.Image




when false:
    type
        Main = ref object of JVMObject
    jexport Main extends Application:
        proc new() = super()
        proc main*() =
            Application.launch()
        proc start*(stage: Stage) =
            var x = 1
            discard



# Initialize JVM
initJNI(JNIVersion.v1_6, @["-Djava.class.path=build"])

suite "javaapi.core":
    setup:
        if not isJNIThreadInitialized():
            initJNI(JNIVersion.v1_8, @["-Djava.class.path=build"])
    test "java.lang.Class":
        let o1 = Object.new
        let o2 = Object.new
        check: not o1.toString.equals(o2.toString)
        check: not o1.equals(o2)
        check: o1.getClass.equals(o2.getClass).bool
        check: $o1.getClass().getName() == "java.lang.Object"
        check: $o1.getClass().newInstance().getClass().getName() == "java.lang.Object"
    test "javafx.application":
        discard
        #let m = Main.new()
        #m.main()
        #Application.launch()