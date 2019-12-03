#nim c --app:lib --passC:-g --threads:on jfx.nim

import jnim#, jnim/private/jni_export
import java2jnim
#import java2jnim/javafx

when false:
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


jclassDef java.lang.Object * of JVMObject
proc `$`*(o: Object): string =
    o.toStringRaw

jclassDef java.lang.reflect.Type as ReflectType * of Object
jclassDef java.lang.Class * [T] of Object
jclassDef java.lang.Void * of Object
jclassDef javafx.stage.Window * of Object
jclassDef java.util.EventObject * of Object
jclassDef javafx.event.Event * of EventObject
jclassDef javafx.stage.WindowEvent * of Event
jclassDef javafx.stage.Stage * of Window
jclassDef javafx.scene.image.Image * of Object
jclassDef java.lang.String * of Object
jclassDef java.lang.ClassLoader * of Object
jclassDef java.lang.reflect.TypeVariable * [D] of ReflectType
jclassDef java.lang.Package * of Object
jclassDef java.lang.reflect.AccessibleObject * of Object
jclassDef java.lang.reflect.Executable * of AccessibleObject
jclassDef java.lang.reflect.Method * of Executable
jclassDef java.lang.reflect.Constructor * [T] of Executable
jclassDef java.lang.reflect.Field * of AccessibleObject
jclassDef java.io.InputStream * of Object
jclassDef java.net.URL * of Object
jclassDef java.security.ProtectionDomain * of Object
jclassDef java.lang.annotation.Annotation * of Object
jclassDef java.lang.reflect.AnnotatedElement * of Object
jclassDef java.lang.reflect.AnnotatedType * of AnnotatedElement
jclassDef java.util.Iterator * [E] of Object
jclassDef com.sun.javafx.tk.TKStage * of Object
jclassDef javafx.beans.binding.NumberExpressionBase * of Object
jclassDef javafx.beans.binding.DoubleExpression * of NumberExpressionBase
jclassDef javafx.beans.property.ReadOnlyDoubleProperty * of DoubleExpression
jclassDef javafx.beans.binding.BooleanExpression * of Object
jclassDef javafx.beans.property.ReadOnlyBooleanProperty * of BooleanExpression
jclassDef java.util.Map * [K, V] of Object
jclassDef javafx.collections.ObservableMap * [K, V] of Map[K, V]
jclassDef javafx.scene.Scene * of Object
jclassDef javafx.beans.binding.ObjectExpression * [T] of Object
jclassDef javafx.beans.property.ReadOnlyObjectProperty * [T] of
    ObjectExpression[T]
jclassDef javafx.beans.property.DoubleProperty * of ReadOnlyDoubleProperty
jclassDef java.util.EventListener * of Object
jclassDef javafx.event.EventHandler * [T] of EventListener
jclassDef javafx.beans.property.ObjectProperty * [T] of ReadOnlyObjectProperty[T]
jclassDef javafx.event.EventDispatcher * of Object
jclassDef javafx.event.EventType * [T] of Object
jclassDef javafx.event.EventDispatchChain * of Object
jclassDef javafx.event.EventTarget * of Object
jclassDef java.lang.Enum * [E] of Object
jclassDef javafx.stage.StageStyle * of Enum[StageStyle]
jclassDef javafx.stage.Modality * of Enum[Modality]
jclassDef java.lang.Iterable * [T] of Object
jclassDef java.util.Collection * [E] of Iterable[E]
jclassDef java.util.List * [E] of Collection[E]
jclassDef javafx.collections.ObservableList * [E] of List[E]
jclassDef javafx.beans.binding.StringExpression * of Object
jclassDef javafx.beans.property.ReadOnlyStringProperty * of StringExpression
jclassDef javafx.beans.property.StringProperty * of ReadOnlyStringProperty
jclassDef javafx.beans.property.BooleanProperty * of ReadOnlyBooleanProperty
jclassDef javafx.scene.input.KeyCombination * of Object
jclassDef java.lang.Throwable * of Object
jclassDef java.lang.Exception * of Throwable
jclassDef javafx.scene.image.PixelReader * of Object
jclassImpl java.lang.Object * of JVMObject:
    proc new*()
    proc getClass*(): Class[Object] {.final.}
    proc hashCode*(): jint
    proc equals*(a0: Object): bool
    proc toString*(): String
    proc notify*() {.final.}
    proc notifyAll*() {.final.}
    proc wait*(a0: jlong) {.final.}
    proc wait*(a0: jlong; a1: jint) {.final.}
    proc wait*() {.final.}
jclassImpl java.lang.reflect.Type as ReflectType * of Object:
    proc getTypeName*(): String
jclassImpl java.lang.Class * [T] of Object:
    proc toString*(): String
    proc toGenericString*(): String
    proc forName*(a0: string): Class[Object] {.`static`.}
    proc forName*(a0: string; a1: jboolean; a2: ClassLoader): Class[Object] {.`static`.}
    proc newInstance*(): T
    proc isInstance*(a0: Object): bool
    proc isAssignableFrom*(a0: Class[Object]): bool
    proc isInterface*(): bool
    proc isArray*(): bool
    proc isPrimitive*(): bool
    proc isAnnotation*(): bool
    proc isSynthetic*(): bool
    proc getName*(): String
    proc getClassLoader*(): ClassLoader
    proc getTypeParameters*(): seq[TypeVariable[Class[T]]]
    proc getSuperclass*(): Class[T]
    proc getGenericSuperclass*(): ReflectType
    proc getPackage*(): Package
    proc getInterfaces*(): seq[Class[Object]]
    proc getGenericInterfaces*(): seq[ReflectType]
    proc getComponentType*(): Class[Object]
    proc getModifiers*(): jint
    proc getSigners*(): seq[Object]
    proc getEnclosingMethod*(): Method
    proc getEnclosingConstructor*(): Constructor[Object]
    proc getDeclaringClass*(): Class[Object]
    proc getEnclosingClass*(): Class[Object]
    proc getSimpleName*(): String
    proc getTypeName*(): String
    proc getCanonicalName*(): String
    proc isAnonymousClass*(): bool
    proc isLocalClass*(): bool
    proc isMemberClass*(): bool
    proc getClasses*(): seq[Class[Object]]
    proc getFields*(): seq[Field]
    proc getMethods*(): seq[Method]
    proc getConstructors*(): seq[Constructor[Object]]
    proc getField*(a0: string): Field
    proc getMethod*(a0: string; a1: varargs[Class[Object]]): Method
    proc getConstructor*(a0: varargs[Class[Object]]): Constructor[T]
    proc getDeclaredClasses*(): seq[Class[Object]]
    proc getDeclaredFields*(): seq[Field]
    proc getDeclaredMethods*(): seq[Method]
    proc getDeclaredConstructors*(): seq[Constructor[Object]]
    proc getDeclaredField*(a0: string): Field
    proc getDeclaredMethod*(a0: string; a1: varargs[Class[Object]]): Method
    proc getDeclaredConstructor*(a0: varargs[Class[Object]]): Constructor[T]
    proc getResourceAsStream*(a0: string): InputStream
    proc getResource*(a0: string): URL
    proc getProtectionDomain*(): ProtectionDomain
    proc desiredAssertionStatus*(): bool
    proc isEnum*(): bool
    proc getEnumConstants*(): seq[T]
    proc `cast`*(a0: Object): T
    proc isAnnotationPresent*(a0: Class[Annotation]): bool
    proc getAnnotations*(): seq[Annotation]
    proc getDeclaredAnnotations*(): seq[Annotation]
    proc getAnnotatedSuperclass*(): AnnotatedType
    proc getAnnotatedInterfaces*(): seq[AnnotatedType]
jclassImpl java.lang.Void * of Object:
    proc TYPE*(): Class[Void] {.prop, final, `static`.}
jclassImpl javafx.stage.Window * of Object:
    proc impl_getWindows*(): Iterator[Window] {.`static`.}
    proc impl_getPeer*(): TKStage
    proc impl_getMXWindowType*(): String
    proc sizeToScene*()
    proc centerOnScreen*()
    proc setX*(a0: jdouble) {.final.}
    proc getX*(): jdouble {.final.}
    proc xProperty*(): ReadOnlyDoubleProperty {.final.}
    proc setY*(a0: jdouble) {.final.}
    proc getY*(): jdouble {.final.}
    proc yProperty*(): ReadOnlyDoubleProperty {.final.}
    proc setWidth*(a0: jdouble) {.final.}
    proc getWidth*(): jdouble {.final.}
    proc widthProperty*(): ReadOnlyDoubleProperty {.final.}
    proc setHeight*(a0: jdouble) {.final.}
    proc getHeight*(): jdouble {.final.}
    proc heightProperty*(): ReadOnlyDoubleProperty {.final.}
    proc setFocused*(a0: jboolean) {.final.}
    proc requestFocus*() {.final.}
    proc isFocused*(): bool {.final.}
    proc focusedProperty*(): ReadOnlyBooleanProperty {.final.}
    proc getProperties*(): ObservableMap[Object, Object] {.final.}
    proc hasProperties*(): bool
    proc setUserData*(a0: Object)
    proc getUserData*(): Object
    proc getScene*(): Scene {.final.}
    proc sceneProperty*(): ReadOnlyObjectProperty[Scene] {.final.}
    proc setOpacity*(a0: jdouble) {.final.}
    proc getOpacity*(): jdouble {.final.}
    proc opacityProperty*(): DoubleProperty {.final.}
    proc setOnCloseRequest*(a0: EventHandler[WindowEvent]) {.final.}
    proc getOnCloseRequest*(): EventHandler[WindowEvent] {.final.}
    proc onCloseRequestProperty*(): ObjectProperty[EventHandler[WindowEvent]] {.final.}
    proc setOnShowing*(a0: EventHandler[WindowEvent]) {.final.}
    proc getOnShowing*(): EventHandler[WindowEvent] {.final.}
    proc onShowingProperty*(): ObjectProperty[EventHandler[WindowEvent]] {.final.}
    proc setOnShown*(a0: EventHandler[WindowEvent]) {.final.}
    proc getOnShown*(): EventHandler[WindowEvent] {.final.}
    proc onShownProperty*(): ObjectProperty[EventHandler[WindowEvent]] {.final.}
    proc setOnHiding*(a0: EventHandler[WindowEvent]) {.final.}
    proc getOnHiding*(): EventHandler[WindowEvent] {.final.}
    proc onHidingProperty*(): ObjectProperty[EventHandler[WindowEvent]] {.final.}
    proc setOnHidden*(a0: EventHandler[WindowEvent]) {.final.}
    proc getOnHidden*(): EventHandler[WindowEvent] {.final.}
    proc onHiddenProperty*(): ObjectProperty[EventHandler[WindowEvent]] {.final.}
    proc isShowing*(): bool {.final.}
    proc showingProperty*(): ReadOnlyBooleanProperty {.final.}
    proc hide*()
    proc setEventDispatcher*(a0: EventDispatcher) {.final.}
    proc getEventDispatcher*(): EventDispatcher {.final.}
    proc eventDispatcherProperty*(): ObjectProperty[EventDispatcher] {.final.}
    proc addEventHandler*[T](a0: EventType[T]; a1: EventHandler[T]) {.final.}
    proc removeEventHandler*[T](a0: EventType[T]; a1: EventHandler[T]) {.final.}
    proc addEventFilter*[T](a0: EventType[T]; a1: EventHandler[T]) {.final.}
    proc removeEventFilter*[T](a0: EventType[T]; a1: EventHandler[T]) {.final.}
    proc fireEvent*(a0: Event) {.final.}
    proc buildEventDispatchChain*(a0: EventDispatchChain): EventDispatchChain
jclassImpl javafx.stage.WindowEvent * of Event:
    proc ANY*(): EventType[WindowEvent] {.prop, final, `static`.}
    proc WINDOW_SHOWING*(): EventType[WindowEvent] {.prop, final, `static`.}
    proc WINDOW_SHOWN*(): EventType[WindowEvent] {.prop, final, `static`.}
    proc WINDOW_HIDING*(): EventType[WindowEvent] {.prop, final, `static`.}
    proc WINDOW_HIDDEN*(): EventType[WindowEvent] {.prop, final, `static`.}
    proc WINDOW_CLOSE_REQUEST*(): EventType[WindowEvent] {.prop, final, `static`.}
    proc new*(a0: Window; a1: EventType[Event])
    proc toString*(): String
    proc copyFor*(a0: Object; a1: EventTarget): WindowEvent
    proc copyFor*(a0: Object; a1: EventTarget; a2: EventType[WindowEvent]): WindowEvent
    proc getEventType*(): EventType[WindowEvent]
    proc copyFor*(a0: Object; a1: EventTarget): Event
jclassImpl javafx.stage.Stage * of Window:
    proc new*()
    proc new*(a0: StageStyle)
    proc setScene*(a0: Scene) {.final.}
    proc show*() {.final.}
    proc impl_setPrimary*(a0: jboolean)
    proc impl_getMXWindowType*(): String
    proc impl_setImportant*(a0: jboolean)
    proc showAndWait*()
    proc initStyle*(a0: StageStyle) {.final.}
    proc getStyle*(): StageStyle {.final.}
    proc initModality*(a0: Modality) {.final.}
    proc getModality*(): Modality {.final.}
    proc initOwner*(a0: Window) {.final.}
    proc getOwner*(): Window {.final.}
    proc setFullScreen*(a0: jboolean) {.final.}
    proc isFullScreen*(): bool {.final.}
    proc fullScreenProperty*(): ReadOnlyBooleanProperty {.final.}
    proc getIcons*(): ObservableList[Image] {.final.}
    proc setTitle*(a0: string) {.final.}
    proc getTitle*(): String {.final.}
    proc titleProperty*(): StringProperty {.final.}
    proc setIconified*(a0: jboolean) {.final.}
    proc isIconified*(): bool {.final.}
    proc iconifiedProperty*(): ReadOnlyBooleanProperty {.final.}
    proc setMaximized*(a0: jboolean) {.final.}
    proc isMaximized*(): bool {.final.}
    proc maximizedProperty*(): ReadOnlyBooleanProperty {.final.}
    proc setAlwaysOnTop*(a0: jboolean) {.final.}
    proc isAlwaysOnTop*(): bool {.final.}
    proc alwaysOnTopProperty*(): ReadOnlyBooleanProperty {.final.}
    proc setResizable*(a0: jboolean) {.final.}
    proc isResizable*(): bool {.final.}
    proc resizableProperty*(): BooleanProperty {.final.}
    proc setMinWidth*(a0: jdouble) {.final.}
    proc getMinWidth*(): jdouble {.final.}
    proc minWidthProperty*(): DoubleProperty {.final.}
    proc setMinHeight*(a0: jdouble) {.final.}
    proc getMinHeight*(): jdouble {.final.}
    proc minHeightProperty*(): DoubleProperty {.final.}
    proc setMaxWidth*(a0: jdouble) {.final.}
    proc getMaxWidth*(): jdouble {.final.}
    proc maxWidthProperty*(): DoubleProperty {.final.}
    proc setMaxHeight*(a0: jdouble) {.final.}
    proc getMaxHeight*(): jdouble {.final.}
    proc maxHeightProperty*(): DoubleProperty {.final.}
    proc toFront*()
    proc toBack*()
    proc close*()
    proc setFullScreenExitKeyCombination*(a0: KeyCombination) {.final.}
    proc getFullScreenExitKeyCombination*(): KeyCombination {.final.}
    proc fullScreenExitKeyProperty*(): ObjectProperty[KeyCombination] {.final.}
    proc setFullScreenExitHint*(a0: string) {.final.}
    proc getFullScreenExitHint*(): String {.final.}
    proc fullScreenExitHintProperty*(): ObjectProperty[String] {.final.}
jclassImpl javafx.scene.image.Image * of Object:
    proc impl_getUrl*(): String {.final.}
    proc getProgress*(): jdouble {.final.}
    proc progressProperty*(): ReadOnlyDoubleProperty {.final.}
    proc getRequestedWidth*(): jdouble {.final.}
    proc getRequestedHeight*(): jdouble {.final.}
    proc getWidth*(): jdouble {.final.}
    proc widthProperty*(): ReadOnlyDoubleProperty {.final.}
    proc getHeight*(): jdouble {.final.}
    proc heightProperty*(): ReadOnlyDoubleProperty {.final.}
    proc isPreserveRatio*(): bool {.final.}
    proc isSmooth*(): bool {.final.}
    proc isBackgroundLoading*(): bool {.final.}
    proc isError*(): bool {.final.}
    proc errorProperty*(): ReadOnlyBooleanProperty {.final.}
    proc getException*(): Exception {.final.}
    proc exceptionProperty*(): ReadOnlyObjectProperty[Exception] {.final.}
    proc impl_getPlatformImage*(): Object {.final.}
    proc new*(a0: string)
    proc new*(a0: string; a1: jboolean)
    proc new*(a0: string; a1: jdouble; a2: jdouble; a3: jboolean; a4: jboolean)
    proc new*(a0: string; a1: jdouble; a2: jdouble; a3: jboolean; a4: jboolean; a5: jboolean)
    proc new*(a0: InputStream)
    proc new*(a0: InputStream; a1: jdouble; a2: jdouble; a3: jboolean; a4: jboolean)
    proc cancel*()
    proc impl_fromPlatformImage*(a0: Object): Image {.`static`.}
    proc getPixelReader*(): PixelReader {.final.}


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
    let stage = jcast[Stage](stage.newJVMObject)
    stage.setTitle("JNIM First Application")
    #stage.setWidth(300.jint)
    #stage.setHeight(250)
    stage.show()
proc Java_JFx_startJfy(vjnienv: JNIEnvPtr, vclass: pointer) {.JNIEXPORT.} =
    discard