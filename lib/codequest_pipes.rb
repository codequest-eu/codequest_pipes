#!/usr/bin/env ruby

module Pipes
  class InstanceError < ::Exception; end
end  # module Pipes

class Parent
  include Pipes::Pipe
  def self.call(ctx)
    puts('Evaluating parent...')
    ctx.add(parent: 1)
  end
end

class Child
  include Pipes::Pipe
  def self.call(ctx)
    puts('Evaluating child...')
    ctx.add(child: 2)
  end
end

class GrandChild
  include Pipes::Pipe
  def self.call(ctx)
    puts('Evaluating grandchild...')
    ctx.add(grandchild: 3)
    begin
      ctx.add(grandchild: 4)
    rescue Pipes::Context::Override
      puts('Can\'t touch this!')
    end
  end
end

class LoggingContext < Pipes::Context
  def on_start(klass, method)
    puts("Started #{klass.name}.#{method}")
  end

  def on_success(klass, method)
    puts("Successfully finished #{klass.name}.#{method}")
  end
end

def main
  a = Parent | Child | GrandChild
  ctx = LoggingContext.new
  a.call(ctx)
  puts(ctx.parent)
  puts(ctx.child)
  puts(ctx.grandchild)
  begin
    Parent.new
  rescue ::Pipes::InstanceError
    puts('No, you can\'t instantiate pipes')
  end
end

main if __FILE__ == $PROGRAM_NAME
