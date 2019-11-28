# To run these tests, simply execute `nimble test`.

import jnim
import java2jnim
import unittest, math

when true:
    jnimport_all:
        java.lang.Object
        java.lang.Class




# Initialize JVM
initJNI()

suite "javaapi.core":
    setup:
        if not isJNIThreadInitialized():
            initJNI(JNIVersion.v1_8)
    test "java.lang.Object":
        let o1 = Object.new
        let o2 = Object.new
        check: not o1.toString.equals(o2.toString)
        check: not o1.equals(o2)
        check: o1.getClass.equals(o2.getClass).bool