require File.join(File.dirname(__FILE__), *%w[.. .. spec_helper])
require 'livemidi/util/hookable'

class SomeHookedClass
  include Hookable

  add_hook_for :target_hook, :something

  def target_method
    run_hooks :target_hook
  end

  attr_reader :something_called
  def something
    @something_called = true
  end

  def target_method_without_hooks
    run_hooks :target_hook_that_doesnt_exist
  end
end

describe Hookable do

  it "should call the methods that have been hooked for the step" do
    hooked = SomeHookedClass.new
    hooked.target_method
    hooked.something_called.should be_true
  end

  it "should not care if there hasn't been any hooks registered yet" do
    hooked = SomeHookedClass.new
    hooked.target_method_without_hooks
  end
  
end
