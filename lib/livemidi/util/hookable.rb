module Hookable

  HOOK_NAME = :@@hooks

  module ClassMethods
    def add_hook_for(step, method_name)
      hooks_for_step(step) << method_name
    end

    def hooks_for_step(step)
      hooks = class_variable_get(HOOK_NAME)
      hooks[step] ||= []
    end
  end

  module InstanceMethods
    def run_hooks(step)
      self.class.hooks_for_step(step).each { |method_name| self.send(method_name.to_sym) }
    end
  end

  def self.included(klass)
    klass.send(:class_variable_set, HOOK_NAME, { })
    klass.extend ClassMethods
    klass.send(:include, InstanceMethods)
  end
end
