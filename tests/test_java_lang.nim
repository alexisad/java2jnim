# To run these tests, simply execute `nimble test`.

import jnim
import java2jnim
import unittest, math

when true:
    jnimport_all:
        java.lang.Object
        java.lang.String
        java.lang.Number
        java.lang.Byte
        java.lang.Short
        java.lang.Integer
        java.lang.Float
        java.lang.Boolean




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
    test "java.lang.String":
        let s1 = String.new("Hi")
        let s2 = String.new("Hi")
        let s3 = String.new("Hello")
        # Check inheritance
        check: s1 of String
        check: s1 of Object
        # Check operations
        check: $s1 == "Hi"
        check: s1.equals(s2)
        check: not s2.equals(s3)
        let s = String.new("Привет!")
        check: String.new(s.getBytes("CP1251"), "CP1251") == s
    test "java.lang - Numbers":
        check: Byte.MIN_VALUE == low(int8)
        check: Byte.MAX_VALUE == high(int8)
        check: Byte.SIZE == 8
        check: $Byte.TYPE == "byte"
        check: Byte.new(100).byteValue == Byte.new("100").byteValue
        expect JavaException:
            discard Byte.new("1000")
        check: Short.MIN_VALUE == low(int16)
        check: Short.MAX_VALUE == high(int16)
        let jI = Integer.new(1)
        let jII = Integer.new(1)
        check: Integer.new(1) == Integer.new(1)
        check: jI.equals(jII)
        check: Float.MIN_VALUE == pow(2.00, -149.00)
        check: $Float.TYPE == "float"
        #check: Float.new(137.89).doubleValue == 137.89
        let xxx = Float.parseFloat("137.89")
        #check: Float.parseFloat(String.new "137.89").equals(Float.new(137.89))
    test "java.lang - Booleans":
        check: Boolean.new(JVM_TRUE).booleanValue == JVM_TRUE.bool
        check: Boolean.new(JVM_FALSE).booleanValue == JVM_FALSE.bool
