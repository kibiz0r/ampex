# Copyright 2010 Conrad Irwin <conrad.irwin@gmail.com> MIT License
#
# For detailed usage notes, please see README.markdown

# NOTE: Ruby 1.9 seems to provide a default blank slate that isn't
# very blank, luckily it also provides a BasicObject which is pretty
# basic.
if defined? BasicObject
  superclass = BasicObject
else
  require 'rubygems'
  require 'blankslate'
  superclass = BlankSlate
end

class Metavariable # < superclass
  # When you pass an argument with & in ruby, you're actually calling #to_proc
  # on the object. So it's Symbol#to_proc that makes the &:to_s trick work,
  # and Metavariable#to_proc that makes &X work.
  attr_reader :to_proc

  def initialize(&block)
    @to_proc = block || ::Proc.new{|x| x}
  end

  def init(&block)
    initialize &block
    self
  end

  # Each time a method is called on a Metavariable, we want to create a new
  # Metavariable that is like the last but does something more.
  #
  # The end result of calling X.one.two will be like:
  #
  # lambda{|x|
  #   (lambda{|x|
  #     (lambda{|x| x}).call(x).one
  #   }).call(x).two
  # }
  #
  def method_missing(name, *args, &block)
    raise ::NotImplementedError, "(&X = 'foo') is unsupported in ampex > 2.0.0" if name.to_s =~ /[^!=<>]=$/
    ::Metavariable.new { |x| @to_proc.call(x).__send__(name, *args, &block) }
  end

  # BlankSlate and BasicObject have different sets of methods that you don't want.
  # let's remove them all.
  instance_methods.each do |method|
    undef_method method unless %w(CA_addValue:multipliedBy: CA_copyRenderValue CA_distanceToValue: CA_interpolateValue:byFraction: CA_interpolateValues:::interpolator: CA_prepareRenderValue
                                MPMediaLibraryDataProviderSystemML3CoercedString __send__ __id__ accessibilityActivationPoint accessibilityContainer accessibilityDecrement accessibilityElementAtIndex:
                                accessibilityElementCount accessibilityElementDidBecomeFocused accessibilityElementDidLoseFocus accessibilityElementIsFocused accessibilityElementsHidden
                                accessibilityFrame accessibilityHint accessibilityIdentifier accessibilityIncrement accessibilityLabel accessibilityLanguage accessibilityPerformEscape
                                accessibilityScroll: accessibilitySetIdentification: accessibilityTraits accessibilityValue accessibilityViewIsModal addObserver:forKeyPath:options:context:
                                allowSafePerformSelector allowsWeakReference autoContentAccessingProxy autorelease awakeAfterUsingCoder: awakeFromNib becomeActive becomeInactive
                                blockingMainThreadProxy class classForArchiver classForCoder classForKeyedArchiver classForPortCoder conformsToProtocol: copy dealloc debugDescription
                                defaultAccessibilityTraits delayedProxy: description dictionaryWithValuesForKeys: didChange:valuesAtIndexes:forKey: didChangeValueForKey:
                                didChangeValueForKey:withSetMutation:usingObjects: disallowSafePerformSelector doesNotRecognizeSelector: finalize forwardInvocation: forwardingTargetForSelector:
                                fromMainThreadPostNotificationName:object:userInfo: fromNotifySafeThreadPerformSelector:withObject: fromNotifySafeThreadPostNotificationName:object:userInfo:
                                hash implementsSelector: indexOfAccessibilityElement: init instance_eval: instance_exec: isAccessibilityElement isAccessibilityElementByDefault
                                isElementAccessibilityExposedToInterfaceBuilder isEqual: isFault isKindOfClass: isMemberOfClass: isNSArray__ isNSData__ isNSDate__ isNSDictionary__ isNSNumber__
                                isNSOrderedSet__ isNSSet__ isNSString__ isNSTimeZone__ isNSValue__ isProxy mainThreadProxy method_missing: methodDescriptionForSelector: methodForSelector:
                                methodSignatureForSelector: mutableArrayValueForKey: mutableArrayValueForKeyPath: mutableCopy mutableOrderedSetValueForKey: mutableOrderedSetValueForKeyPath:
                                mutableSetValueForKey: mutableSetValueForKeyPath: my_run_as_block my_compactDescription observationInfo observeValueForKeyPath:ofObject:change:context:
                                okToNotifyFromThisThread pep_afterDelay: pep_getInvocation: pep_onDetachedThread pep_onMainThread pep_onMainThreadIfNecessary pep_onOperationQueue:
                                pep_onOperationQueue:priority: pep_onThread: pep_onThread:immediateForMatchingThread: performSelector: performSelector:object:afterDelay:
                                performSelector:onThread:withObject:waitUntilDone: performSelector:onThread:withObject:waitUntilDone:modes: performSelector:withObject: performSelector:withObject:afterDelay:
                                performSelector:withObject:afterDelay:inModes: performSelector:withObject:withObject: performSelectorInBackground:withObject: performSelectorOnMainThread:withObject:waitUntilDone:
                                performSelectorOnMainThread:withObject:waitUntilDone:modes: postNotificationWithDescription: registerForTimeMarkerNotificationsIfNecessary release releaseOnMainThread
                                removeObserver:forKeyPath: removeObserver:forKeyPath:context: replacementObjectForArchiver: replacementObjectForCoder: replacementObjectForKeyedArchiver: replacementObjectForPortCoder:
                                respondsToSelector: retain retainCount retainWeakReference selectionAffinity self setAccessibilityActivationPoint: setAccessibilityContainer: setAccessibilityElementsHidden:
                                setAccessibilityFrame: setAccessibilityHint: setAccessibilityIdentifier: setAccessibilityLabel: setAccessibilityLanguage: setAccessibilityTraits: setAccessibilityValue:
                                setAccessibilityViewIsModal: setIsAccessibilityElement: setNilValueForKey: setObservationInfo: setValue:forKey: setValue:forKeyPath: setValue:forUndefinedKey: setValuesForKeysWithDictionary:
                                storedAccessibilityActivationPoint storedAccessibilityElementsHidden storedAccessibilityFrame storedAccessibilityTraits storedAccessibilityViewIsModal storedIsAccessibilityElement
                                superclass to_proc unregisterForTimeMarkerNotifications validateValue:forKey:error: validateValue:forKeyPath:error: valueForKey: valueForKeyPath: valueForUndefinedKey:
                                willChange:valuesAtIndexes:forKey: willChangeValueForKey: willChangeValueForKey:withSetMutation:usingObjects: zone
                                copyWithZone: object_id respond_to? respond_to?:).include? method.to_s
  end
end

X = Metavariable.new
