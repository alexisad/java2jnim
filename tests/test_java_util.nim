# To run these tests, simply execute `nimble test`.
#GC_disable()
#nim c --passC:-g -d:jnimGlue=Jnim.java --threads:on -d:noSignalHandler --tlsEmulation:off test_java_util.nim

import jnim
#import java2jnim
import java2jnim/jni_export
import unittest
import strutils, random
import sequtils except toSeq
import jimports/util



#################################################################################################### 
# Helpers

proc toSeq*[V](c: Collection[V]): seq[V] =
    result = newSeq[V]()
    let it = c.`iterator`
    while it.hasNext:
        result.add it.next

# Initialize JVM
#initJNI()
initJNI(JNIVersion.v1_8, @["-Djava.class.path=build"])

type
    MyObj = ref object of JVMObject
    KyZbj = ref object of JVMObject

jexport MyObj implements Consumer[MapEntry[Integer, string]]:#, Integer[Stream[Integer], Consumer[string], Double, Long[Set, Comparable, Boolean]]:
    proc new() = super()
    proc accept(i: MapEntry[Integer, string]) =
        System.`out`.println "i: " & $i
jexport KyZbj implements Consumer[MapEntry[string, string]]:#, Integer[Stream[Integer], Consumer[string], Double, Long[Set, Comparable, Boolean]]:
    proc new() = super()
    proc accept(i: MapEntry[string, string]) =
        System.`out`.println "i: " & $i
#[jexport KyZbj implements Consumer, Integer[Double[String], Long[Set, Comparable, Boolean]]:
    proc new() = super()
    proc accept(i: MapEntry[Integer, string]) =
        System.`out`.println "i: " & $i]#
        
let cnsO = MyObj.new()
let cnsK = jcast[Consumer[MapEntry[string, string]]] KyZbj.new()



suite "java.util":
    setup:
        echo "setup test..."
        if not isJNIThreadInitialized():
            initJNI(JNIVersion.v1_8)
    test "java.util.List":
        let xs = ArrayList[string].new()
        discard xs.add("Hello")
        xs.add(1, "world")
        check: xs.get(0) == "Hello"
        check: xs.get(1) == "world"
        expect JavaException:
            discard xs.get(3)
        var s = newSeq[string]()
        let it = xs.`iterator`
        while it.hasNext:
            s.add it.next
        check: s == @["Hello", "world"]
        #discard xs.removeAll(ArrayList[string].new(["world", "!"]))
        #check: xs.toSeq == @["Hello"]
    test "java.util.Map":
        var x = HashMap[Integer, string].new()
        discard x.put(Integer.new 1, "A")
        var m = HashMap[Integer, string].new()
        discard m.put(Integer.new 1, "A")
        discard m.put(Integer.new 3, "C")
        discard m.put(Integer.new 2, "B")
        check: m.get(Integer.new 1) == "A"
        check: m.get(Integer.new 2) == "B"
        check: m.get(Integer.new 3) == "C"
        check: m.keySet.toSeq.mapIt(it.intValue) == @[1.jint, 2, 3]
        check: m.keySet.toSeq == @[1.jint, 2, 3].mapIt(Integer.new(it))
        check: m.values.toSeq == @[ "A",  "B",  "C"]
        #var map = jcast[ Map[Integer, string] ](m)
        let mSet = m.entrySet()
        let stm = mSet
                .stream()
                .sorted(Collections.reverseOrder(MapEntry[Integer, string].comparingByValue))
                .limit(2)
                .toArray()
                #.forEach(System.`out`.println)
        check stm.len == 2
        discard x.remove(jcast[Object]( Integer.new(1) ))
        check: jcast[ MapEntry[Integer, string] ](stm[0]).getKey().intValue == 3
        check: jcast[ MapEntry[Integer, string] ](stm[1]).getKey().intValue == 2
        for mItem in stm:
            echo "mItem: ", jcast[ MapEntry[Integer, string] ](mItem).getKey
        #let f = jcast[Consumer[string]](System.`out`.println)#
        let cnsOInt: Consumer[MapEntry[Integer, string]] = jcast[Consumer[MapEntry[Integer, string]]](cnsO)
        let stm2 = mSet
                .stream()
                .sorted(Collections.reverseOrder(MapEntry[Integer, string].comparingByValue))
                .limit(2)
        stm2.forEach(cnsOInt)
        let it = mSet.`iterator`
        while it.hasNext:
            let me = jcast[ MapEntry[Integer, string] ](it.next)
            echo me.getKey
    test "java.util.Map use large data":
        var alph = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_".repeat 10
        randomize()
        for _ in 0..100:
            shuffle(alph)
            echo alph
            echo "getOccupiedMem: ", getOccupiedMem()
            var x = HashMap[string, string].new()
            for i in 0..1_000_000:
                discard x.put($i & alph, alph & $i)
            GC_fullCollect()
            let xSet = x.entrySet()
            let stm = xSet
                    .stream()
                    .sorted( Collections.reverseOrder(MapEntry[string, string].comparingByValue) )
                    .limit(50)
            stm.forEach(cnsK)
            for i in countdown(1_000_000, 0):
                discard x.remove(jcast[Object](toJVMObject($i & alph)))
            echo "getOccupiedMem: ", getOccupiedMem()
            GC_fullCollect()
            echo "getOccupiedMem: ", getOccupiedMem()
            #System.gc()
            #System.runFinalization()
            echo "getOccupiedMem: ", getOccupiedMem()
            GC_fullCollect()
            echo "getOccupiedMem: ", getOccupiedMem()
            echo "x.size: ", x.size()
        discard stdin.readLine
