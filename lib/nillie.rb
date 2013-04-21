require 'nillie/version'
require 'set'

class NoMethodError # reopen
  attr_accessor :sent_method
end

class Nillie

  module MethodMissing
    def method_missing sent_method, *args
      # TODO: better error message by tracing the stack.
      e = NilError::NoMethod.new "Undefined method `#{sent_method}' for #{self}:#{self.class}!"
      e.sent_method = sent_method
      raise e
    end
  end
  include MethodMissing

  attr_reader :sent_method, :returned_by, :type_error
  def type_error? ; @type_error ; end

  class InvalidType < Nillie
    def initialize sent_method, type_error
      @sent_method = sent_method
      @type_error = type_error
      @returned_by = nil
    end
  end
  class Returned < Nillie
    def initialize returned_by
      @sent_method = nil
      @type_error = nil
      @returned_by = returned_by
    end
  end

  def self.catches &block
    block.call
  rescue NilError::NoMethod => e
    Nillie::InvalidType.new e.sent_method, false
  rescue TypeError => e
    if e.message =~ /\bnil\b|\bNilClass\b/
      Nillie::InvalidType.new nil, true
    else
      raise e
    end
  end

  # TODO: Really useful?
  DEFAULT_OPTS_OBSERVES = { ignoring: Set[ :puts, :warn ] }
  def self.observes opts = DEFAULT_OPTS_OBSERVES, &block
    # TODO: use trace_func to detect a method returning nil
    self.catches( &block )
  end

end

class NilError < NoMethodError
  class NoMethod < NilError ; end
  class Returned < NilError ; end
end

class NilClass # reopen
  include Nillie::MethodMissing
end

# TODO: Really useful?
module Kernel # reopen
  def method_missing sent_method, *args # override
    # TODO: better error message by tracing the stack.
    # TODO: correct the preposition before `self'. on? to?
    e = NoMethodError.new "Undefined method `#{sent_method}' called on #{self.inspect}!"
    e.sent_method = sent_method
    raise e
  end
end
